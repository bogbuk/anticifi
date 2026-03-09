# Task: Мультиязычность (i18n/l10n) — 12 языков
Date: 2026-03-08
Status: done

## Checklist

### Инфраструктура
- [x] l10n.yaml — конфигурация генерации
- [x] pubspec.yaml — flutter_localizations, intl ^0.20.2, generate: true
- [x] lib/core/locale/locale_cubit.dart — Cubit для управления локалью
- [x] lib/core/locale/locale_state.dart — состояние (Equatable)
- [x] injection.dart — регистрация LocaleCubit
- [x] app.dart — localizationsDelegates, supportedLocales, locale binding

### ARB файлы (~220 ключей каждый)
- [x] app_en.arb — English (template)
- [x] app_ru.arb — Русский
- [x] app_ro.arb — Română
- [x] app_es.arb — Español
- [x] app_fr.arb — Français
- [x] app_de.arb — Deutsch
- [x] app_uk.arb — Українська
- [x] app_pt.arb — Português
- [x] app_it.arb — Italiano
- [x] app_tr.arb — Türkçe
- [x] app_zh.arb — 中文
- [x] app_ja.arb — 日本語

### Settings Page
- [x] Все строки заменены на l10n ключи
- [x] Language picker с выбором 12 языков
- [x] Сохранение языка в SecureStorage
- [x] Theme/Currency/Delete/Logout dialogs локализованы

### Остальные страницы
- [x] Auth pages (login, register, onboarding)
- [x] Dashboard page + widgets (balance_card, spending_chart, income_expense_row)
- [x] Transactions pages + widgets
- [x] Accounts pages + widgets
- [x] Budgets pages + widgets
- [x] Debts pages + widgets
- [x] Oracle page
- [x] Notifications page
- [x] Subscription/Paywall page
- [x] Import/Export pages
- [x] Receipt scan page + history
- [x] Scheduled payments pages + widgets
- [x] Offline banner

### Verification
- [x] flutter analyze — 0 errors
- [ ] build & test on device
- [x] commit & push
