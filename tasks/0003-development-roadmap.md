# AnticiFi — Development Roadmap
Date: 2026-02-28
Status: in_progress

## Фазы разработки

### Phase 1: Infrastructure & Auth (Sprint 1-2) — СЕЙЧАС
Параллельные потоки:
- [ ] **Infra**: Docker Compose (PostgreSQL 16, Redis 7, NATS 2.x, Nginx)
- [ ] **Backend Core**: NestJS monorepo, API Gateway, конфиг, логирование
- [ ] **Database**: Sequelize модели, миграции (Users, Accounts)
- [ ] **Auth Module**: Register, Login, JWT RS256, Refresh tokens
- [ ] **Mobile Core**: Flutter проект, Clean Architecture структура, DI, Router
- [ ] **Mobile Auth**: Login/Register экраны, AuthBloc, Secure Storage

### Phase 2: Accounts & Transactions (Sprint 3-4)
- [ ] Accounts CRUD (backend + mobile)
- [ ] Transactions CRUD с пагинацией
- [ ] Категории (системные + пользовательские)
- [ ] CSV Import Service + парсер
- [ ] NATS pub/sub между сервисами
- [ ] Bull Queue для фоновых задач

### Phase 3: Dashboard & Real-time (Sprint 5)
- [ ] Dashboard API (агрегированные данные)
- [ ] Dashboard UI (Flutter)
- [ ] Socket.IO real-time обновления
- [ ] Balance calculation service
- [ ] Transaction charts (fl_chart)

### Phase 4: Scheduled Payments (Sprint 6)
- [ ] ScheduledPayments CRUD
- [ ] Cron job для автоматического выполнения
- [ ] UI для создания/редактирования

### Phase 5: Prediction Engine (Sprint 7)
- [ ] Python ML Service (FastAPI)
- [ ] Prophet time-series model
- [ ] Rule Engine для запланированных платежей
- [ ] Prediction API (NestJS wrapper)
- [ ] Oracle UI — чат-интерфейс
- [ ] Predictive Alerts

### Phase 6: Polish & Launch (Sprint 8)
- [ ] Notification Service (FCM + email)
- [ ] Offline sync (Isar)
- [ ] Settings screens
- [ ] E2E tests
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] App Store / Play Store submission

## Технологии
- **Backend**: NestJS, PostgreSQL 16, Sequelize, Redis 7, NATS 2.x, Bull
- **Mobile**: Flutter 3.x, Dart, BLoC, Isar, GoRouter
- **ML**: Python 3.11, FastAPI, Prophet
- **Infra**: Docker Compose, Nginx, GitHub Actions
