# Task: Доработка OCR Receipt Scanning
Date: 2026-03-08
Status: in_progress

## Выполнено сегодня
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

## Checklist — осталось

### Mobile
- [ ] Превью изображения перед отправкой на OCR
- [ ] Выбор категории в форме подтверждения чека
- [ ] Страница истории сканов (ReceiptHistoryPage)
- [ ] Страница деталей отдельного скана
- [ ] Локализация строк UI
- [ ] Обработка ошибок загрузки аккаунтов (UI feedback)

### Backend
- [ ] Пагинация GET /receipts
- [ ] Endpoint удаления скана (DELETE /receipts/:id)
- [ ] Endpoint редактирования распознанных данных (PATCH /receipts/:id)
- [ ] Уведомление клиента о завершении OCR (через WebSocket/Events)
- [ ] Валидация confidence — предупреждение при низком качестве

### Verification
- [x] build backend (`cd backend && npm run build`)
- [x] build mobile (`cd mobile && flutter analyze`)
- [x] commit & push
