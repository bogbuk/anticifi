import logging

from fastapi import APIRouter, HTTPException

from app.schemas.prediction import (
    PredictionRequest,
    PredictionResponse,
    ChatPredictionRequest,
    ChatPredictionResponse,
)
from app.services.prediction_service import get_predictions, process_chat_question

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("", response_model=PredictionResponse)
async def predict(request: PredictionRequest) -> PredictionResponse:
    """Generate balance predictions from transaction history."""
    try:
        transactions = [tx.model_dump() for tx in request.transactions]

        response = get_predictions(
            transactions=transactions,
            current_balance=request.currentBalance,
            days_ahead=request.daysAhead,
        )

        return response

    except Exception as e:
        logger.error(f"Prediction failed: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")


@router.post("/chat", response_model=ChatPredictionResponse)
async def chat_predict(request: ChatPredictionRequest) -> ChatPredictionResponse:
    """Process a natural language financial question."""
    try:
        transactions = [tx.model_dump() for tx in request.transactions]
        scheduled = [sp.model_dump() for sp in request.scheduledPayments]

        response = process_chat_question(
            question=request.question,
            transactions=transactions,
            current_balance=request.currentBalance,
            scheduled_payments=scheduled,
        )

        return response

    except Exception as e:
        logger.error(f"Chat prediction failed: {e}")
        raise HTTPException(
            status_code=500, detail=f"Chat prediction failed: {str(e)}"
        )


@router.get("/health")
async def health():
    """ML prediction service health check."""
    return {"status": "ok", "service": "prediction-engine"}
