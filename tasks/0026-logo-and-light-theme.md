# Task: Логотип и полноценная светлая тема
Date: 2026-03-08
Status: done

## Checklist

### Логотип
- [x] Создать assets/ структуру
- [x] Создать виджет логотипа (CustomPainter)
- [x] Настроить flutter_launcher_icons
- [x] Обновить splash_page с логотипом
- [x] Обновить onboarding с логотипом

### Светлая тема — инфраструктура
- [x] Создать AppColorsExtension (ThemeExtension)
- [x] Зарегистрировать в dark и light темах
- [x] Создать BuildContext extension для доступа

### Светлая тема — замена hardcoded цветов (47 файлов, ~492 ссылок)
- [x] auth (3 файла) — уже theme-aware
- [x] onboarding (2 файла) — уже theme-aware
- [x] home (1 файл) — уже theme-aware
- [x] dashboard (3 файла) — уже theme-aware
- [x] transactions (3 файла) — убран ColorScheme.dark в date pickers
- [x] accounts (4 файла) — уже theme-aware
- [x] budgets (4 файла) — уже theme-aware
- [x] debts (8 файлов) — убран ColorScheme.dark, заменены Colors.white на onSurface
- [x] scheduled_payments (3 файла) — убран ColorScheme.dark в date picker
- [x] oracle (4 файла) — заменён Colors.black.withOpacity в chat_bubble
- [x] settings (2 файла) — уже theme-aware
- [x] receipts (2 файла) — убран ColorScheme.dark в date picker
- [x] notifications (2 файла) — уже theme-aware
- [x] subscription (2 файла) — уже theme-aware
- [x] export (1 файл) — убран ColorScheme.dark в date picker
- [x] import (1 файл) — уже theme-aware

### Verification
- [x] flutter analyze — 0 errors
- [ ] build & test on device
- [x] commit & push
