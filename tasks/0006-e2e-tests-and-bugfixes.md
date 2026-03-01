# Task: E2E тесты + исправление багов в mobile datasources
Date: 2026-03-01
Status: done

## Checklist

### Backend E2E тесты
- [x] Создать `backend/test/api.e2e-spec.ts` — полный API flow (42 теста)
- [x] Auth: register → login → profile → refresh
- [x] Accounts: CRUD
- [x] Transactions: CRUD + pagination
- [x] Dashboard: проверка totalBalance, spendingByCategory
- [x] Categories: get all (9 defaults)
- [x] Scheduled Payments: CRUD + execute
- [x] Notifications: get all, unread count
- [x] Users: get/update profile
- [x] Health check

### Mobile datasource fixes
- [x] `accounts_remote_datasource.dart` — backend возвращает `[]` а не `{accounts: []}`
- [x] `scheduled_payments_remote_datasource.dart` — backend возвращает `{data: [], total, page}` а не `{scheduledPayments: []}`
- [x] `notifications_remote_datasource.dart` — backend возвращает `{data: [], total, page}` а не `{notifications: []}`
- [x] `auth_bloc.dart` — при наличии токена получать профиль через API

### Mobile unit тесты
- [x] Добавить `bloc_test`, `mocktail` в pubspec.yaml
- [x] `test/features/auth/data/models/user_model_test.dart` (5 тестов)
- [x] `test/features/accounts/data/models/account_model_test.dart` (5 тестов)
- [x] `test/features/transactions/data/models/transaction_model_test.dart` (6 тестов)
- [x] `test/features/auth/presentation/bloc/auth_bloc_test.dart` (9 тестов)
- [x] `test/features/accounts/presentation/bloc/accounts_cubit_test.dart` (5 тестов)

### Verification
- [x] `flutter analyze` — 0 issues
- [x] `flutter test --concurrency=1` — 30/30 passed
- [ ] `cd backend && npm run test:e2e` — требует PostgreSQL
- [ ] commit & push
