from fastapi import APIRouter, File, Form, UploadFile

from app.schemas.ocr import OcrMethod, OcrReceiptResponse
from app.services.ocr_service import process_receipt

router = APIRouter()


@router.post("/receipt", response_model=OcrReceiptResponse)
async def scan_receipt(
    file: UploadFile = File(...),
    method: OcrMethod = Form(default=OcrMethod.auto),
    default_currency: str | None = Form(default=None),
):
    image_bytes = await file.read()
    media_type = file.content_type or "image/jpeg"
    return await process_receipt(image_bytes, media_type, method, default_currency)
