# Task: Логотип и полноценная светлая тема
Date: 2026-03-08
Status: in_progress

## Checklist

### Логотип
- [ ] Создать assets/ структуру
- [ ] Создать виджет логотипа (CustomPainter)
- [ ] Настроить flutter_launcher_icons
- [ ] Обновить splash_page с логотипом
- [ ] Обновить onboarding с логотипом

### Светлая тема — инфраструктура
- [ ] Создать AppColorsExtension (ThemeExtension)
- [ ] Зарегистрировать в dark и light темах
- [ ] Создать BuildContext extension для доступа

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
- [x] flutter analyze — 0 errors (117 info-level warnings, pre-existing)
- [ ] build & test on device
- [ ] commit & push
