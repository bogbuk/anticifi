# Спецификация мобильного приложения AnticiFi

[← Назад к README](./README.md)

---

## Содержание

1. [Обзор](#1-обзор)
2. [Архитектура приложения](#2-архитектура-приложения)
   - 2.1. [Принципы Clean Architecture](#21-принципы-clean-architecture)
   - 2.2. [Структура директорий](#22-структура-директорий)
   - 2.3. [Поток данных](#23-поток-данных)
3. [Навигация и экраны](#3-навигация-и-экраны)
   - 3.1. [Дерево маршрутов GoRouter](#31-дерево-маршрутов-gorouter)
   - 3.2. [Shell-навигация (нижний таббар)](#32-shell-навигация-нижний-таббар)
   - 3.3. [Deep linking](#33-deep-linking)
4. [State Management (BLoC / Cubit)](#4-state-management-bloc--cubit)
   - 4.1. [AuthBloc](#41-authbloc)
   - 4.2. [DashboardCubit](#42-dashboardcubit)
   - 4.3. [TransactionListBloc](#43-transactionlistbloc)
   - 4.4. [AccountsCubit](#44-accountscubit)
   - 4.5. [OracleCubit](#45-oraclecubit)
   - 4.6. [ImportBloc](#46-importbloc)
   - 4.7. [NotificationCubit](#47-notificationcubit)
   - 4.8. [SettingsCubit](#48-settingscubit)
5. [Локальное хранилище (Isar)](#5-локальное-хранилище-isar)
   - 5.1. [Коллекции](#51-коллекции)
   - 5.2. [Стратегия синхронизации](#52-стратегия-синхронизации)
6. [OCR-модуль (Google ML Kit)](#6-ocr-модуль-google-ml-kit)
   - 6.1. [Поток обработки чека](#61-поток-обработки-чека)
   - 6.2. [Парсинг данных](#62-парсинг-данных)
7. [Push-уведомления](#7-push-уведомления)
   - 7.1. [Firebase Cloud Messaging](#71-firebase-cloud-messaging)
   - 7.2. [Типы уведомлений](#72-типы-уведомлений)
   - 7.3. [Локальные уведомления-напоминания](#73-локальные-уведомления-напоминания)
8. [Офлайн-режим](#8-офлайн-режим)
   - 8.1. [Offline-first стратегия](#81-offline-first-стратегия)
   - 8.2. [Разрешение конфликтов](#82-разрешение-конфликтов)
9. [Безопасность и биометрия](#9-безопасность-и-биометрия)
10. [UI/UX Гайдлайны](#10-uiux-гайдлайны)
    - 10.1. [Design System](#101-design-system)
    - 10.2. [Состояния загрузки](#102-состояния-загрузки)
    - 10.3. [Анимации и обратная связь](#103-анимации-и-обратная-связь)
11. [Ключевые пакеты](#11-ключевые-пакеты)
12. [Инъекция зависимостей (GetIt + Injectable)](#12-инъекция-зависимостей-getit--injectable)
13. [Обработка ошибок](#13-обработка-ошибок)
14. [Связанные документы](#связанные-документы)

---

## 1. Обзор

Мобильное приложение AnticiFi разработано на **Flutter 3.x** с использованием языка **Dart** и является основной точкой взаимодействия пользователя с предиктивным AI-ассистентом. Приложение работает на **iOS** и **Android** из единой кодовой базы.

### Ключевые технические решения

| Аспект | Решение | Обоснование |
|---|---|---|
| Фреймворк | Flutter 3.x | Единая кодовая база для iOS и Android, высокая производительность, богатая экосистема |
| Архитектура | Clean Architecture + BLoC | Чёткое разделение ответственностей, тестируемость, предсказуемый поток состояния |
| Навигация | GoRouter | Декларативная маршрутизация, deep linking, Shell-маршруты для табов |
| Локальная БД | Isar | Высокая производительность, нативная поддержка Dart, офлайн-первый подход |
| DI-контейнер | GetIt + Injectable | Compile-time DI, минимальный boilerplate |
| Сетевой слой | Dio | Мощная система интерцепторов, работа с multipart, обработка ошибок |
| OCR | Google ML Kit | Локальная обработка изображений, нет передачи данных на внешние серверы |

### Требования к платформам

- **iOS:** 14.0+
- **Android:** API 24+ (Android 7.0+)
- **Flutter:** 3.19+
- **Dart SDK:** 3.3+

---

## 2. Архитектура приложения

### 2.1. Принципы Clean Architecture

Приложение следует принципам Clean Architecture Роберта Мартина, разделяя код на три независимых слоя с чётко определёнными направлениями зависимостей.

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│         (Pages, Widgets, BLoC/Cubit, Routes)            │
│                                                         │
│  Знает о: Domain Layer                                  │
│  Не знает о: Data Layer, внешних фреймворках            │
└─────────────────────┬───────────────────────────────────┘
                      │ зависит от
                      ▼
┌─────────────────────────────────────────────────────────┐
│                   Domain Layer                          │
│          (Entities, Use Cases, Repo Interfaces)         │
│                                                         │
│  Знает о: ничём снаружи (чистый Dart)                  │
│  Не знает о: Flutter, Dio, Isar, любых фреймворках      │
└─────────────────────┬───────────────────────────────────┘
                      │ зависит от (через интерфейсы)
                      ▼
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                           │
│     (Models, DataSources, Repository Implementations)   │
│                                                         │
│  Знает о: Domain Layer (реализует интерфейсы)          │
│  Использует: Dio, Isar, ML Kit, FCM                    │
└─────────────────────────────────────────────────────────┘
```

**Ключевой принцип**: зависимости всегда направлены внутрь — от внешних слоёв к внутренним. Domain Layer — ядро приложения — не зависит ни от чего внешнего, что делает бизнес-логику независимой от фреймворков и легко тестируемой.

### 2.2. Структура директорий

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       — базовые URL, таймауты
│   │   ├── app_constants.dart       — лимиты, конфигурация
│   │   └── storage_keys.dart        — ключи SecureStorage
│   ├── errors/
│   │   ├── exceptions.dart          — типизированные исключения
│   │   └── failures.dart            — Either<Failure, T> обёртки
│   ├── network/
│   │   ├── dio_client.dart          — настройка Dio + базовый URL
│   │   ├── auth_interceptor.dart    — JWT-токены, auto-refresh
│   │   ├── error_interceptor.dart   — обработка HTTP-ошибок
│   │   └── connectivity_service.dart — мониторинг сети
│   ├── theme/
│   │   ├── app_theme.dart           — ThemeData light/dark
│   │   ├── app_colors.dart          — цветовые константы
│   │   ├── app_text_styles.dart     — типографика
│   │   └── app_dimensions.dart      — отступы, радиусы
│   └── utils/
│       ├── date_utils.dart          — форматирование дат
│       ├── currency_utils.dart      — форматирование сумм
│       └── validators.dart          — валидация форм
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── isar_service.dart    — инициализация Isar
│   │   │   ├── user_local_ds.dart
│   │   │   ├── account_local_ds.dart
│   │   │   ├── transaction_local_ds.dart
│   │   │   ├── prediction_local_ds.dart
│   │   │   └── pending_sync_ds.dart — очередь офлайн-операций
│   │   └── remote/
│   │       ├── auth_remote_ds.dart
│   │       ├── account_remote_ds.dart
│   │       ├── transaction_remote_ds.dart
│   │       ├── prediction_remote_ds.dart
│   │       └── import_remote_ds.dart
│   ├── models/
│   │   ├── user_model.dart          — @JsonSerializable
│   │   ├── account_model.dart
│   │   ├── transaction_model.dart
│   │   ├── prediction_model.dart
│   │   └── category_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── account_repository_impl.dart
│       ├── transaction_repository_impl.dart
│       └── prediction_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── account.dart
│   │   ├── transaction.dart
│   │   ├── prediction.dart
│   │   └── scheduled_payment.dart
│   ├── repositories/
│   │   ├── auth_repository.dart     — abstract interface
│   │   ├── account_repository.dart
│   │   ├── transaction_repository.dart
│   │   └── prediction_repository.dart
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── register_usecase.dart
│       │   └── refresh_token_usecase.dart
│       ├── transactions/
│       │   ├── get_transactions_usecase.dart
│       │   ├── create_transaction_usecase.dart
│       │   └── import_csv_usecase.dart
│       ├── predictions/
│       │   ├── get_prediction_usecase.dart
│       │   └── ask_oracle_usecase.dart
│       └── accounts/
│           ├── get_accounts_usecase.dart
│           └── create_account_usecase.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_cubit.dart
│   │   ├── transactions/
│   │   │   ├── transaction_list_bloc.dart
│   │   │   ├── transaction_list_event.dart
│   │   │   └── transaction_list_state.dart
│   │   ├── accounts/
│   │   │   └── accounts_cubit.dart
│   │   ├── oracle/
│   │   │   └── oracle_cubit.dart
│   │   ├── import/
│   │   │   ├── import_bloc.dart
│   │   │   ├── import_event.dart
│   │   │   └── import_state.dart
│   │   ├── notifications/
│   │   │   └── notification_cubit.dart
│   │   └── settings/
│   │       └── settings_cubit.dart
│   ├── pages/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   └── forgot_password_page.dart
│   │   ├── dashboard/
│   │   ├── transactions/
│   │   ├── oracle/
│   │   ├── accounts/
│   │   ├── import/
│   │   ├── notifications/
│   │   └── settings/
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── loading_skeleton.dart
│   │   │   └── offline_banner.dart
│   │   ├── charts/
│   │   │   ├── balance_timeline_chart.dart
│   │   │   └── spending_pie_chart.dart
│   │   └── transaction/
│   │       ├── transaction_tile.dart
│   │       └── transaction_filter_bar.dart
│   └── routes/
│       ├── app_router.dart          — GoRouter configuration
│       └── route_names.dart         — константы маршрутов
│
└── injection_container.dart         — GetIt DI setup
```

### 2.3. Поток данных

```
UI Event (tap, scroll, input)
         │
         ▼
  BLoC / Cubit
  add(Event) / call method
         │
         ▼
    Use Case
  (domain logic)
         │
         ▼
   Repository Interface
  (domain contract)
         │
         ▼
  Repository Implementation
  (data layer)
     /        \
    /          \
   ▼            ▼
Remote DS    Local DS
(Dio/API)   (Isar DB)
         │
         │ Either<Failure, Entity>
         ▼
  BLoC emits new State
         │
         ▼
  Widget rebuilds via BlocBuilder
```

Все операции репозитория возвращают `Either<Failure, T>` (dartz) — явное разделение ошибочного и успешного путей без исключений в бизнес-логике.

---

## 3. Навигация и экраны

### 3.1. Дерево маршрутов GoRouter

```
/splash                         — SplashPage
  └─ (auto redirect)
     ├─ /onboarding             — OnboardingPage (3 слайда, только при первом запуске)
     ├─ /auth/login             — LoginPage
     ├─ /auth/register          — RegisterPage
     ├─ /auth/forgot-password   — ForgotPasswordPage
     └─ /home                   — ShellRoute (TabNavigator)
          ├─ /home/dashboard     — DashboardPage [TAB 1]
          ├─ /home/transactions  — TransactionListPage [TAB 2]
          ├─ /home/oracle        — OraclePage [TAB 3]
          └─ /home/settings      — SettingsPage [TAB 4]

/accounts                       — AccountListPage
/accounts/:id                   — AccountDetailPage
/accounts/:id/transactions      — AccountTransactionsPage

/transactions/:id               — TransactionDetailPage

/import/csv                     — CsvImportPage
/import/ocr                     — OcrCameraPage → OcrConfirmPage

/oracle/ask                     — OracleAskPage (natural language query)
/predictions/:accountId         — PredictionTimelinePage

/scheduled-payments             — ScheduledPaymentListPage
/scheduled-payments/create      — CreateScheduledPaymentPage
/scheduled-payments/:id/edit    — EditScheduledPaymentPage

/notifications                  — NotificationCenterPage

/settings/profile               — ProfileEditPage
/settings/categories            — CategoryManagementPage
/settings/export                — DataExportPage
/settings/security              — SecuritySettingsPage
```

### 3.2. Shell-навигация (нижний таббар)

Нижний таббар реализован через `ShellRoute` в GoRouter. Это гарантирует, что каждая вкладка имеет собственный навигационный стек и сохраняет состояние при переключении между табами.

```dart
final _router = GoRouter(
  initialLocation: '/splash',
  redirect: _authGuard,
  routes: [
    GoRoute(path: '/splash', builder: (ctx, state) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (ctx, state) => const OnboardingPage()),
    // Auth routes ...
    ShellRoute(
      builder: (ctx, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home/dashboard', builder: (ctx, state) => const DashboardPage()),
        GoRoute(path: '/home/transactions', builder: (ctx, state) => const TransactionListPage()),
        GoRoute(path: '/home/oracle', builder: (ctx, state) => const OraclePage()),
        GoRoute(path: '/home/settings', builder: (ctx, state) => const SettingsPage()),
      ],
    ),
    // Feature routes ...
  ],
);
```

**Guard-функция `_authGuard`** выполняется на каждый переход маршрута и перенаправляет неаутентифицированных пользователей на `/auth/login`, а аутентифицированных — с экрана входа на `/home/dashboard`.

### 3.3. Deep linking

GoRouter поддерживает deep linking "из коробки". Примеры поддерживаемых ссылок:

| Ссылка | Результат |
|---|---|
| `anticifi://home/dashboard` | Открыть главный дашборд |
| `anticifi://notifications` | Открыть центр уведомлений |
| `anticifi://predictions/acc_123` | Открыть прогноз для счёта |
| `anticifi://scheduled-payments` | Открыть список регулярных платежей |

Конфигурация deep link добавляется в `AndroidManifest.xml` (Intent Filter) и `Info.plist` (CFBundleURLSchemes).

---

## 4. State Management (BLoC / Cubit)

Правило выбора между BLoC и Cubit: если управление состоянием требует обработки потока событий с возможными побочными эффектами (пагинация, фильтрация) — используется **BLoC**. Если состояние обновляется вызовом методов напрямую — используется **Cubit** (меньше boilerplate).

### 4.1. AuthBloc

Управляет жизненным циклом сессии пользователя.

```dart
// Events
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}
class RegisterRequested extends AuthEvent { /* поля регистрации */ }
class LogoutRequested extends AuthEvent {}
class TokenRefreshRequested extends AuthEvent {}
class BiometricAuthRequested extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
}
```

**Ответственности:**
- Вход по email/паролю и биометрии
- Регистрация нового пользователя
- Выход из аккаунта (очистка токенов и Isar)
- Автоматическое обновление JWT-токена через `auth_interceptor.dart`
- Персистентность сессии через `flutter_secure_storage`

### 4.2. DashboardCubit

Оркестрирует загрузку данных главного экрана — совокупный баланс, ближайшие события, краткий прогноз.

```dart
// States
abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final List<Account> accounts;
  final double totalBalance;
  final List<Transaction> recentTransactions;
  final PredictionSummary prediction;   // прогноз на 14/90 дней
  final List<ScheduledPayment> upcoming; // платежи на 7 дней
}
class DashboardError extends DashboardState {
  final String message;
}
```

**Поток загрузки:**
1. Сразу отображает данные из Isar (оптимистичный UI)
2. Параллельно запрашивает свежие данные с сервера
3. После получения ответа обновляет Isar и перезагружает состояние

### 4.3. TransactionListBloc

Управляет пагинированным, фильтруемым и поискуемым списком транзакций.

```dart
// Events
abstract class TransactionListEvent {}
class LoadTransactions extends TransactionListEvent {}
class LoadMore extends TransactionListEvent {}
class FilterByCategory extends TransactionListEvent {
  final String? categoryId;
}
class FilterByDate extends TransactionListEvent {
  final DateTime? from;
  final DateTime? to;
}
class SearchTransactions extends TransactionListEvent {
  final String query;
}
class RefreshTransactions extends TransactionListEvent {}

// States
abstract class TransactionListState {}
class TransactionInitial extends TransactionListState {}
class TransactionLoading extends TransactionListState {}
class TransactionLoaded extends TransactionListState {
  final List<Transaction> transactions;
  final bool hasMore;          // есть ли следующая страница
  final TransactionFilters filters;
  final bool isLoadingMore;    // подгрузка следующей страницы
}
class TransactionError extends TransactionListState {
  final String message;
}
```

**Пагинация:** курсорная (по `lastId`), размер страницы — 20 транзакций. При достижении конца списка виджет отправляет событие `LoadMore`, BLoC добавляет новые транзакции к существующему списку.

### 4.4. AccountsCubit

Управляет списком счетов пользователя — CRUD-операции.

```dart
abstract class AccountsState {}
class AccountsInitial extends AccountsState {}
class AccountsLoading extends AccountsState {}
class AccountsLoaded extends AccountsState {
  final List<Account> accounts;
  final double totalBalance;
}
class AccountsError extends AccountsState {
  final String message;
}
```

Методы Cubit: `loadAccounts()`, `createAccount(AccountInput)`, `updateAccount(id, AccountInput)`, `deleteAccount(id)`, `refreshBalances()`.

### 4.5. OracleCubit

Управляет взаимодействием с предиктивным движком Oracle — как диалоговыми запросами, так и временной шкалой прогноза.

```dart
abstract class OracleState {}
class OracleIdle extends OracleState {}
class OracleThinking extends OracleState {}  // анимация "думает..."
class OracleAnswered extends OracleState {
  final String question;
  final OracleAnswer answer;  // текст + прогноз + confidence
  final List<OracleMessage> history;
}
class OraclePredictionLoaded extends OracleState {
  final List<PredictionPoint> timeline;  // кривая баланса
  final List<ScheduledPayment> markers;  // маркеры событий
  final DateTime? riskDate;             // первая дата риска
}
class OracleError extends OracleState {
  final String message;
}
```

Методы: `askQuestion(String query)`, `loadPredictionTimeline(accountId, days)`, `clearHistory()`.

### 4.6. ImportBloc

Управляет многоэтапным флоу импорта данных — CSV и OCR. Каждый этап — отдельный стейт.

```dart
// Events
class StartCsvImport extends ImportEvent { final File file; }
class StartOcrCapture extends ImportEvent {}
class OcrImageCaptured extends ImportEvent { final File image; }
class ConfirmImportData extends ImportEvent { final ImportPreview preview; }
class CancelImport extends ImportEvent {}

// States
class ImportIdle extends ImportState {}
class ImportParsingFile extends ImportState {}       // парсинг CSV
class ImportPreviewReady extends ImportState {       // предпросмотр данных
  final ImportPreview preview;                       // строки для подтверждения
  final List<ImportConflict> conflicts;              // дубликаты
}
class ImportOcrProcessing extends ImportState {}     // ML Kit работает
class ImportOcrResult extends ImportState {          // данные из чека
  final OcrExtractedData data;
  final bool requiresConfirmation;
}
class ImportUploading extends ImportState {
  final double progress;                             // 0.0 – 1.0
}
class ImportSuccess extends ImportState {
  final int transactionsImported;
}
class ImportError extends ImportState {
  final String message;
}
```

### 4.7. NotificationCubit

Управляет списком уведомлений и их состоянием прочитанности.

```dart
abstract class NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
}
class NotificationError extends NotificationState {}
```

Методы: `loadNotifications()`, `markAsRead(id)`, `markAllAsRead()`, `deleteNotification(id)`.

### 4.8. SettingsCubit

Управляет пользовательскими настройками: профиль, тема, уведомления, биометрия.

```dart
abstract class SettingsState {}
class SettingsLoaded extends SettingsState {
  final UserProfile profile;
  final AppThemeMode themeMode;        // light / dark / system
  final NotificationPreferences notifPrefs;
  final bool biometricEnabled;
  final String currency;               // USD, RUB, EUR
}
```

Методы: `updateProfile(...)`, `toggleTheme(mode)`, `setBiometric(enabled)`, `updateNotificationPrefs(...)`, `setCurrency(code)`.

---

## 5. Локальное хранилище (Isar)

Isar — встраиваемая NoSQL база данных с нативной поддержкой Dart, скомпилированная в нативный код для максимальной производительности. Работает синхронно на изолированном потоке.

### 5.1. Коллекции

#### UserLocal

```dart
@collection
class UserLocal {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String userId;
  late String email;
  late String name;
  String? avatarUrl;
  late String currency;
  late DateTime cachedAt;
}
```

#### AccountLocal

```dart
@collection
class AccountLocal {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String accountId;
  late String name;
  late double balance;
  late String currency;
  late String type;        // checking, savings, cash
  late DateTime updatedAt;
}
```

#### TransactionLocal

```dart
@collection
class TransactionLocal {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String transactionId;
  late String accountId;
  late double amount;
  late String type;        // income, expense
  late String categoryId;
  String? description;
  late DateTime date;
  late DateTime cachedAt;

  // Индексы для быстрой фильтрации
  @Index()
  late String accountIdIndex;
  @Index()
  late DateTime dateIndex;
}
```

Кэшируются транзакции за последние **30 дней**. Более старые данные запрашиваются с сервера по требованию.

#### PredictionLocal

```dart
@collection
class PredictionLocal {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String accountId;
  late List<double> balancePoints;    // прогнозные значения по дням
  late DateTime startDate;
  late DateTime endDate;
  late double confidenceScore;
  late DateTime generatedAt;
  late DateTime expiresAt;            // TTL кэша прогноза
}
```

#### CategoryLocal

```dart
@collection
class CategoryLocal {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String categoryId;
  late String name;
  late String icon;
  late String color;
  late bool isDefault;
  late DateTime cachedAt;
}
```

#### PendingSync

Очередь операций, созданных офлайн, ожидающих синхронизации с сервером.

```dart
@collection
class PendingSync {
  Id id = Isar.autoIncrement;
  late String operationType;    // CREATE_TRANSACTION, UPDATE_ACCOUNT, ...
  late String payload;          // JSON-строка тела запроса
  late String endpoint;         // /transactions, /accounts, ...
  late String httpMethod;       // POST, PUT, DELETE
  late DateTime createdAt;
  late int retryCount;
  String? lastError;
}
```

### 5.2. Стратегия синхронизации

```
Запуск приложения
       │
       ▼
Загрузить данные из Isar → показать UI немедленно
       │
       │ (параллельно в фоне)
       ▼
Запрос к API (свежие данные)
       │
       ├─ Успех → обновить Isar → emit новый State
       └─ Ошибка сети → показать "Offline mode" баннер
                        → отработать из кэша Isar

Фоновая синхронизация (каждые 5 минут, только при наличии сети)
       │
       ├─ Проверить PendingSync
       ├─ Отправить накопленные операции на сервер
       ├─ При успехе → удалить из PendingSync
       └─ При ошибке → retryCount++, повторить позже

Запись офлайн (нет сети)
       │
       ├─ Применить изменение в Isar немедленно (optimistic)
       └─ Добавить запись в PendingSync
```

---

## 6. OCR-модуль (Google ML Kit)

OCR-модуль работает **полностью локально** — изображение не покидает устройство. Это критично для финансового приложения, где данные чеков могут содержать чувствительную информацию.

### 6.1. Поток обработки чека

```
Пользователь нажимает "Сканировать чек"
         │
         ▼
OcrCameraPage (camera_awesome пакет)
  - Предпросмотр с рамкой-гайдом для чека
  - Подсказка: "Наведите камеру на чек"
         │
         │ Снимок
         ▼
ImportBloc: OcrImageCaptured(file)
         │
         ▼
OcrProcessingService.processImage(file)
  1. Инициализация TextRecognizer (ML Kit)
  2. InputImage.fromFile(file)
  3. recognizer.processImage(inputImage)
  4. Получение RecognizedText (блоки, строки)
         │
         ▼
ReceiptParser.extract(recognizedText)
  - Парсинг суммы (регулярные выражения)
  - Парсинг даты
  - Парсинг названия магазина
         │
         ▼
OcrConfirmPage (ImportOcrResult state)
  - Редактируемые поля с предзаполненными данными
  - Кнопка "Подтвердить" / "Отмена"
         │
         │ ConfirmImportData
         ▼
ImportBloc: отправка на API /import/ocr
```

### 6.2. Парсинг данных

```dart
class ReceiptParser {
  static OcrExtractedData extract(RecognizedText text) {
    final allText = text.text;
    final lines = text.blocks
        .expand((b) => b.lines)
        .map((l) => l.text)
        .toList();

    return OcrExtractedData(
      amount: _extractAmount(allText),
      date: _extractDate(allText),
      merchantName: _extractMerchant(lines),
    );
  }

  // Паттерны: "ИТОГО 1 234,50", "TOTAL 45.00", "К ОПЛАТЕ: 890р"
  static double? _extractAmount(String text) { ... }

  // Паттерны: "25.03.2026", "2026-03-25", "25 марта 2026"
  static DateTime? _extractDate(String text) { ... }

  // Первые строки чека — обычно название торговой точки
  static String? _extractMerchant(List<String> lines) { ... }
}
```

**Поддерживаемые языки распознавания:** русский, английский.

**Обработка ошибок OCR:**
- Если сумма не распознана — поле пустое, пользователь вводит вручную
- Если дата не распознана — подставляется текущая дата
- Если качество изображения низкое — показывается подсказка переснять

---

## 7. Push-уведомления

### 7.1. Firebase Cloud Messaging

**Регистрация токена:**

```dart
class FcmService {
  Future<void> initialize() async {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    // Запрос разрешения (iOS)
    await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    // Получить токен и отправить на сервер
    final token = await messaging.getToken();
    if (token != null) await _api.registerFcmToken(token);

    // Обновление токена при ротации
    messaging.onTokenRefresh.listen(_api.registerFcmToken);
  }
}
```

**Обработка уведомлений:**

| Состояние приложения | Поведение |
|---|---|
| Foreground | Показывается in-app баннер (flutter_local_notifications) |
| Background | Системное уведомление, при нажатии — deep link в приложение |
| Terminated | Системное уведомление, при запуске — `getInitialMessage()` |

### 7.2. Типы уведомлений

| Тип | Триггер | Действие при нажатии |
|---|---|---|
| `LOW_BALANCE` | Прогнозируемый баланс < порога | Открыть `/home/dashboard` |
| `UPCOMING_PAYMENT` | За N дней до регулярного платежа | Открыть `/scheduled-payments` |
| `WEEKLY_SUMMARY` | Каждый понедельник 09:00 | Открыть `/home/oracle` |
| `UNUSUAL_SPENDING` | Аномальный расход обнаружен AI | Открыть транзакцию |
| `PREDICTION_READY` | Новый прогноз сгенерирован | Открыть `/predictions/:id` |

**Структура FCM payload:**

```json
{
  "notification": {
    "title": "Внимание: низкий баланс",
    "body": "Через 3 дня ожидается платёж 15 000 р., баланс может уйти в минус."
  },
  "data": {
    "type": "LOW_BALANCE",
    "accountId": "acc_123",
    "deepLink": "anticifi://predictions/acc_123"
  }
}
```

### 7.3. Локальные уведомления-напоминания

`flutter_local_notifications` используется для:
- Показа уведомлений, пришедших в foreground-режиме
- Локальных напоминаний (не требуют сервера): например, ежедневное напоминание внести расход

---

## 8. Офлайн-режим

### 8.1. Offline-first стратегия

AnticiFi следует стратегии **"Local First"**: все данные сначала читаются из локального кэша Isar, и только потом обновляются с сервера. Это гарантирует мгновенный старт приложения и работоспособность без сети.

```dart
class ConnectivityService {
  final _connectivity = Connectivity();
  final _streamController = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _streamController.stream;

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void init() {
    _connectivity.onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      _streamController.add(online);
      if (online) _syncService.syncPendingOperations();
    });
  }
}
```

**Offline-баннер** — виджет `OfflineBanner` отображается в верхней части экрана при потере соединения:

```dart
class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.read<ConnectivityService>().onConnectivityChanged,
      builder: (ctx, snapshot) {
        final isOnline = snapshot.data ?? true;
        if (isOnline) return const SizedBox.shrink();
        return Material(
          color: AppColors.warning,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              const Icon(Icons.wifi_off, size: 16),
              const SizedBox(width: 8),
              Text('Офлайн-режим', style: AppTextStyles.caption),
            ]),
          ),
        );
      },
    );
  }
}
```

### 8.2. Разрешение конфликтов

Стратегия: **server-wins (last-write-wins)**.

При восстановлении соединения:
1. Из `PendingSync` достаются накопленные операции (сортировка по `createdAt`)
2. Операции отправляются на сервер по одной
3. В случае конфликта (HTTP 409) — серверная версия считается актуальной, локальная перезаписывается
4. В случае ошибки — `retryCount++`, повторная попытка через экспоненциальный backoff

Пользователь **не видит** процесс разрешения конфликта — он происходит в фоне. Если синхронизация провалилась (retryCount > 5) — уведомление в центре уведомлений приложения.

---

## 9. Безопасность и биометрия

### Хранение токенов

JWT-токены (access + refresh) хранятся исключительно в **flutter_secure_storage**:
- **iOS**: Keychain Services
- **Android**: EncryptedSharedPreferences / Android Keystore

Токены **не хранятся** в обычном SharedPreferences, файловой системе или Isar.

### Биометрическая аутентификация

```dart
class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async =>
      await _auth.canCheckBiometrics && await _auth.isDeviceSupported();

  Future<bool> authenticate() async {
    return _auth.authenticate(
      localizedReason: 'Войдите в AnticiFi с помощью биометрии',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,  // разрешить PIN как fallback
      ),
    );
  }
}
```

**Флоу блокировки:**
- При переходе приложения в background > 5 минут — требовать повторную биометрию
- Настройка порога тайм-аута в `SettingsCubit`

### Сетевая безопасность

- **Certificate Pinning**: продакшн API-сертификат прибит в `dio_client.dart`
- **Jailbreak/Root Detection**: проверка при старте (пакет `flutter_jailbreak_detection`)
- **Screenshot Protection**: отключение скриншотов на чувствительных экранах (Android `FLAG_SECURE`, iOS соответствующий API)

---

## 10. UI/UX Гайдлайны

### 10.1. Design System

Приложение построено на **Material 3** (Material You) с кастомной цветовой схемой AnticiFi.

```dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: AppTextStyles.textTheme,
    // ...
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTextStyles.textTheme,
  );
}
```

**Цветовая система:**

| Токен | Light | Dark | Назначение |
|---|---|---|---|
| `primary` | `#4F6AF5` | `#7B93FF` | Основное действие, акценты |
| `secondary` | `#26C281` | `#3DD9A0` | Успех, положительные суммы |
| `error` | `#E53935` | `#FF6659` | Ошибки, отрицательные суммы |
| `warning` | `#FFB300` | `#FFC933` | Предупреждения, риски |
| `surface` | `#FFFFFF` | `#1A1A2E` | Карточки, фоны |
| `background` | `#F5F6FA` | `#12121F` | Фон приложения |

**Типографика:** Inter (Google Fonts) — основной шрифт. Monospace (Roboto Mono) — для отображения числовых значений баланса.

### 10.2. Состояния загрузки

Все экраны с загрузкой данных используют **skeleton loading** (shimmer-анимация) вместо spinner-а. Это даёт пользователю предварительное представление о структуре экрана.

```dart
class TransactionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.surface,
      highlightColor: context.colorScheme.surfaceVariant,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => const TransactionTileSkeleton(),
      ),
    );
  }
}
```

**Pull-to-refresh** реализован через стандартный `RefreshIndicator` с дополнительной тактильной обратной связью (haptic).

### 10.3. Анимации и обратная связь

| Элемент | Анимация |
|---|---|
| Переход между экранами | Hero-анимация для карточек счетов и транзакций |
| Появление элементов списка | Staggered fade-in (задержка 50ms между элементами) |
| Прогрессбар импорта | Анимированный LinearProgressIndicator |
| Oracle "думает" | Пульсирующие точки (typing indicator) |
| Успешное действие | Haptic: `HapticFeedback.mediumImpact()` |
| Ошибка | Haptic: `HapticFeedback.heavyImpact()` + shake-анимация |
| Бесконечная прокрутка | Spinner в подвале списка при `isLoadingMore: true` |

**Infinite scroll** реализован через `ScrollController` с порогом срабатывания 200px до конца списка:

```dart
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    context.read<TransactionListBloc>().add(LoadMore());
  }
}
```

---

## 11. Ключевые пакеты

```yaml
dependencies:
  flutter_bloc: ^8.1.6          # State management (BLoC/Cubit)
  go_router: ^13.2.0            # Декларативная навигация + deep linking
  dio: ^5.4.3                   # HTTP-клиент с интерцепторами
  isar: ^3.1.0                  # Локальная NoSQL база данных
  isar_flutter_libs: ^3.1.0     # Нативные бинарники Isar
  get_it: ^7.6.7                # Service locator (DI)
  injectable: ^2.3.2            # Code generation для GetIt
  freezed_annotation: ^2.4.1    # Immutable классы и union types
  json_annotation: ^4.8.1       # JSON сериализация/десериализация
  socket_io_client: ^2.0.3+1    # Real-time уведомления через WebSocket
  google_mlkit_text_recognition: ^0.13.0  # OCR (локально, без сети)
  camera_awesome: ^1.4.0        # Камера с расширенным API
  firebase_core: ^2.30.1        # Firebase инициализация
  firebase_messaging: ^14.9.1   # Push-уведомления (FCM)
  flutter_local_notifications: ^17.2.1    # Локальные уведомления
  connectivity_plus: ^5.0.2     # Мониторинг состояния сети
  fl_chart: ^0.68.0             # Графики (прогноз баланса, аналитика)
  shimmer: ^3.0.0               # Skeleton loading анимации
  cached_network_image: ^3.3.1  # Кэшированные сетевые изображения
  flutter_secure_storage: ^9.0.0  # Безопасное хранение токенов
  local_auth: ^2.2.0            # Биометрическая аутентификация
  dartz: ^0.10.1                # Either<Failure, T> для функционального стиля
  intl: ^0.19.0                 # Форматирование дат и чисел (l10n)
  path_provider: ^2.1.3         # Доступ к файловой системе

dev_dependencies:
  build_runner: ^2.4.9          # Code generation
  injectable_generator: ^2.4.1  # DI code generation
  freezed: ^2.5.2               # Immutable classes generation
  json_serializable: ^6.8.0     # JSON code generation
  isar_generator: ^3.1.0        # Isar schema generation
  bloc_test: ^9.1.7             # Тестирование BLoC
  mocktail: ^1.0.3              # Mock-объекты для тестов
  flutter_test:
    sdk: flutter
```

---

## 12. Инъекция зависимостей (GetIt + Injectable)

Все зависимости регистрируются в `injection_container.dart` и генерируются через `injectable`.

```dart
// injection_container.dart
@InjectableInit(
  initializerName: 'initGetIt',
  preferRelativeImports: true,
)
Future<void> configureDependencies() async => initGetIt(getIt);

// Использование аннотаций
@singleton  — один экземпляр на всё время жизни приложения (Dio, Isar, Services)
@lazySingleton — создаётся при первом обращении (Repositories, Use Cases)
@injectable — новый экземпляр при каждом запросе (BLoC/Cubit)
```

**Пример регистрации:**

```dart
@module
abstract class NetworkModule {
  @singleton
  Dio get dio => DioClient().instance;
}

@singleton
class IsarService {
  late Isar isar;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    isar = await Isar.open([
      UserLocalSchema,
      AccountLocalSchema,
      TransactionLocalSchema,
      PredictionLocalSchema,
      CategoryLocalSchema,
      PendingSyncSchema,
    ]);
  }
}

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(
    this._remoteDs,
    this._localDs,
    this._connectivity,
  );
  // ...
}
```

---

## 13. Обработка ошибок

Единая стратегия обработки ошибок на всех уровнях:

### Уровень Data (исключения → Failure)

```dart
// Типизированные Failure через Freezed
@freezed
class Failure with _$Failure {
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.server({required int statusCode, required String message}) = ServerFailure;
  const factory Failure.cache({required String message}) = CacheFailure;
  const factory Failure.unauthorized() = UnauthorizedFailure;
  const factory Failure.notFound() = NotFoundFailure;
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
```

### Уровень BLoC (Failure → UserMessage)

```dart
on<LoadTransactions>((event, emit) async {
  emit(TransactionLoading());
  final result = await _getTransactions(NoParams());
  result.fold(
    (failure) => emit(TransactionError(_mapFailureToMessage(failure))),
    (transactions) => emit(TransactionLoaded(transactions: transactions)),
  );
});

String _mapFailureToMessage(Failure failure) => failure.when(
  network: (_) => 'Нет подключения к интернету',
  server: (code, msg) => 'Ошибка сервера ($code)',
  cache: (_) => 'Ошибка локальной базы данных',
  unauthorized: () => 'Сессия истекла, войдите снова',
  notFound: () => 'Данные не найдены',
  unknown: (msg) => 'Неизвестная ошибка',
);
```

### Уровень UI (отображение ошибок)

- **Inline-ошибки**: под полями формы при валидации
- **Snackbar**: для временных ошибок действий (не удалось сохранить)
- **Error State экран**: при критической ошибке загрузки с кнопкой "Повторить"
- **Dialog**: при необратимых действиях (удаление, выход из аккаунта)

---

## Связанные документы

| Документ | Связь |
|---|---|
| [README](./README.md) | Обзор проекта, быстрый старт |
| [Техническое задание](./technical-spec.md) | Функциональные требования к каждому экрану |
| [Архитектура системы](./architecture.md) | Серверная часть, с которой взаимодействует приложение |
| [Пользовательские истории](./user-stories.md) | Сценарии, которые реализуют описанные экраны и BLoC |
| [Схема базы данных](./database-schema.md) | Серверные модели данных, соответствующие локальным моделям Isar |
| [Спецификация API](./api-spec.md) | Endpoints, используемые remote datasources |
| [Инфраструктура и DevOps](./infrastructure.md) | CI/CD для мобильного приложения (Fastlane, GitHub Actions) |

---

[← Назад к README](./README.md)
