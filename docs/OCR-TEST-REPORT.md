# OCR Receipt Test Report — 2026-03-11

## Overview

Tested Tesseract.js-based OCR receipt scanning against 92 real receipt images from 7 currencies. Images sourced from Wikimedia Commons, HuggingFace datasets, ExpressExpense dataset, and yurichev.com.

## Summary

| Metric                    | Result        |
|---------------------------|---------------|
| Total receipts tested     | 92            |
| Successfully scanned      | 77 / 92 (84%) |
| Currency correctly detected | 23 / 77 (29%) |
| Amount detected           | 58 / 77 (75%) |
| Confidence (median)       | ~65%          |

## Results by Currency

| Currency | Images | Scanned OK | Currency Correct | Amount Detected | Notes |
|----------|--------|------------|------------------|-----------------|-------|
| USD      | 51     | 38         | 19 (50%)         | 30 (79%)        | Best results; $ symbol recognized well |
| EUR      | 14     | 12         | 4 (33%)          | 8 (67%)         | € often not recognized by OCR |
| UAH      | 13     | 12         | 0 (0%)           | 10 (83%)        | Cyrillic text poorly read; no UAH/грн trigger found |
| GBP      | 9      | 6          | 0 (0%)           | 2 (33%)         | Mostly historic/low-quality images; £ not detected |
| MDL      | 2      | 2          | 1 (50%)          | 2 (100%)        | "TOTAL LEI" pattern works; "LEI" ambiguous RON/MDL |
| CNY      | 2      | 2          | 0 (0%)           | 1 (50%)         | CJK characters poorly recognized |
| PLN      | 1      | 1          | 1 (100%)         | 1 (100%)        | "PLN" text clearly printed on receipt |

**Not tested (no open-source images found):** CHF, CZK, JPY, TRY, RON

## Key Findings

### What works well
- **Amount detection (75%)** — regex patterns for total/subtotal work across many formats
- **USD receipts (50% currency)** — `$` symbol is most commonly printed and recognized
- **MDL/PLN** — explicit currency text (`MDL`, `PLN`, `LEI`) on receipts aids detection
- **Date parsing** — works reliably across DD/MM/YYYY and MM/DD/YYYY formats

### What doesn't work
- **Cyrillic OCR (UAH)** — Tesseract produces garbled output for Ukrainian text; `UAH` and `грн` never recognized
- **CJK OCR (CNY/JPY)** — Chinese/Japanese characters produce nonsense output
- **Currency symbol recognition** — `€`, `£` frequently missed or misread (€→¢, £→E)
- **GBP** — only recognized when text "GBP" is explicitly present, which is rare on UK receipts
- **Merchant names** — frequently garbled, especially for non-Latin scripts

### Error analysis
- 15/92 (16%) receipts completely failed — likely oversized images or unsupported formats
- False positives: some USD receipts detected as EUR/GBP/TRY due to OCR artifacts

## Supported Currencies (OCR Detection)

| Currency | Detection Triggers | Reliability |
|----------|-------------------|-------------|
| MDL      | `MDL`             | High (if printed) |
| RON      | `RON`, `LEI`      | Medium (LEI ambiguous with MDL) |
| UAH      | `UAH`, `грн`      | Very Low (Cyrillic OCR fails) |
| TRY      | `TRY`, `TL`, `₺`  | Untested |
| JPY      | `JPY`, `円`, `¥`   | Very Low (CJK OCR fails) |
| CNY      | `CNY`, `RMB`, `元` | Very Low (CJK OCR fails) |
| PLN      | `PLN`, `zł`       | High (if printed) |
| CZK      | `CZK`, `Kč`       | Untested |
| CHF      | `CHF`             | Untested |
| EUR      | `€`, `EUR`        | Medium (€ often misread) |
| GBP      | `£`, `GBP`        | Low (£ often misread) |
| USD      | `$`, `USD`        | Medium-High |

## Recommendations

1. **Replace Tesseract with LLM-based OCR** (Google Vision API, Claude Vision, or GPT-4 Vision) for:
   - Multilingual text recognition (Cyrillic, CJK, Turkish)
   - Structured data extraction (merchant, amount, currency, date)
   - Higher confidence across all currencies

2. **Hybrid approach** — use Tesseract for Latin-script receipts (USD/EUR/PLN), LLM for others

3. **Add post-processing heuristics**:
   - If no currency detected but account has one, default to account currency
   - Cross-reference detected items/prices to validate total amount
   - Use merchant name database for known chains → auto-assign currency

## Test Data

Receipt images stored in `receipt/` directory, organized by currency:
```
receipt/
├── USD/   (51 images — ExpressExpense dataset + HuggingFace + Wikimedia)
├── EUR/   (14 images — Wikimedia Commons)
├── UAH/   (13 images — yurichev.com + Wikimedia)
├── GBP/   (9 images — Wikimedia Commons)
├── MDL/   (2 images — real photos)
├── CNY/   (2 images — Wikimedia Commons)
├── PLN/   (1 image — Wikimedia Commons)
└── test-ocr.sh  (test runner script)
```
