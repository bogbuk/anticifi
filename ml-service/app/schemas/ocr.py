from enum import Enum

from pydantic import BaseModel


class OcrMethod(str, Enum):
    tesseract = "tesseract"
    paddleocr = "paddleocr"
    glm_ocr = "glm-ocr"
    deepseek_ocr = "deepseek-ocr"
    gemini = "gemini"
    claude = "claude"
    qwen = "qwen"
    auto = "auto"


class ReceiptItem(BaseModel):
    name: str
    price: float


class OcrReceiptResponse(BaseModel):
    merchant: str | None = None
    amount: float | None = None
    date: str | None = None
    currency: str | None = None
    items: list[ReceiptItem] | None = None
    confidence: float
    method_used: str
