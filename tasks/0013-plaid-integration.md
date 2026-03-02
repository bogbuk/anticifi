# Task: Интеграция Plaid для автоматического подключения банковских счетов
Date: 2026-03-02
Status: done

## Checklist — Backend
- [x] npm install plaid
- [x] Создать plaid-item.model.ts
- [x] Изменить account.model.ts (4 поля + enum)
- [x] Создать plaid-encryption.service.ts
- [x] Создать 3 DTO файла
- [x] Создать plaid.service.ts
- [x] Создать plaid-sync.service.ts
- [x] Создать plaid.controller.ts
- [x] Создать plaid.module.ts
- [x] Зарегистрировать PlaidModule в app.module.ts
- [x] Добавить env vars в .env.example

## Checklist — Mobile
- [x] plaid_flutter в pubspec.yaml
- [x] Расширить AccountEntity + AccountModel
- [x] Создать PlaidRemoteDataSource
- [x] Добавить API endpoints
- [x] Добавить Plaid states
- [x] Расширить AccountsCubit
- [x] Создать LinkBankPage
- [x] Обновить AccountsPage, маршрут, DI

### Verification
- [x] build backend (`npm run build` — 0 errors)
- [x] flutter analyze — 0 issues
