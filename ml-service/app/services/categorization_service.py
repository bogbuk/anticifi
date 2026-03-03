import logging
from typing import Dict, List, Optional
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
import numpy as np

from app.schemas.categorization import (
    CategorizationRequest,
    CategorySuggestion,
    TransactionHistory,
    CategoryInfo,
)

logger = logging.getLogger(__name__)

# In-memory model cache keyed by user context hash
_model_cache: Dict[str, dict] = {}


def _build_model_key(categories: List[CategoryInfo]) -> str:
    return "|".join(sorted(c.id for c in categories))


def _train_model(
    history: List[TransactionHistory],
    categories: List[CategoryInfo],
) -> Optional[dict]:
    labeled = [tx for tx in history if tx.categoryId and tx.description]
    if len(labeled) < 20:
        return None

    category_map = {c.id: c.name for c in categories}
    valid = [tx for tx in labeled if tx.categoryId in category_map]
    if len(valid) < 20:
        return None

    texts = [tx.description for tx in valid]
    labels = [tx.categoryId for tx in valid]

    unique_labels = list(set(labels))
    if len(unique_labels) < 2:
        return None

    vectorizer = TfidfVectorizer(max_features=500, stop_words="english")
    X = vectorizer.fit_transform(texts)
    y = np.array(labels)

    model = LogisticRegression(max_iter=200, multi_class="multinomial")
    model.fit(X, y)

    return {
        "vectorizer": vectorizer,
        "model": model,
        "category_map": category_map,
    }


def _keyword_fallback(
    description: str,
    categories: List[CategoryInfo],
) -> List[CategorySuggestion]:
    keywords = {
        "Food & Dining": [
            "restaurant", "cafe", "coffee", "food", "pizza", "burger",
            "lunch", "dinner", "breakfast", "grocery", "supermarket",
        ],
        "Transportation": [
            "uber", "lyft", "taxi", "gas", "fuel", "parking",
            "metro", "bus", "train",
        ],
        "Shopping": [
            "amazon", "store", "shop", "mall", "purchase", "buy",
        ],
        "Entertainment": [
            "movie", "netflix", "spotify", "gaming", "concert", "theater",
        ],
        "Bills & Utilities": [
            "electric", "water", "internet", "phone", "insurance", "rent",
        ],
        "Health": [
            "pharmacy", "doctor", "hospital", "clinic", "medicine",
            "gym", "fitness",
        ],
        "Salary": [
            "salary", "payroll", "wages", "income", "deposit",
        ],
    }

    desc_lower = description.lower()
    suggestions: List[CategorySuggestion] = []

    for cat_name, kws in keywords.items():
        match_count = sum(1 for kw in kws if kw in desc_lower)
        if match_count > 0:
            cat = next(
                (c for c in categories if c.name.lower() == cat_name.lower()),
                None,
            )
            if cat:
                suggestions.append(
                    CategorySuggestion(
                        categoryId=cat.id,
                        categoryName=cat.name,
                        confidence=min(0.9, 0.3 + match_count * 0.2),
                    )
                )

    suggestions.sort(key=lambda s: s.confidence, reverse=True)
    return suggestions[:3]


def categorize(request: CategorizationRequest) -> List[CategorySuggestion]:
    if not request.categories:
        return []

    model_key = _build_model_key(request.categories)
    cached = _model_cache.get(model_key)

    if cached is None and len(request.history) >= 20:
        trained = _train_model(request.history, request.categories)
        if trained:
            _model_cache[model_key] = trained
            cached = trained

    if cached is not None:
        try:
            vectorizer = cached["vectorizer"]
            model = cached["model"]
            category_map = cached["category_map"]

            X = vectorizer.transform([request.description])
            probas = model.predict_proba(X)[0]
            classes = model.classes_

            top_indices = np.argsort(probas)[::-1][:3]
            suggestions = []

            for idx in top_indices:
                cat_id = classes[idx]
                confidence = float(probas[idx])
                if confidence < 0.05:
                    continue
                suggestions.append(
                    CategorySuggestion(
                        categoryId=cat_id,
                        categoryName=category_map.get(cat_id, "Unknown"),
                        confidence=round(confidence, 3),
                    )
                )

            if suggestions:
                return suggestions
        except Exception as e:
            logger.warning(f"ML prediction failed: {e}")

    return _keyword_fallback(request.description, request.categories)
