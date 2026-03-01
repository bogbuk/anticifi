# Task: Post-MVP Roadmap
Date: 2026-03-01
Status: in_progress

## 1. Production-Readiness

### Testing
- [ ] E2E тесты backend (Jest + Supertest)
- [ ] E2E тесты mobile (Flutter integration tests)
- [ ] Unit тесты для сервисов и кубитов

### CI/CD
- [ ] GitHub Actions: lint, build, test
- [ ] Docker: контейнеризация backend (NestJS)
- [ ] Environment configs (staging / production)
- [ ] Docker Compose для full-stack (backend + frontend + ML + infra)

### Security & Performance
- [ ] Rate limiting (throttler)
- [ ] CORS настройка
- [ ] Helmet (security headers)
- [ ] Input sanitization
- [ ] Логирование (structured logs)

---

## 2. Новые фичи

### OCR Receipt Scanning
- [ ] Интеграция камеры (mobile)
- [ ] OCR сервис (Tesseract / Google Vision API)
- [ ] Парсинг чека → транзакция

### Бюджеты
- [ ] Backend: Budget модуль (CRUD, лимиты по категориям)
- [ ] Mobile: Budget UI (прогресс-бары, алерты при превышении)
- [ ] Нотификации при приближении к лимиту

### Мультивалютность
- [ ] Конвертация валют (API курсов)
- [ ] Мультивалютный дашборд
- [ ] Базовая валюта пользователя

### Экспорт данных
- [ ] PDF отчёты (месячные/годовые)
- [ ] Excel/CSV экспорт транзакций
- [ ] Email отправка отчётов

### Push-уведомления
- [ ] Firebase FCM интеграция
- [ ] Backend: push notification service
- [ ] Mobile: permission flow + token registration

---

## 3. ML улучшения

- [ ] Увеличение датасета для Prophet (больше истории → точнее прогноз)
- [ ] ML-категоризация транзакций (auto-assign category)
- [ ] Anomaly detection (подозрительные траты)
- [ ] LLM интеграция (Claude/GPT) вместо keyword-based NLP
- [ ] Персонализированные финансовые советы

---

## 4. Mobile Polish

- [ ] Онбординг (first-time user flow, tutorial)
- [ ] Offline mode (SQLite local DB + sync)
- [ ] Биометрическая аутентификация (Face ID / Touch ID)
- [ ] Dark / Light theme switching
- [ ] Animations & micro-interactions
- [ ] App Store / Google Play публикация
- [ ] Deep linking

### Verification
- [ ] Все тесты проходят
- [ ] Build iOS + Android
- [ ] Commit & push
