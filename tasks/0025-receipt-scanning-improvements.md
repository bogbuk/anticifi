# Task: Доработка OCR Receipt Scanning
Date: 2026-03-08
Status: done

## Выполнено ранее
- [x] iOS permissions (камера, фото) — краш при сканировании
- [x] Лимит сканов (5/день free, безлимит premium)
- [x] Парсинг snake_case ответов API
- [x] Таймаут загрузки 60с для OCR
- [x] Румынский язык OCR + парсер (Suma, Comerciant, MDL/RON)
- [x] Человекочитаемые ошибки в mobile
- [x] Цвета текста для light/dark theme (login, receipt form, date)
- [x] Фикс onboarding зависания
- [x] Traefik body size limit 15MB
- [x] Уменьшение размера фото для upload
- [x] Фикс бесконечной рекурсии CurrencyService (MDL)

## Выполнено 2026-03-09

### Backend
- [x] Пагинация GET /receipts (page, limit, status filter)
- [x] Endpoint редактирования (PATCH /receipts/:id) — merchant, amount, date, currency, items
- [x] Валидация confidence — предупреждение при <60%
- [x] WebSocket уведомление о завершении OCR (receipt:scanned event)

### Mobile
- [x] Превью изображения перед отправкой на OCR (Scan/Cancel кнопки)
- [x] Обработка ошибок загрузки аккаунтов (retry UI)
- [x] Страница деталей скана (статус, confidence, данные, товары)
- [x] Навигация из истории → детали скана
- [x] Полная локализация (12 языков)

### Verification
- [x] build backend
- [x] build mobile (flutter analyze — 0 errors)
- [x] commit & push
