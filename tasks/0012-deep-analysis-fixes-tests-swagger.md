# Task: Глубокий анализ платформы — фиксы, тесты, Swagger
Date: 2026-03-01
Status: done

## Checklist

### Фаза 1: Исправление багов mobile ↔ backend
- [x] Баг 1: PUT → PATCH (3 файла)
- [x] Баг 2: UserProfileModel — name vs firstName/lastName (3 файла + settings_page)
- [x] Баг 3: DashboardModel — вложенная структура (currentMonth/previousMonth)
- [x] Баг 4: CategorySpendingModel — total/categoryColor вместо amount/color
- [x] Баг 5: Dashboard recentTransactions — DashboardTransactionModel с optional accountId
- [x] Баг 6: ScheduledPaymentModel — accountName из вложенного account объекта

### Фаза 2: Swagger (backend)
- [x] Установить зависимости (@nestjs/swagger, swagger-ui-express)
- [x] Настроить Swagger в main.ts
- [x] Добавить декораторы в контроллеры (12 файлов)
- [x] Настроить CLI plugin в nest-cli.json

### Фаза 3: Mobile тесты (15 файлов, 112 тестов)
- [x] Тесты моделей (5 файлов)
- [x] Тесты Bloc/Cubit (5 файлов)
- [x] Тесты Datasource (5 файлов)

### Verification
- [x] flutter analyze — 0 issues
- [x] flutter test — 112 тестов, все проходят
- [x] Swagger настроен (api/docs)
