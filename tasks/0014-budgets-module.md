# Task: Budgets Module — Backend + Mobile
Date: 2026-03-02
Status: done

## Checklist

### Backend
- [x] Добавить BUDGET_ALERT в NotificationType enum
- [x] Создать budget.model.ts
- [x] Создать 3 DTO файла (create, update, query)
- [x] Создать budgets.service.ts
- [x] Создать budgets.cron.ts
- [x] Создать budgets.controller.ts
- [x] Создать budgets.module.ts
- [x] Зарегистрировать BudgetsModule в app.module.ts

### Mobile
- [x] Создать budget_entity.dart + abstract budgets_repository.dart
- [x] Создать budget_model.dart + budgets_remote_datasource.dart + budgets_repository_impl.dart
- [x] Создать budgets_cubit.dart + budgets_state.dart
- [x] Создать budget_progress_bar.dart + budget_card.dart
- [x] Создать budgets_page.dart + budget_form_page.dart
- [x] Добавить API endpoints
- [x] Обновить DI, router, settings

### Verification
- [x] build (`npm run build` — 0 ошибок)
- [x] flutter analyze — No issues found!
- [x] commit & push (`bdf4936`)
