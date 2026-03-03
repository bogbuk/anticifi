from pydantic import BaseModel
from typing import List, Optional


class TransactionHistory(BaseModel):
    description: str
    categoryId: Optional[str] = None
    categoryName: Optional[str] = None
    amount: float
    type: str


class CategoryInfo(BaseModel):
    id: str
    name: str


class CategorizationRequest(BaseModel):
    description: str
    type: Optional[str] = None
    amount: Optional[float] = None
    history: List[TransactionHistory] = []
    categories: List[CategoryInfo] = []


class CategorySuggestion(BaseModel):
    categoryId: str
    categoryName: str
    confidence: float


class CategorizationResponse(BaseModel):
    suggestions: List[CategorySuggestion]
