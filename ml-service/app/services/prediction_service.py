import re
import logging
from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta

from dateutil import parser as date_parser

from app.models.predictor import BalancePredictor
from app.schemas.prediction import (
    PredictionPoint,
    PredictionResponse,
    ChatPredictionResponse,
    TransactionData,
    ScheduledPaymentData,
)
from app.config import settings

logger = logging.getLogger(__name__)


def get_predictions(
    transactions: List[dict],
    current_balance: float,
    days_ahead: int = 30,
) -> PredictionResponse:
    """
    Train model and return predictions.

    Args:
        transactions: List of transaction dicts with date, amount, type.
        current_balance: Current account balance.
        days_ahead: Number of days to forecast.

    Returns:
        PredictionResponse with predictions list and confidence.
    """
    predictor = BalancePredictor()
    trained = predictor.train(transactions, current_balance)

    raw_predictions = predictor.predict(days_ahead)

    predictions = [
        PredictionPoint(
            date=p["date"],
            predictedBalance=p["predictedBalance"],
            lowerBound=p["lowerBound"],
            upperBound=p["upperBound"],
        )
        for p in raw_predictions
    ]

    confidence = 0.75 if trained else 0.3

    if len(transactions) >= 90:
        confidence = min(confidence + 0.15, 0.95)
    elif len(transactions) >= 30:
        confidence = min(confidence + 0.05, 0.90)

    return PredictionResponse(
        predictions=predictions,
        currentBalance=current_balance,
        confidence=round(confidence, 2),
    )


def process_chat_question(
    question: str,
    transactions: List[dict],
    current_balance: float,
    scheduled_payments: List[dict],
) -> ChatPredictionResponse:
    """
    Process a natural language financial question.

    Supports:
        - "What will my balance be on [date]?"
        - "Can I afford a $X purchase [timeframe]?"
        - "When will I run out of money?"
        - "How much can I spend this month?"

    Args:
        question: Natural language question.
        transactions: Historical transactions.
        current_balance: Current balance.
        scheduled_payments: Upcoming scheduled payments.

    Returns:
        ChatPredictionResponse with answer and optional predictions.
    """
    question_lower = question.lower().strip()

    predictor = BalancePredictor()
    predictor.train(transactions, current_balance)

    # Pattern 1: Balance on a specific date
    date_match = _extract_date_question(question_lower)
    if date_match:
        return _handle_balance_on_date(predictor, date_match, current_balance)

    # Pattern 2: Affordability check
    afford_match = _extract_afford_question(question_lower)
    if afford_match:
        amount, timeframe_days = afford_match
        return _handle_afford_check(
            predictor, amount, timeframe_days, current_balance
        )

    # Pattern 3: When will I run out of money
    if _is_runout_question(question_lower):
        return _handle_runout_question(predictor, current_balance)

    # Pattern 4: How much can I spend
    if _is_spending_budget_question(question_lower):
        return _handle_spending_budget(predictor, current_balance)

    # Default: provide a 30-day forecast summary
    return _handle_general_forecast(predictor, current_balance)


def _extract_date_question(question: str) -> Optional[date]:
    """Try to extract a target date from the question."""
    # Look for patterns like "on March 15", "on 2026-03-15", "by next Friday"
    date_patterns = [
        r"(?:on|by|for|at)\s+(.+?)(?:\?|$|\.)",
        r"balance\s+(.+?)(?:\?|$|\.)",
    ]

    for pattern in date_patterns:
        match = re.search(pattern, question)
        if match:
            date_str = match.group(1).strip()
            try:
                parsed = date_parser.parse(date_str, fuzzy=True)
                return parsed.date()
            except (ValueError, OverflowError):
                continue

    return None


def _extract_afford_question(
    question: str,
) -> Optional[tuple[float, int]]:
    """Extract amount and timeframe from affordability questions."""
    if "afford" not in question and "can i" not in question and "enough" not in question:
        return None

    # Extract dollar amount
    amount_match = re.search(r"\$\s*([\d,]+(?:\.\d{2})?)", question)
    if not amount_match:
        amount_match = re.search(r"([\d,]+(?:\.\d{2})?)\s*(?:dollar|usd)", question)
    if not amount_match:
        return None

    amount = float(amount_match.group(1).replace(",", ""))

    # Extract timeframe
    timeframe_days = 7  # default: next week
    if "tomorrow" in question:
        timeframe_days = 1
    elif "next week" in question:
        timeframe_days = 7
    elif "next month" in question or "end of month" in question:
        today = date.today()
        if today.month == 12:
            next_month = date(today.year + 1, 1, 1)
        else:
            next_month = date(today.year, today.month + 1, 1)
        timeframe_days = (next_month - today).days
    elif "today" in question or "now" in question:
        timeframe_days = 0

    return (amount, timeframe_days)


def _is_runout_question(question: str) -> bool:
    """Check if the question asks about running out of money."""
    runout_keywords = [
        "run out",
        "run low",
        "zero",
        "negative",
        "broke",
        "empty",
        "no money",
        "out of money",
    ]
    return any(kw in question for kw in runout_keywords)


def _is_spending_budget_question(question: str) -> bool:
    """Check if the question asks about spending budget."""
    budget_keywords = [
        "how much can i spend",
        "spending budget",
        "safe to spend",
        "available to spend",
        "can i spend",
        "spare money",
        "extra money",
    ]
    return any(kw in question for kw in budget_keywords)


def _handle_balance_on_date(
    predictor: BalancePredictor,
    target_date: date,
    current_balance: float,
) -> ChatPredictionResponse:
    """Answer: What will my balance be on [date]?"""
    predicted = predictor.predict_date(target_date)
    formatted_date = target_date.strftime("%B %d, %Y")

    days_away = (target_date - date.today()).days
    predictions_list = None

    if days_away > 0:
        raw = predictor.predict(days_away)
        predictions_list = [
            PredictionPoint(
                date=p["date"],
                predictedBalance=p["predictedBalance"],
                lowerBound=p["lowerBound"],
                upperBound=p["upperBound"],
            )
            for p in raw
        ]

    diff = predicted - current_balance
    direction = "increase" if diff >= 0 else "decrease"

    answer = (
        f"Based on your transaction history, your predicted balance on "
        f"{formatted_date} is ${predicted:,.2f}. "
        f"That's a ${abs(diff):,.2f} {direction} from your current "
        f"balance of ${current_balance:,.2f}."
    )

    return ChatPredictionResponse(answer=answer, predictions=predictions_list)


def _handle_afford_check(
    predictor: BalancePredictor,
    amount: float,
    timeframe_days: int,
    current_balance: float,
) -> ChatPredictionResponse:
    """Answer: Can I afford a $X purchase?"""
    if timeframe_days == 0:
        remaining = current_balance - amount
        if remaining >= 0:
            answer = (
                f"Yes, you can afford a ${amount:,.2f} purchase right now. "
                f"Your balance would be ${remaining:,.2f} after the purchase."
            )
        else:
            answer = (
                f"No, a ${amount:,.2f} purchase would put you ${abs(remaining):,.2f} "
                f"in the negative. Your current balance is ${current_balance:,.2f}."
            )
        return ChatPredictionResponse(answer=answer)

    predictions = predictor.predict(timeframe_days)
    predictions_list = [
        PredictionPoint(
            date=p["date"],
            predictedBalance=p["predictedBalance"],
            lowerBound=p["lowerBound"],
            upperBound=p["upperBound"],
        )
        for p in predictions
    ]

    # Check minimum predicted balance over the timeframe
    min_balance = min(p["predictedBalance"] for p in predictions) if predictions else current_balance
    remaining_after = min_balance - amount

    if remaining_after >= 0:
        answer = (
            f"Yes, you can likely afford a ${amount:,.2f} purchase. "
            f"Your lowest predicted balance over the next {timeframe_days} days "
            f"is ${min_balance:,.2f}, leaving you ${remaining_after:,.2f} "
            f"after the purchase."
        )
    else:
        answer = (
            f"This purchase might be risky. Your lowest predicted balance "
            f"over the next {timeframe_days} days is ${min_balance:,.2f}. "
            f"A ${amount:,.2f} purchase could leave you ${abs(remaining_after):,.2f} "
            f"short. Consider waiting or reducing the amount."
        )

    return ChatPredictionResponse(answer=answer, predictions=predictions_list)


def _handle_runout_question(
    predictor: BalancePredictor,
    current_balance: float,
) -> ChatPredictionResponse:
    """Answer: When will I run out of money?"""
    # Predict up to 180 days ahead
    predictions = predictor.predict(180)

    zero_crossing_date = None
    for p in predictions:
        if p["predictedBalance"] <= 0:
            zero_crossing_date = p["date"]
            break

    predictions_list = [
        PredictionPoint(
            date=p["date"],
            predictedBalance=p["predictedBalance"],
            lowerBound=p["lowerBound"],
            upperBound=p["upperBound"],
        )
        for p in predictions[:30]  # Return only 30 days of predictions
    ]

    if zero_crossing_date:
        days_until = (
            datetime.strptime(zero_crossing_date, "%Y-%m-%d").date() - date.today()
        ).days
        answer = (
            f"Based on your spending patterns, your balance could reach zero "
            f"around {zero_crossing_date} (about {days_until} days from now). "
            f"Consider reducing expenses or increasing income to extend your runway."
        )
    else:
        answer = (
            f"Good news! Based on your current spending patterns, your balance "
            f"is not predicted to reach zero within the next 6 months. "
            f"Your current balance is ${current_balance:,.2f}."
        )

    return ChatPredictionResponse(answer=answer, predictions=predictions_list)


def _handle_spending_budget(
    predictor: BalancePredictor,
    current_balance: float,
) -> ChatPredictionResponse:
    """Answer: How much can I spend this month?"""
    today = date.today()
    if today.month == 12:
        end_of_month = date(today.year + 1, 1, 1) - timedelta(days=1)
    else:
        end_of_month = date(today.year, today.month + 1, 1) - timedelta(days=1)

    days_left = (end_of_month - today).days
    if days_left <= 0:
        days_left = 30

    predictions = predictor.predict(days_left)

    predictions_list = [
        PredictionPoint(
            date=p["date"],
            predictedBalance=p["predictedBalance"],
            lowerBound=p["lowerBound"],
            upperBound=p["upperBound"],
        )
        for p in predictions
    ]

    end_balance = predictions[-1]["predictedBalance"] if predictions else current_balance
    buffer = current_balance * settings.SAFETY_BUFFER_PERCENT
    safe_to_spend = max(0, current_balance - buffer - max(0, current_balance - end_balance))

    answer = (
        f"Based on your predicted end-of-month balance of ${end_balance:,.2f}, "
        f"you can safely spend about ${safe_to_spend:,.2f} this month "
        f"while keeping a ${buffer:,.2f} safety buffer ({int(settings.SAFETY_BUFFER_PERCENT * 100)}% of your balance). "
        f"Your current balance is ${current_balance:,.2f}."
    )

    return ChatPredictionResponse(answer=answer, predictions=predictions_list)


def _handle_general_forecast(
    predictor: BalancePredictor,
    current_balance: float,
) -> ChatPredictionResponse:
    """Default answer: provide a 30-day forecast summary."""
    predictions = predictor.predict(30)

    predictions_list = [
        PredictionPoint(
            date=p["date"],
            predictedBalance=p["predictedBalance"],
            lowerBound=p["lowerBound"],
            upperBound=p["upperBound"],
        )
        for p in predictions
    ]

    if predictions:
        end_balance = predictions[-1]["predictedBalance"]
        min_balance = min(p["predictedBalance"] for p in predictions)
        max_balance = max(p["predictedBalance"] for p in predictions)

        diff = end_balance - current_balance
        direction = "increase" if diff >= 0 else "decrease"

        answer = (
            f"Here's your 30-day financial forecast: Your balance is predicted to "
            f"{direction} by ${abs(diff):,.2f}, from ${current_balance:,.2f} "
            f"to ${end_balance:,.2f}. During this period, your balance may range "
            f"between ${min_balance:,.2f} and ${max_balance:,.2f}."
        )
    else:
        answer = (
            f"I don't have enough transaction history to make a detailed prediction. "
            f"Your current balance is ${current_balance:,.2f}. "
            f"Keep tracking your transactions for better forecasts!"
        )

    return ChatPredictionResponse(answer=answer, predictions=predictions_list)
