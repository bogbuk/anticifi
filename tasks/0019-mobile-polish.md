# Task: Mobile Polish — Theme, Animations, Offline Mode
Date: 2026-03-05
Status: done

## Checklist

### 1. Dark/Light Theme Switching
- [x] app_colors.dart — добавить light цвета (AppColorsLight)
- [x] app_theme.dart — добавить lightTheme
- [x] theme_cubit.dart + state — управление темой
- [x] Сохранение выбора темы в SecureStorage
- [x] app.dart — MultiBlocProvider + themeMode
- [x] settings_page.dart — рабочий переключатель темы
- [x] injection.dart — регистрация ThemeCubit

### 2. Animations & Micro-interactions
- [x] pubspec.yaml — flutter_animate ^4.3.0
- [x] Анимации списков (staggered fade-in) — transactions, accounts
- [x] Анимации навигации (FadeSlideTransitionPage)
- [x] Анимации карточек dashboard (staggered sections)
- [x] Settings page animations (staggered sections)

### 3. Offline Mode (SQLite + Sync)
- [x] pubspec.yaml — sqflite, connectivity_plus, path
- [x] Local database service (LocalDatabase)
- [x] Offline-first repository pattern (accounts, transactions, budgets)
- [x] Sync service (queue + retry, server-wins)
- [x] Connectivity monitor (ConnectivityService)
- [x] Offline indicator UI (OfflineBanner)
- [x] Local datasources (transactions, accounts, budgets)
- [x] DI registration всех новых сервисов

### Verification
- [x] flutter analyze — No issues found
- [x] build
- [x] commit & push
