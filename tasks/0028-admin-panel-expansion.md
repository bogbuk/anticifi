# Task: Admin Panel — полное расширение (Фазы 1-4)
Date: 2026-03-10
Status: done

## Checklist

### Фаза 1: Dashboard + UserDetail + System
- [x] Dashboard — 8 метрик-карточек (users, premium, active, transactions, accounts, budgets, debts, receipts)
- [x] Dashboard — графики recharts (User Growth 30d, Transaction Volume 30d)
- [x] UserDetail — вкладки: Transactions, Accounts, Budgets, Debts
- [x] UserDetail — расширенная статистика (budgetsCount, debtsCount)
- [x] System page — health check API, информация о среде

### Фаза 2: Core Admin
- [x] GET /admin/transactions — глобальный просмотр транзакций с фильтрами
- [x] GET /admin/users/:id/transactions — транзакции пользователя
- [x] GET /admin/users/:id/accounts — аккаунты пользователя
- [x] GET /admin/users/:id/budgets — бюджеты пользователя
- [x] GET /admin/users/:id/debts — долги пользователя
- [x] GET /admin/subscriptions — все подписки
- [x] GET /admin/receipts — все чеки (OCR)
- [x] POST /admin/notifications/broadcast — массовая рассылка
- [x] Transactions page (фронтенд)
- [x] Subscriptions page (фронтенд)
- [x] Notifications page (фронтенд)

### Фаза 3: Аналитика
- [x] GET /admin/analytics/user-growth — рост пользователей
- [x] GET /admin/analytics/transactions — объём транзакций
- [x] GET /admin/analytics/revenue — premium подписки
- [x] GET /admin/analytics/retention — DAU/WAU/MAU
- [x] GET /admin/analytics/categories — разбивка по категориям
- [x] GET /admin/analytics/subscriptions — разбивка подписок
- [x] Analytics page — графики (bar, line, pie), retention cards

### Фаза 4: Advanced
- [x] AuditLog model (audit_logs table)
- [x] AuditLogService (log + getLogs)
- [x] GET /admin/audit-logs — логи действий админов
- [x] Receipts page — OCR мониторинг (статус, confidence, parsed data)
- [x] AuditLogs page (фронтенд)

### Verification
- [x] backend build
- [x] frontend build
