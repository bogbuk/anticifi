from fastapi import APIRouter

from app.schemas.categorization import CategorizationRequest, CategorizationResponse
from app.services.categorization_service import categorize

router = APIRouter()


@router.post("/categorize", response_model=CategorizationResponse)
async def categorize_transaction(request: CategorizationRequest):
    suggestions = categorize(request)
    return CategorizationResponse(suggestions=suggestions)
