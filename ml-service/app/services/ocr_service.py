"""Receipt OCR service — PaddleOCR + Ollama vision + cloud providers.

Enhanced with: image preprocessing, quality detection, hybrid OCR+LLM,
language-based currency detection, improved prompts.
"""

import base64
import json
import logging
import os
import re
from io import BytesIO

import cv2
import numpy as np

from app.schemas.ocr import OcrMethod, OcrReceiptResponse, ReceiptItem

logger = logging.getLogger(__name__)

# Cached PaddleOCR instance (initialization takes ~10-15s)
_paddle_ocr_instance = None


def _get_paddle_ocr():
    global _paddle_ocr_instance
    if _paddle_ocr_instance is None:
        from paddleocr import PaddleOCR
        _paddle_ocr_instance = PaddleOCR(
            lang='ch',
            use_angle_cls=True,
            text_det_limit_side_len=960,
            text_det_limit_type='max',
        )
    return _paddle_ocr_instance


# Cached PaddleOCR Cyrillic instance for Ukrainian/Russian receipts
_paddle_ocr_cyrillic = None


def _get_paddle_ocr_cyrillic():
    global _paddle_ocr_cyrillic
    if _paddle_ocr_cyrillic is None:
        from paddleocr import PaddleOCR
        _paddle_ocr_cyrillic = PaddleOCR(
            lang='uk',
            use_angle_cls=True,
            text_det_limit_side_len=960,
            text_det_limit_type='max',
        )
    return _paddle_ocr_cyrillic


def _has_cyrillic_artifacts(text: str) -> bool:
    """Detect if PaddleOCR with lang='ch' produced Cyrillic transliteration artifacts."""
    artifact_re = re.compile(
        r'厂PH|rPH|CYMA|4ICKANbH|中ICKANbH|KACHP|4EK\b|NAB\s|BE3FOTI|'
        r'KOnInKA|KOHiHKA|GE3ROTI|EKBA[PN]PA',
        re.I,
    )
    if artifact_re.search(text):
        return True
    cyrillic_chars = len(re.findall(r'[\u0400-\u04ff]', text))
    latin_upper_runs = len(re.findall(r'[A-Z]{4,}', text))
    if cyrillic_chars < 5 and latin_upper_runs > 3:
        if _detect_language_currency(text) == 'UAH':
            return True
    return False


# ---------------------------------------------------------------------------
# Prompts
# ---------------------------------------------------------------------------

VISION_PROMPT = """You are a receipt data extraction expert. Analyze this receipt image carefully.

STEPS:
1. Identify the language and country of the receipt
2. Based on the country, determine the correct currency (ISO 4217)
3. Find the TOTAL/GRAND TOTAL amount (not subtotal, not tax, not individual items)
4. Extract the merchant/store name from the top of the receipt
5. Find the transaction date

CURRENCY RULES:
- Chinese text (汉字) → CNY
- Ukrainian text (кирилиця, грн) → UAH
- "Lei" or "MDL" → MDL (Moldova)
- £ → GBP, € → EUR, $ → USD
- Polish (zł, PLN) → PLN

Return ONLY this JSON (no explanation, no markdown):
{"merchant": "store name", "amount": 12.50, "date": "DD/MM/YYYY", "currency": "EUR", "items": [{"name": "item", "price": 1.50}]}

IMPORTANT:
- amount MUST be the grand total the customer paid
- currency MUST be a 3-letter ISO 4217 code
- If you cannot determine a field, use null
- Do NOT guess or hallucinate values"""

HYBRID_PROMPT_TEMPLATE = """You are a receipt parser. Below is raw OCR text extracted from a receipt image.
Extract structured data from this text.

OCR TEXT:
---
{ocr_text}
---

RULES:
- Find the TOTAL amount (grand total, final paid amount)
- Identify currency from symbols, text, or language context
- Chinese text → CNY, Ukrainian/Cyrillic → UAH, "Lei"/"MDL" → MDL
- Extract merchant name (usually first lines)
- Extract date in DD/MM/YYYY format
- Extract line items with prices if visible

Return ONLY valid JSON:
{{"merchant": "...", "amount": 12.50, "date": "DD/MM/YYYY", "currency": "EUR", "items": [{{"name": "item", "price": 1.50}}]}}
Use null for fields you cannot determine."""

# ---------------------------------------------------------------------------
# Currency normalization
# ---------------------------------------------------------------------------

_CURRENCY_NORMALIZE = {
    '€': 'EUR', '$': 'USD', '£': 'GBP', '₺': 'TRY',
    '¥': 'CNY', '￥': 'CNY',
    'zł': 'PLN', 'złoty': 'PLN', 'zloty': 'PLN',
    'Kč': 'CZK', '₴': 'UAH', 'грн': 'UAH', 'грн.': 'UAH', 'ГРН': 'UAH',
    '元': 'CNY', 'RMB': 'CNY',
    'LEI': 'MDL', 'лей': 'MDL',
}


def _normalize_currency(raw: str | None) -> str | None:
    if not raw:
        return None
    stripped = raw.strip()
    if re.match(r'^[A-Z]{3}$', stripped):
        return stripped
    return _CURRENCY_NORMALIZE.get(stripped, _CURRENCY_NORMALIZE.get(
        stripped.upper(), stripped.upper() if len(stripped) <= 4 else None))


def _detect_language_currency(text: str) -> str | None:
    """Detect currency by character set and OCR artifacts."""
    chinese_chars = len(re.findall(r'[\u4e00-\u9fff]', text))
    cyrillic_chars = len(re.findall(r'[\u0400-\u04ff]', text))

    # PaddleOCR with lang='ch' often transliterates Cyrillic to Latin+Chinese mix.
    # Detect Ukrainian receipts by typical OCR artifacts:
    # "ГРН" → "厂PH", "СУМА" → "CYMA", "ФІСКАЛЬНИЙ" → "中ICKANbH"
    # "КАСИР" → "KACHP", "ЧЕК" → "4EK", "ПДВ" → "NAB"
    uah_markers = re.search(
        r'厂PH|rPH|CYMA|4ICKANbH|中ICKANbH|KACHP|4EK\b|NAB\s*A|BE3FOTI|'
        r'грн|ГРН|UAH|₴|ФІСКАЛЬНИЙ|КАСИР|СУМА',
        text, re.I
    )
    if uah_markers:
        return 'UAH'

    # Russian receipt markers
    rub_markers = re.search(
        r'руб|RUB|₽|ИТОГО\s*К\s*ОПЛАТЕ|НАЛИЧНЫЕ|СДАЧА',
        text
    )
    if rub_markers:
        return 'RUB'

    if chinese_chars > 5:
        return 'CNY'
    if cyrillic_chars > 10:
        if re.search(r'MDL|лей', text, re.I):
            return 'MDL'
        return 'UAH'
    return None


def _normalize_date(raw: str | None) -> str | None:
    """Normalize date string to ISO YYYY-MM-DD format."""
    if not raw or raw == 'None':
        return None

    raw = raw.strip()

    # Already ISO
    m = re.match(r'^(\d{4})-(\d{1,2})-(\d{1,2})$', raw)
    if m:
        y, mo, d = int(m.group(1)), int(m.group(2)), int(m.group(3))
        if 1 <= mo <= 12 and 1 <= d <= 31:
            return f"{y}-{mo:02d}-{d:02d}"

    parts = re.split(r'[/\-.]', raw)
    if len(parts) != 3:
        return raw

    try:
        a, b, c = int(parts[0]), int(parts[1]), int(parts[2])
    except ValueError:
        return raw

    if a > 31:
        year, month, day = a, b, c
    elif c > 31:
        # DD/MM/YYYY or MM/DD/YYYY — default to DD/MM/YYYY (European)
        if a > 12:
            day, month, year = a, b, c
        elif b > 12:
            month, day, year = a, b, c
        else:
            day, month, year = a, b, c
    else:
        # Two-digit year
        if a > 12:
            day, month, year = a, b, c
        else:
            day, month, year = a, b, c

    if year < 100:
        year += 2000 if year < 50 else 1900

    if not (1 <= month <= 12 and 1 <= day <= 31 and 1900 <= year <= 2100):
        return raw

    return f"{year}-{month:02d}-{day:02d}"


# ---------------------------------------------------------------------------
# Image preprocessing
# ---------------------------------------------------------------------------

def _deskew(gray: np.ndarray) -> np.ndarray:
    """Deskew using Hough line transform."""
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, 100, minLineLength=100, maxLineGap=10)
    if lines is None:
        return gray

    angles = []
    for line in lines:
        x1, y1, x2, y2 = line[0]
        angle = np.degrees(np.arctan2(y2 - y1, x2 - x1))
        if abs(angle) < 30:
            angles.append(angle)

    if not angles:
        return gray

    median_angle = float(np.median(angles))
    if abs(median_angle) < 0.5:
        return gray

    h, w = gray.shape
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, median_angle, 1.0)
    return cv2.warpAffine(gray, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)


def assess_image_quality(image_bytes: bytes) -> dict:
    """Assess receipt image quality."""
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    h, w = gray.shape

    laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    mean_brightness = float(np.mean(gray))
    contrast = float(gray.std())

    issues = []
    if laplacian_var < 100:
        issues.append('blurry')
    if mean_brightness < 80:
        issues.append('too_dark')
    if mean_brightness > 220:
        issues.append('overexposed')
    if contrast < 40:
        issues.append('low_contrast')
    if max(h, w) < 500:
        issues.append('low_resolution')

    return {'issues': issues, 'needs_enhancement': len(issues) > 0}


def auto_enhance(image_bytes: bytes, issues: list[str]) -> bytes:
    """Auto-enhance image based on detected issues."""
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if 'too_dark' in issues:
        table = np.array([((i / 255.0) ** (1.0 / 1.8)) * 255 for i in range(256)]).astype('uint8')
        img = cv2.LUT(img, table)

    if 'overexposed' in issues:
        table = np.array([((i / 255.0) ** (1.0 / 0.6)) * 255 for i in range(256)]).astype('uint8')
        img = cv2.LUT(img, table)

    if 'low_contrast' in issues:
        lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
        l = clahe.apply(l)
        img = cv2.cvtColor(cv2.merge([l, a, b]), cv2.COLOR_LAB2BGR)

    if 'blurry' in issues:
        kernel = np.array([[-1, -1, -1], [-1, 9, -1], [-1, -1, -1]])
        img = cv2.filter2D(img, -1, kernel)

    _, buf = cv2.imencode('.jpg', img, [cv2.IMWRITE_JPEG_QUALITY, 95])
    return buf.tobytes()


def preprocess_receipt(image_bytes: bytes) -> np.ndarray:
    """Full preprocessing pipeline for receipt images."""
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # 1. Resize to optimal range
    h, w = img.shape[:2]
    max_side = 2000
    if max(h, w) > max_side:
        scale = max_side / max(h, w)
        img = cv2.resize(img, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA)
    elif max(h, w) < 1000:
        scale = 1500 / max(h, w)
        img = cv2.resize(img, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)

    # 2. Grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 3. Deskew
    gray = _deskew(gray)

    # 4. Denoise
    gray = cv2.fastNlMeansDenoising(gray, h=10, templateWindowSize=7, searchWindowSize=21)

    # 5. CLAHE contrast enhancement
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    gray = clahe.apply(gray)

    # 6. Adaptive binarization
    binary = cv2.adaptiveThreshold(
        gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY, 31, 15
    )

    # Convert back to 3-channel for PaddleOCR
    return cv2.cvtColor(binary, cv2.COLOR_GRAY2BGR)


# ---------------------------------------------------------------------------
# Text parsing helpers (for Tesseract / PaddleOCR / DeepSeek raw text)
# ---------------------------------------------------------------------------

def _parse_amount(raw: str) -> float | None:
    cleaned = re.sub(r'[€$£\s]', '', raw).strip()
    if re.match(r'^\d{1,3}(\.\d{3})*(,\d{2})$', cleaned):
        cleaned = cleaned.replace('.', '').replace(',', '.')
    elif re.match(r'^\d{1,3}(,\d{3})*(\.\d{2})$', cleaned):
        cleaned = cleaned.replace(',', '')
    elif re.match(r'^\d+,\d{2}$', cleaned):
        cleaned = cleaned.replace(',', '.')
    try:
        val = float(cleaned)
        return val if val > 0 else None
    except ValueError:
        return None


def _parse_ocr_text(text: str) -> dict:
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    result: dict = {}

    # --- Currency detection (explicit symbols/codes first) ---
    if re.search(r'MDL\b', text):
        result['currency'] = 'MDL'
    elif re.search(r'\bRON\b', text):
        result['currency'] = 'RON'
    elif re.search(r'\bLEI\b', text, re.I):
        # "LEI" is ambiguous: RON (Romania) or MDL (Moldova)
        # Detect Moldova by: IDNO (tax ID), Chisinau, +373 phone code
        if re.search(r'IDNO|Chisinau|Chișinău|Chi[sș]in[aă]u|\+373|Moldova', text, re.I):
            result['currency'] = 'MDL'
        else:
            result['currency'] = 'RON'
    elif re.search(r'\bUAH\b|\bгрн\b|厂PH|rPH|ГРН', text, re.I):
        result['currency'] = 'UAH'
    elif re.search(r'\bTRY\b|\bTL\b', text) or '₺' in text:
        result['currency'] = 'TRY'
    elif re.search(r'\bJPY\b|\b円\b', text) or '¥' in text:
        result['currency'] = 'JPY'
    elif re.search(r'\bCNY\b|\bRMB\b|\b元\b', text):
        result['currency'] = 'CNY'
    elif re.search(r'\bPLN\b|\bzł\b', text, re.I):
        result['currency'] = 'PLN'
    elif re.search(r'\bCZK\b|\bKč\b', text, re.I):
        result['currency'] = 'CZK'
    elif re.search(r'\bCHF\b', text):
        result['currency'] = 'CHF'
    elif '€' in text or '¢' in text or re.search(r'\bEUR\b', text):
        result['currency'] = 'EUR'
    elif '£' in text or re.search(r'\bGBP\b', text):
        result['currency'] = 'GBP'
    elif '$' in text or re.search(r'\bUSD\b', text):
        result['currency'] = 'USD'

    # Fallback: detect by character set (Chinese → CNY, Cyrillic → UAH)
    if 'currency' not in result:
        lang_currency = _detect_language_currency(text)
        if lang_currency:
            result['currency'] = lang_currency

    # --- Merchant ---
    merchant_label = re.compile(r'(?:comerciant|merchant|marchand|händler)[:\s]+(.+)', re.I)
    for line in lines:
        m = merchant_label.match(line)
        if m:
            result['merchant'] = m.group(1).strip()
            break

    if 'merchant' not in result:
        skip_merchant = re.compile(r'^tel\b|^\d+\s*(rue|st|ave|blvd|road|str|sos\.|adresa)', re.I)
        for line in lines:
            clean = re.sub(r'[^a-zA-Z\u00C0-\u024F\u4e00-\u9fff\u0400-\u04ff0-9\s\-\'."]', '', line).strip()
            alpha_count = len(re.findall(r'[a-zA-Z\u00C0-\u024F\u4e00-\u9fff\u0400-\u04ff]', clean))
            if alpha_count >= 3 and not skip_merchant.search(line):
                result['merchant'] = clean
                break

    # --- Total amount ---
    cur = r'[$€£¢]'
    total_patterns = [
        re.compile(rf'(?:total\s*(?:a|à)\s*payer|montant\s*(?:total|ttc)?|total\s*ttc)[:\s|]*{cur}?\s*([\d.,]+)\s*{cur}?', re.I),
        re.compile(rf'(?:grand\s*total|total\s*due|balance\s*due|amount\s*due|total)[:\s|]*{cur}?\s*([\d.,]+)\s*{cur}?', re.I),
        re.compile(rf'(?:gesamtbetrag|summe|gesamt|zu\s*zahlen)[:\s|]*{cur}?\s*([\d.,]+)\s*{cur}?', re.I),
        re.compile(rf'(?:total\s*a\s*pagar|importe\s*total|importe)[:\s|]*{cur}?\s*([\d.,]+)\s*{cur}?', re.I),
        re.compile(r'total\s*(?:LEI|MDL|RON)[:\s|]*([\d.,]+)', re.I),
        re.compile(rf'(?:suma|total\s*de\s*plat[aă])[:\s|]*{cur}?\s*([\d.,]+)\s*(?:MDL|RON|LEI)?', re.I),
        re.compile(r'(?:^|[\s|])(?:合\s*计|总\s*计|总\s*额|实\s*付|应\s*付|实\s*收)[:\s]*[¥￥]?\s*([\d]+(?:[.,]\d{1,2})?)\s*[元¥￥]?(?:\s|$)', re.M),  # Chinese total
        # Ukrainian: "СУМА 60.80 ГРН" or OCR artifact "CYMA 60.80 厂PH"
        re.compile(r'(?:СУМА|CYMA|СУММА)[:\s]*([\d.,]+)', re.I),
        # Russian: "ИТОГО К ОПЛАТЕ" / "ИТОГО:"
        re.compile(r'(?:ИТОГО\s*К\s*ОПЛАТЕ|ИТОГО)[:\s.=]*([\d.,]+)', re.I),
        # Ukrainian OCR: "BE3FOTI" (БЕЗГОТІВКОВА) card payment line
        re.compile(r'(?:BE3FOTI\w*|БЕЗГОТІВКОВА)[:\s]*([\d.,]+)', re.I),
        re.compile(r'(?:visa|mastercard|card)[:\s]*([\d.,]+)', re.I),
    ]

    for pattern in total_patterns:
        for line in lines:
            m = pattern.search(line)
            if m:
                amount = _parse_amount(m.group(1))
                if amount:
                    result['amount'] = amount
                    break
        if 'amount' in result:
            break

    # Multi-line total: "CYMA\n60.80\n厂PH" or "СУМА\n60.80\nГРН"
    if 'amount' not in result:
        full = '\n'.join(lines)
        m = re.search(
            r'(?:СУМА|CYMA|СУММА)\s*\n?\s*([\d.,]+)\s*\n?\s*(?:厂PH|rPH|ГРН|грн)',
            full, re.I
        )
        if m:
            amount = _parse_amount(m.group(1))
            if amount:
                result['amount'] = amount
        # Also: "60,80PH" (number directly before PH/ГРН)
        if 'amount' not in result:
            m = re.search(r'([\d.,]+)\s*(?:厂PH|rPH|ГРН|грн)', full, re.I)
            if m:
                amount = _parse_amount(m.group(1))
                if amount:
                    result['amount'] = amount

    # Fallback: largest price-like value
    if 'amount' not in result:
        price_pattern = re.compile(rf'{cur}?\s*([\d]+[.,]\d{{2}})\s*{cur}?')
        skip_fallback = re.compile(r'tel|phone|fax|rue|street|addr', re.I)
        max_amount = 0.0
        for line in lines:
            if skip_fallback.search(line):
                continue
            for m in price_pattern.finditer(line):
                val = _parse_amount(m.group(1))
                if val and val > max_amount:
                    max_amount = val
        if max_amount > 0:
            result['amount'] = max_amount

    # --- Date ---
    date_patterns = [
        re.compile(r'(\d{4}[/\-\.]\d{1,2}[/\-\.]\d{1,2})'),  # YYYY-MM-DD
        re.compile(r'(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})'),  # DD/MM/YYYY
    ]
    for dp in date_patterns:
        for line in lines:
            m = dp.search(line)
            if m:
                result['date'] = _normalize_date(m.group(1))
                break
        if 'date' in result:
            break

    # --- Items ---
    items: list[dict] = []
    skip_items = re.compile(
        r'total|subtotal|sub.total|tax|tip|tva|montant|payer|summe|gesamt|importe|'
        r'balance|change|visa|master|carte|cb\s|emv|article|suma|achitare|reusit|'
        r'comerciant|locatie|adresa|terminal|autorizare|tranzactie|contactless|'
        r'returnare|multumim|suport|cashback|discount|rabatt|remise|coupon|'
        r'card\b|cash\b|наличн|сдача|безнал|ПДВ|НДС|CYMA|厂PH|BE3FOTI|'
        r'合\s*计|总\s*计|小\s*计|实\s*付|找\s*零', re.I
    )
    # Pattern: "Item name    12.50" (2+ spaces between name and price)
    item_re = re.compile(rf'^(.+?)\s{{2,}}{cur}?\s*([\d]+[.,]\d{{2}})\s*{cur}?\s*[A-Za-z]?\s*$')
    # Pattern: "Item name  x2  12.50" (quantity notation)
    item_qty_re = re.compile(rf'^(.+?)\s+[xXхХ*]?\d+[.,]?\d*\s+{cur}?\s*([\d]+[.,]\d{{2}})\s*{cur}?\s*$')
    for line in lines:
        if skip_items.search(line):
            continue
        m = item_re.match(line) or item_qty_re.match(line)
        if m:
            name = re.sub(r'^\*+', '', m.group(1)).strip()
            price = _parse_amount(m.group(2))
            if price and price < 10000 and len(name) >= 2:
                items.append({'name': name, 'price': price})
    if items:
        result['items'] = items

    return result


# ---------------------------------------------------------------------------
# Tesseract OCR
# ---------------------------------------------------------------------------

async def _ocr_tesseract(image_bytes: bytes) -> OcrReceiptResponse:
    import pytesseract
    from PIL import Image

    preprocessed = preprocess_receipt(image_bytes)
    img = Image.fromarray(preprocessed)

    data = pytesseract.image_to_data(img, lang='eng+fra+deu+spa+ron', output_type=pytesseract.Output.DICT)
    confidences = [int(c) for c, t in zip(data['conf'], data['text']) if t.strip() and int(c) >= 0]
    confidence = sum(confidences) / len(confidences) if confidences else 0.0

    text = pytesseract.image_to_string(img, lang='eng+fra+deu+spa+ron')
    parsed = _parse_ocr_text(text)

    return OcrReceiptResponse(
        merchant=parsed.get('merchant'),
        amount=parsed.get('amount'),
        date=parsed.get('date'),
        currency=parsed.get('currency'),
        items=[ReceiptItem(**i) for i in parsed.get('items', [])] if parsed.get('items') else None,
        confidence=confidence,
        method_used='tesseract',
    )


# ---------------------------------------------------------------------------
# PaddleOCR
# ---------------------------------------------------------------------------

async def _ocr_paddleocr(image_bytes: bytes) -> OcrReceiptResponse:
    # PaddleOCR PP-OCRv5 has its own preprocessing — skip ours to avoid artifacts
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    ocr = _get_paddle_ocr()
    result = ocr.predict(img)

    lines = []
    total_conf = 0.0
    count = 0
    for res in result:
        for text, score in zip(res['rec_texts'], res['rec_scores']):
            lines.append(text)
            total_conf += score
            count += 1

    full_text = '\n'.join(lines)

    # Re-run with Cyrillic model if transliteration artifacts detected
    if _has_cyrillic_artifacts(full_text):
        logger.info("Cyrillic artifacts detected, re-running with lang='uk'")
        ocr_cyr = _get_paddle_ocr_cyrillic()
        result_cyr = ocr_cyr.predict(img)
        lines = []
        total_conf = 0.0
        count = 0
        for res in result_cyr:
            for text, score in zip(res['rec_texts'], res['rec_scores']):
                lines.append(text)
                total_conf += score
                count += 1
        full_text = '\n'.join(lines)

    confidence = (total_conf / count * 100) if count > 0 else 0.0
    parsed = _parse_ocr_text(full_text)

    return OcrReceiptResponse(
        merchant=parsed.get('merchant'),
        amount=parsed.get('amount'),
        date=parsed.get('date'),
        currency=parsed.get('currency'),
        items=[ReceiptItem(**i) for i in parsed.get('items', [])] if parsed.get('items') else None,
        confidence=confidence,
        method_used='paddleocr',
    )


# ---------------------------------------------------------------------------
# Hybrid: PaddleOCR text → LLM parsing
# ---------------------------------------------------------------------------

async def _ocr_hybrid(image_bytes: bytes, media_type: str) -> OcrReceiptResponse:
    """PaddleOCR extracts text, Qwen LLM structures it (no image sent to LLM)."""
    import httpx

    # PaddleOCR PP-OCRv5 has its own preprocessing — use raw image
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    ocr = _get_paddle_ocr()
    result = ocr.predict(img)

    lines = []
    for res in result:
        for text in res['rec_texts']:
            lines.append(text)

    ocr_text = '\n'.join(lines)
    if not ocr_text.strip():
        raise ValueError("PaddleOCR produced no text")

    # Send text (not image) to LLM for structured extraction
    ollama_host = os.environ.get('OLLAMA_HOST', 'http://localhost:11434')
    model = os.environ.get('QWEN_VL_MODEL', 'qwen3.5:9b')
    prompt = HYBRID_PROMPT_TEMPLATE.format(ocr_text=ocr_text)

    async with httpx.AsyncClient(timeout=300) as client:
        resp = await client.post(f'{ollama_host}/api/chat', json={
            'model': model,
            'messages': [{'role': 'user', 'content': prompt}],
            'stream': False,
        })

    content = resp.json().get('message', {}).get('content', '')
    data = _parse_llm_json(content)
    return _llm_json_to_response(data, f'hybrid-paddleocr+{model}')


# ---------------------------------------------------------------------------
# LLM Vision providers
# ---------------------------------------------------------------------------

def _parse_llm_json(content: str) -> dict:
    """Extract JSON from LLM response (handles ```json``` blocks)."""
    m = re.search(r'```(?:json)?\s*\n?(.*?)\n?```', content, re.S)
    raw = m.group(1) if m else content

    start = raw.find('{')
    end = raw.rfind('}')
    if start == -1 or end == -1:
        return {}

    try:
        return json.loads(raw[start:end + 1])
    except json.JSONDecodeError:
        logger.warning("Failed to parse LLM JSON response: %s", raw[start:end + 1][:200])
        return {}


def _llm_json_to_response(data: dict, method: str) -> OcrReceiptResponse:
    items = None
    if data.get('items'):
        items = [ReceiptItem(name=i.get('name', ''), price=float(i.get('price', 0)))
                 for i in data['items'] if i.get('name')]

    amount = data.get('amount')
    if amount is not None:
        try:
            amount = float(amount)
            if amount == 0:
                amount = None
        except (ValueError, TypeError):
            amount = None

    currency = _normalize_currency(data.get('currency'))

    return OcrReceiptResponse(
        merchant=data.get('merchant'),
        amount=amount,
        date=_normalize_date(data.get('date')),
        currency=currency,
        items=items,
        confidence=90.0,
        method_used=method,
    )


# --- Ollama-based vision models ---

async def _ocr_ollama_vision(image_bytes: bytes, model: str, method_name: str) -> OcrReceiptResponse:
    """Generic Ollama vision model caller."""
    import httpx

    ollama_host = os.environ.get('OLLAMA_HOST', 'http://localhost:11434')
    b64 = base64.b64encode(image_bytes).decode()

    async with httpx.AsyncClient(timeout=300) as client:
        resp = await client.post(f'{ollama_host}/api/chat', json={
            'model': model,
            'messages': [{
                'role': 'user',
                'content': VISION_PROMPT,
                'images': [b64],
            }],
            'stream': False,
        })

    content = resp.json().get('message', {}).get('content', '')
    data = _parse_llm_json(content)
    return _llm_json_to_response(data, method_name)


async def _ocr_glm(image_bytes: bytes, media_type: str) -> OcrReceiptResponse:
    model = os.environ.get('GLM_OCR_MODEL', 'glm-ocr')
    return await _ocr_ollama_vision(image_bytes, model, f'glm-ocr ({model})')


async def _ocr_deepseek(image_bytes: bytes, media_type: str) -> OcrReceiptResponse:
    """DeepSeek-OCR: pure OCR model — returns raw text, needs regex parsing."""
    import httpx

    ollama_host = os.environ.get('OLLAMA_HOST', 'http://localhost:11434')
    model = os.environ.get('DEEPSEEK_OCR_MODEL', 'deepseek-ocr:3b')
    b64 = base64.b64encode(image_bytes).decode()

    async with httpx.AsyncClient(timeout=300) as client:
        resp = await client.post(f'{ollama_host}/api/chat', json={
            'model': model,
            'messages': [{
                'role': 'user',
                'content': '<image>\nOCR this receipt image. Extract all text.',
                'images': [b64],
            }],
            'stream': False,
        })

    text = resp.json().get('message', {}).get('content', '')
    parsed = _parse_ocr_text(text)

    return OcrReceiptResponse(
        merchant=parsed.get('merchant'),
        amount=parsed.get('amount'),
        date=parsed.get('date'),
        currency=parsed.get('currency'),
        items=[ReceiptItem(**i) for i in parsed.get('items', [])] if parsed.get('items') else None,
        confidence=85.0,
        method_used=f'deepseek-ocr ({model})',
    )


async def _ocr_qwen(image_bytes: bytes, media_type: str) -> OcrReceiptResponse:
    model = os.environ.get('QWEN_VL_MODEL', 'qwen3.5:9b')
    return await _ocr_ollama_vision(image_bytes, model, f'qwen-local ({model})')


# --- Cloud providers ---

async def _ocr_gemini(image_bytes: bytes, media_type: str) -> OcrReceiptResponse:
    from openai import OpenAI

    api_key = os.environ.get('GEMINI_API_KEY', '')
    base_url = os.environ.get('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta/openai/')

    client = OpenAI(api_key=api_key, base_url=base_url)
    b64 = base64.b64encode(image_bytes).decode()

    response = client.chat.completions.create(
        model='gemini-2.5-flash',
        messages=[{
            'role': 'user',
            'content': [
                {'type': 'text', 'text': VISION_PROMPT},
                {'type': 'image_url', 'image_url': {'url': f'data:{media_type};base64,{b64}'}},
            ],
        }],
        max_tokens=1024,
    )

    content = response.choices[0].message.content or ''
    data = _parse_llm_json(content)
    return _llm_json_to_response(data, 'gemini')


async def _ocr_claude(image_bytes: bytes, media_type: str) -> OcrReceiptResponse:
    import anthropic

    api_key = os.environ.get('ANTHROPIC_API_KEY', '')
    client = anthropic.Anthropic(api_key=api_key)
    b64 = base64.b64encode(image_bytes).decode()

    response = client.messages.create(
        model='claude-haiku-4-5-20251001',
        max_tokens=1024,
        messages=[{
            'role': 'user',
            'content': [
                {
                    'type': 'image',
                    'source': {'type': 'base64', 'media_type': media_type, 'data': b64},
                },
                {'type': 'text', 'text': VISION_PROMPT},
            ],
        }],
    )

    content = response.content[0].text if response.content else ''
    data = _parse_llm_json(content)
    return _llm_json_to_response(data, 'claude')


# ---------------------------------------------------------------------------
# Auto: fallback chain (PaddleOCR → Qwen → DeepSeek)
# ---------------------------------------------------------------------------

async def _ocr_auto(image_bytes: bytes, media_type: str) -> OcrReceiptResponse:
    """PaddleOCR fast path → LLM fallback for low confidence."""

    # Step 0: Quality assessment + auto-enhance
    quality = assess_image_quality(image_bytes)
    if quality['needs_enhancement']:
        logger.info("Auto-enhancing image, issues: %s", quality['issues'])
        image_bytes = auto_enhance(image_bytes, quality['issues'])

    # Step 1: PaddleOCR + regex — fast path (4-7s)
    try:
        result = await _ocr_paddleocr(image_bytes)
        if result.amount is not None and result.confidence >= 70.0:
            return result
        logger.warning("PaddleOCR low confidence (%.1f) or no amount, trying LLM", result.confidence)
    except Exception as e:
        logger.warning("PaddleOCR failed: %s, trying hybrid", e)

    # Step 2: Hybrid (PaddleOCR text → LLM parsing) — slower but more accurate
    try:
        result = await _ocr_hybrid(image_bytes, media_type)
        if result.amount is not None:
            return result
        logger.warning("Hybrid returned no amount, trying next")
    except Exception as e:
        logger.warning("Hybrid failed: %s, trying next", e)

    # Step 3: Qwen vision
    try:
        result = await _ocr_qwen(image_bytes, media_type)
        if result.amount is not None:
            return result
    except Exception as e:
        logger.warning("Qwen vision failed: %s, trying next", e)

    # Step 4: DeepSeek-OCR (raw text + regex)
    try:
        result = await _ocr_deepseek(image_bytes, media_type)
        if result.amount is not None:
            return result
    except Exception as e:
        logger.warning("DeepSeek-OCR failed: %s, trying next", e)

    # Step 5: Tesseract as last resort
    return await _ocr_tesseract(image_bytes)


# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------

_METHOD_MAP = {
    OcrMethod.tesseract: lambda img, mt: _ocr_tesseract(img),
    OcrMethod.paddleocr: lambda img, mt: _ocr_paddleocr(img),
    OcrMethod.glm_ocr: _ocr_glm,
    OcrMethod.deepseek_ocr: _ocr_deepseek,
    OcrMethod.gemini: _ocr_gemini,
    OcrMethod.claude: _ocr_claude,
    OcrMethod.qwen: _ocr_qwen,
    OcrMethod.auto: _ocr_auto,
}


async def process_receipt(
    image_bytes: bytes,
    media_type: str,
    method: OcrMethod,
    default_currency: str | None = None,
) -> OcrReceiptResponse:
    handler = _METHOD_MAP[method]
    result = await handler(image_bytes, media_type)

    # Apply default_currency as fallback (from user's locale/geolocation)
    if result.currency is None and default_currency:
        result.currency = default_currency.upper()

    return result
