# Бэклог задач — AnticiFi

> Навигация: [README](./README.md) | [Пользовательские истории](./user-stories.md) | [Техническое задание](./technical-spec.md) | [Схема базы данных](./database-schema.md) | [Архитектура системы](./architecture.md)

---

## Обзор плана выпуска

| Фаза | Спринтов | Недель | Статус |
|---|---|---|---|
| MVP (v1.0) | 8 | 16 | В разработке |
| v1.1 | 4 | 8 | Планируется |
| v2.0 | 6 | 12 | Roadmap |

**Итого:** 18 спринтов / 36 недель от старта до v2.0

---

## Условные обозначения сложности

| Метка | Время | Описание |
|---|---|---|
| **S** | 1–2 ч | Небольшая задача с единственной зоной ответственности |
| **M** | 2–4 ч | Задача умеренной сложности, несколько шагов |
| **L** | 4–8 ч | Значительная функция, затрагивает несколько слоёв |
| **XL** | 8–16+ ч | Сложная функция, охватывает несколько компонентов |

---

## Ключевые цепочки зависимостей

Следующие цепочки определяют критический путь разработки. Задача не может быть начата до завершения всех предшествующих задач в цепочке.

```
Инфраструктура и ядро backend:
TASK-001 → TASK-002 → TASK-003 → TASK-004 → TASK-005

Мобильное приложение — аутентификация:
TASK-010 → TASK-015 → TASK-016 → TASK-017

Транзакции и импорт:
TASK-021 → TASK-022 → TASK-025 → TASK-029 → TASK-032

Очереди и real-time:
TASK-030 → TASK-032
TASK-030 → TASK-035

Предиктивный движок Oracle:
TASK-051 → TASK-052 → TASK-053 → TASK-054 → TASK-055
```

> Все остальные зависимости указаны в поле **Зависит от** каждой задачи. Задачи без указанных зависимостей могут выполняться параллельно с учётом ресурсов команды.

---

## MVP (v1.0) — 8 спринтов / 16 недель

Цель MVP: рабочее мобильное приложение с ручным и CSV-импортом транзакций, базовым предиктивным движком Oracle, дашбордом и системой уведомлений. Покрывает ключевой value proposition — ответ на вопрос "хватит ли мне денег к дате X".

Связанные пользовательские истории: [US-001 — US-015](./user-stories.md) | Функциональные требования MVP: [technical-spec.md #mvp-scope](./technical-spec.md)

---

### Sprint 1 — Инфраструктура и Auth

**Цель спринта:** Поднять локальную инфраструктуру, создать монорепозиторий, реализовать полный auth-flow включая refresh-токены и сброс пароля. По завершении спринта разработчик должен иметь возможность запустить весь стек одной командой и получить JWT-токен через API.

**Продолжительность:** 2 недели (недели 1–2)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-001 | Docker Compose setup (PostgreSQL, Redis, NATS) | S | — | [arch](./architecture.md) |
| TASK-002 | NestJS project scaffold (монорепо с nx или turborepo) | M | TASK-001 | [arch](./architecture.md) |
| TASK-003 | Sequelize config + начальная миграция | S | TASK-002 | [db](./database-schema.md) |
| TASK-004 | User model + миграция | S | TASK-003 | [db](./database-schema.md#users) |
| TASK-005 | Auth module: register, login, JWT | L | TASK-004 | [api](./api-spec.md#auth), [us](./user-stories.md#us-001) |
| TASK-006 | Auth module: refresh token, logout | M | TASK-005 | [api](./api-spec.md#auth) |
| TASK-007 | Password reset flow (email) | M | TASK-005 | [api](./api-spec.md#auth), [us](./user-stories.md#us-002) |
| TASK-008 | Настройка input validation (class-validator, pipes) | S | TASK-002 | [spec](./technical-spec.md) |
| TASK-009 | Error handling (exception filters) | S | TASK-002 | [spec](./technical-spec.md) |
| TASK-010 | Flutter project scaffold | M | — | [mobile](./mobile-app.md) |

**Критерии готовности спринта:**
- `docker compose up` поднимает PostgreSQL, Redis, NATS без ошибок
- `POST /auth/register` и `POST /auth/login` возвращают валидный JWT
- Refresh-токен обновляется через `POST /auth/refresh`
- Email со ссылкой сброса пароля отправляется корректно
- Flutter-приложение запускается на iOS-симуляторе и Android-эмуляторе

---

### Sprint 2 — Accounts и базовый UI

**Цель спринта:** Реализовать CRUD для счетов и категорий на backend, создать первые экраны мобильного приложения с полной аутентификацией через BLoC. По завершении спринта пользователь может зарегистрироваться, войти и видеть список своих счетов в приложении.

**Продолжительность:** 2 недели (недели 3–4)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-011 | Account model + миграция | S | TASK-003 | [db](./database-schema.md#accounts) |
| TASK-012 | Account CRUD API | M | TASK-011 | [api](./api-spec.md#accounts), [us](./user-stories.md#us-003) |
| TASK-013 | Category model + миграция + seeder | S | TASK-003 | [db](./database-schema.md#categories) |
| TASK-014 | Category CRUD API | S | TASK-013 | [api](./api-spec.md#categories) |
| TASK-015 | Flutter auth screens (login, register) | L | TASK-010 | [mobile](./mobile-app.md#auth-screens), [us](./user-stories.md#us-001) |
| TASK-016 | Flutter auth BLoC | M | TASK-015 | [mobile](./mobile-app.md#bloc) |
| TASK-017 | Flutter Dio client + JWT interceptor | M | TASK-016 | [mobile](./mobile-app.md#networking) |
| TASK-018 | Flutter Isar setup | S | TASK-010 | [mobile](./mobile-app.md#local-db) |
| TASK-019 | Flutter account list screen | M | TASK-017, TASK-018 | [mobile](./mobile-app.md#accounts), [us](./user-stories.md#us-003) |
| TASK-020 | Flutter GoRouter setup | S | TASK-010 | [mobile](./mobile-app.md#navigation) |

**Критерии готовности спринта:**
- Пользователь может создать, отредактировать и удалить счёт через API
- Предустановленные категории (еда, транспорт, жильё и т.д.) доступны после seeder
- Flutter-приложение показывает экраны login/register с валидацией
- Список счетов отображается с реальными данными из API
- JWT автоматически обновляется через Dio-interceptor

---

### Sprint 3 — Транзакции

**Цель спринта:** Реализовать полный lifecycle транзакций: CRUD, фильтрация, пагинация, статистика, дедупликация. В мобильном приложении — список транзакций с пагинацией и экран создания. По завершении спринта — ядро учёта финансов готово.

**Продолжительность:** 2 недели (недели 5–6)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-021 | Transaction model + миграция | M | TASK-011, TASK-013 | [db](./database-schema.md#transactions) |
| TASK-022 | Transaction CRUD API | L | TASK-021 | [api](./api-spec.md#transactions), [us](./user-stories.md#us-004) |
| TASK-023 | Transaction filtering + pagination | M | TASK-022 | [api](./api-spec.md#transactions), [us](./user-stories.md#us-005) |
| TASK-024 | Transaction statistics endpoint | M | TASK-022 | [api](./api-spec.md#statistics) |
| TASK-025 | transactionHash deduplication hook | S | TASK-021 | [spec](./technical-spec.md#deduplication) |
| TASK-026 | Flutter transaction list screen | L | TASK-017, TASK-019 | [mobile](./mobile-app.md#transactions), [us](./user-stories.md#us-004) |
| TASK-027 | Flutter transaction detail / create screen | M | TASK-026 | [mobile](./mobile-app.md#transactions) |
| TASK-028 | Flutter transaction BLoC (pagination, filters) | M | TASK-026 | [mobile](./mobile-app.md#bloc) |

**Критерии готовности спринта:**
- `POST /transactions` создаёт транзакцию, повторная отправка того же хэша возвращает 409
- `GET /transactions` поддерживает фильтрацию по дате, категории, счёту и пагинацию cursor-based
- `GET /statistics` возвращает агрегированные данные по периоду
- Список транзакций в приложении подгружается постранично при скролле
- Создание транзакции через форму в приложении работает корректно

---

### Sprint 4 — Импорт CSV

**Цель спринта:** Реализовать асинхронный импорт банковских выписок в формате CSV с отображением прогресса в реальном времени. Включает настройку NATS-микросервиса, Bull-очередей и Socket.IO. По завершении — пользователь может загрузить CSV и видеть прогресс импорта.

**Продолжительность:** 2 недели (недели 7–8)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-029 | ImportJob model + миграция | S | TASK-003 | [db](./database-schema.md#import-jobs) |
| TASK-030 | NATS microservice setup | M | TASK-002 | [arch](./architecture.md#nats) |
| TASK-031 | Import Service scaffold | M | TASK-030 | [arch](./architecture.md#import-service) |
| TASK-032 | CSV parser + import logic | L | TASK-025, TASK-030, TASK-031 | [spec](./technical-spec.md#csv-import), [us](./user-stories.md#us-006) |
| TASK-033 | Bull queue для обработки CSV | M | TASK-031 | [arch](./architecture.md#queues) |
| TASK-034 | Import progress events (NATS → Socket.IO) | M | TASK-030, TASK-035 | [arch](./architecture.md#realtime) |
| TASK-035 | Socket.IO setup в API Gateway | M | TASK-030 | [arch](./architecture.md#realtime) |
| TASK-036 | Flutter CSV import screen | M | TASK-017 | [mobile](./mobile-app.md#import), [us](./user-stories.md#us-006) |
| TASK-037 | Flutter import progress UI | M | TASK-036 | [mobile](./mobile-app.md#import) |

**Критерии готовности спринта:**
- Загрузка CSV-файла создаёт ImportJob и ставит задачу в Bull-очередь
- Import Service обрабатывает транзакции асинхронно с дедупликацией через хэш
- Прогресс импорта транслируется через Socket.IO в реальном времени
- Flutter-приложение показывает progress bar с актуальным статусом
- Поддерживаются форматы выписок минимум 2 банков

---

### Sprint 5 — Dashboard

**Цель спринта:** Разработать главный экран приложения с агрегированной финансовой информацией: текущий баланс, тренды, траты по категориям. Реализовать кэширование дашборда в Redis для производительности. По завершении — пользователь видит полную картину своих финансов.

**Продолжительность:** 2 недели (недели 9–10)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-038 | Dashboard API endpoint | L | TASK-022, TASK-024 | [api](./api-spec.md#dashboard), [us](./user-stories.md#us-007) |
| TASK-039 | Spending chart endpoint | M | TASK-038 | [api](./api-spec.md#dashboard) |
| TASK-040 | Balance trend endpoint | M | TASK-038 | [api](./api-spec.md#dashboard) |
| TASK-041 | Account summary endpoint | S | TASK-038 | [api](./api-spec.md#dashboard) |
| TASK-042 | Flutter Dashboard screen | XL | TASK-038, TASK-039, TASK-040, TASK-041 | [mobile](./mobile-app.md#dashboard), [us](./user-stories.md#us-007) |
| TASK-043 | Flutter charts (fl_chart) | L | TASK-042 | [mobile](./mobile-app.md#charts) |
| TASK-044 | Flutter pull-to-refresh + skeleton loading | M | TASK-042 | [mobile](./mobile-app.md#ux) |
| TASK-045 | Redis caching для dashboard | M | TASK-038 | [spec](./technical-spec.md#caching) |

**Критерии готовности спринта:**
- `GET /dashboard` возвращает баланс, топ-категории трат и тренд за период менее 200 мс (с кэшем)
- Дашборд отображает круговую диаграмму трат по категориям и линейный тренд баланса
- Skeleton-loading показывается при загрузке данных
- Pull-to-refresh инвалидирует кэш и обновляет данные
- Redis-кэш инвалидируется при создании новой транзакции

---

### Sprint 6 — Scheduled Payments

**Цель спринта:** Добавить управление регулярными платежами (аренда, подписки, коммунальные услуги), которые автоматически учитываются в прогнозах. Cron-job обрабатывает наступившие платежи. По завершении — ключевой input для предиктивного движка готов.

**Продолжительность:** 2 недели (недели 11–12)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-046 | ScheduledPayment model + миграция | S | TASK-003 | [db](./database-schema.md#scheduled-payments) |
| TASK-047 | ScheduledPayment CRUD API | M | TASK-046 | [api](./api-spec.md#scheduled-payments), [us](./user-stories.md#us-008) |
| TASK-048 | Cron job для обработки scheduled payments | M | TASK-047 | [spec](./technical-spec.md#scheduler) |
| TASK-049 | Flutter scheduled payments screens | M | TASK-017, TASK-047 | [mobile](./mobile-app.md#scheduled), [us](./user-stories.md#us-008) |
| TASK-050 | Flutter scheduled payment BLoC | S | TASK-049 | [mobile](./mobile-app.md#bloc) |

**Критерии готовности спринта:**
- Пользователь может создать регулярный платёж с частотой (ежемесячно, еженедельно, ежегодно)
- Cron-job каждую ночь создаёт транзакции для наступивших платежей
- Список регулярных платежей отображается в приложении с датой следующего списания
- Регулярные платежи передаются в prediction service как входной параметр

---

### Sprint 7 — Prediction Engine (Oracle) MVP

**Цель спринта:** Запустить Python-микросервис предиктивного движка на базе Prophet, интегрировать его с основным backend через NATS, реализовать Oracle-endpoint для ответов на вопросы о будущем балансе. По завершении — ключевая ценность AnticiFi доступна пользователю.

**Продолжительность:** 2 недели (недели 13–14)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-051 | Prediction model + миграция | S | TASK-003 | [db](./database-schema.md#predictions) |
| TASK-052 | Python prediction service scaffold | M | TASK-051 | [arch](./architecture.md#prediction-service) |
| TASK-053 | NATS integration для Python service | M | TASK-030, TASK-052 | [arch](./architecture.md#nats) |
| TASK-054 | Базовая prediction model (Prophet) | XL | TASK-053 | [spec](./technical-spec.md#prediction), [us](./user-stories.md#us-009) |
| TASK-055 | Prediction API endpoints | M | TASK-054 | [api](./api-spec.md#predictions) |
| TASK-056 | Oracle natural language endpoint (базовый) | L | TASK-055 | [api](./api-spec.md#oracle), [us](./user-stories.md#us-010) |
| TASK-057 | Flutter Oracle screen | L | TASK-055, TASK-056 | [mobile](./mobile-app.md#oracle), [us](./user-stories.md#us-010) |
| TASK-058 | Flutter prediction timeline widget | M | TASK-057 | [mobile](./mobile-app.md#oracle) |

**Критерии готовности спринта:**
- Python-сервис получает запрос через NATS и возвращает прогноз баланса на 30/60/90 дней
- `POST /oracle/predict` возвращает прогнозируемый баланс на указанную дату с доверительным интервалом
- `POST /oracle/ask` принимает вопрос на естественном языке ("хватит ли мне денег 25-го?") и возвращает текстовый ответ
- Flutter-экран Oracle отображает timeline с прогнозом и визуальным предупреждением при потенциальном дефиците
- Время ответа prediction service не превышает 3 секунд для стандартного запроса

---

### Sprint 8 — Polish и Launch

**Цель спринта:** Завершить MVP — добавить систему уведомлений, провести end-to-end тестирование, оптимизировать производительность, исправить критические баги и подготовить приложение к публикации в App Store и Google Play.

**Продолжительность:** 2 недели (недели 15–16)

| ID | Задача | Сложность | Зависит от | Связь |
|---|---|---|---|---|
| TASK-059 | Notification Service scaffold | M | TASK-002 | [arch](./architecture.md#notifications) |
| TASK-060 | Push notifications (FCM) | L | TASK-059 | [spec](./technical-spec.md#notifications), [us](./user-stories.md#us-011) |
| TASK-061 | Email notifications | M | TASK-059 | [spec](./technical-spec.md#notifications) |
| TASK-062 | Flutter notification UI | M | TASK-060 | [mobile](./mobile-app.md#notifications) |
| TASK-063 | Notification preferences API | S | TASK-059 | [api](./api-spec.md#notifications) |
| TASK-064 | End-to-end testing | XL | все TASK-001–063 | [spec](./technical-spec.md#testing) |
| TASK-065 | Performance optimization | L | TASK-064 | [spec](./technical-spec.md#performance) |
| TASK-066 | Bug fixing sprint | XL | TASK-064 | — |
| TASK-067 | App Store / Play Store preparation | M | TASK-065, TASK-066 | — |

**Критерии готовности спринта (Definition of Done для MVP):**
- Push-уведомление отправляется за 3 дня до прогнозируемого дефицита баланса
- E2E-тесты покрывают критические пользовательские пути (регистрация → импорт → прогноз)
- Время загрузки дашборда не превышает 1 секунды на 4G
- Crash-free rate не ниже 99.5% на тестовой аудитории
- Приложение прошло App Store Review Guidelines и Google Play Policy review
- Все TASK-001–063 имеют статус Done

---

## v1.1 — 4 спринта / 8 недель

Цель v1.1: улучшение пользовательского опыта, расширение возможностей импорта через OCR, offline-режим, тёмная тема и экспорт данных. Фокус — удержание пользователей и повышение DAU.

Связанные пользовательские истории: [US-016 — US-025](./user-stories.md)

---

| ID | Задача | Сложность | Зависит от | Версия |
|---|---|---|---|---|
| TASK-100 | OCR сканирование чеков (Google ML Kit) | XL | TASK-010 | v1.1 |
| TASK-101 | OCR backend processing | L | TASK-100, TASK-032 | v1.1 |
| TASK-102 | Biometric login | M | TASK-016 | v1.1 |
| TASK-103 | Offline mode (Isar sync) | XL | TASK-018 | v1.1 |
| TASK-104 | Dark theme | M | TASK-010 | v1.1 |
| TASK-105 | Data export (CSV / PDF) | M | TASK-023 | v1.1 |
| TASK-106 | Onboarding screens | M | TASK-015 | v1.1 |
| TASK-107 | Advanced filtering (transaction search) | M | TASK-028 | v1.1 |
| TASK-108 | Spending insights (anomaly detection) | L | TASK-054 | v1.1 |

**Ключевые задачи v1.1 — детали:**

**TASK-100 / TASK-101 — OCR Receipt Scanning (XL + L)**
Интеграция Google ML Kit для сканирования бумажных чеков камерой смартфона. Flutter-часть захватывает изображение, ML Kit извлекает текст, backend парсит и создаёт транзакцию. Сложность: вариативность форматов чеков разных магазинов, качество OCR при плохом освещении.
Связь: [us](./user-stories.md#us-016) | [spec](./technical-spec.md#ocr)

**TASK-103 — Offline mode (XL)**
Полноценная работа приложения без интернета: локальное создание транзакций в Isar, синхронизация при восстановлении соединения с разрешением конфликтов. Сложность: conflict resolution при одновременных изменениях online/offline.
Связь: [us](./user-stories.md#us-018) | [mobile](./mobile-app.md#offline)

**TASK-108 — Spending Insights / Anomaly Detection (L)**
Расширение Python prediction service: детектирование аномальных трат (расход сильно выше среднего по категории), автоматические инсайты типа "В этом месяце вы тратите на кафе на 40% больше обычного".
Связь: [us](./user-stories.md#us-025) | [spec](./technical-spec.md#anomaly)

---

## v2.0 — 6 спринтов / 12 недель

Цель v2.0: масштабирование продукта — LSTM-модели, банковские API, семейные счета, web-клиент, B2B white-label и расширенный Oracle с conversational интерфейсом.

Связанные пользовательские истории: [US-026 — US-040](./user-stories.md)

---

| ID | Задача | Сложность | Зависит от | Версия |
|---|---|---|---|---|
| TASK-200 | LSTM prediction model | XL | TASK-054 | v2.0 |
| TASK-201 | Multi-currency support | L | TASK-022 | v2.0 |
| TASK-202 | Bank API integration (Plaid / Open Banking) | XL | TASK-032 | v2.0 |
| TASK-203 | Shared accounts / family mode | XL | TASK-012 | v2.0 |
| TASK-204 | Web client (Angular / React) | XL | TASK-038 | v2.0 |
| TASK-205 | B2B white-label module | XL | TASK-038, TASK-054 | v2.0 |
| TASK-206 | Advanced Oracle (GPT-like conversational interface) | XL | TASK-056, TASK-200 | v2.0 |
| TASK-207 | Investment tracking | L | TASK-022 | v2.0 |
| TASK-208 | Savings goals | M | TASK-046 | v2.0 |
| TASK-209 | Weekly / monthly AI-generated reports | L | TASK-200 | v2.0 |

**Ключевые задачи v2.0 — детали:**

**TASK-200 — LSTM Prediction Model (XL)**
Замена Prophet на LSTM (Long Short-Term Memory) нейросеть для более точного прогнозирования на длинных горизонтах. Модель обучается на исторических данных пользователя с fine-tuning. Требует достаточного объёма исторических данных (минимум 6 месяцев).
Связь: [spec](./technical-spec.md#lstm) | Зависит от: TASK-054 (данные и инфраструктура Prophet)

**TASK-202 — Bank API Integration (XL)**
Автоматический импорт транзакций через Plaid (США/Канада) или PSD2 Open Banking API (Европа). Устраняет необходимость ручного CSV-импорта. Ключевой шаг к premium-монетизации.
Связь: [us](./user-stories.md#us-028) | [spec](./technical-spec.md#open-banking)

**TASK-203 — Shared Accounts / Family Mode (XL)**
Совместный доступ к счёту для нескольких пользователей с разграничением ролей (owner, viewer, editor). Общий дашборд и сводный прогноз семейного бюджета.
Связь: [us](./user-stories.md#us-030)

**TASK-205 — B2B White-Label Module (XL)**
Конфигурируемый white-label вариант AnticiFi для банков и финтех-компаний. Включает: tenant-изоляцию данных, кастомизацию брендинга, API для интеграции с core banking, SLA-мониторинг.
Связь: [vision](./vision.md#b2b)

**TASK-206 — Advanced Oracle (XL)**
Переход от rule-based ответов к GPT-like conversational interface. Пользователь ведёт диалог с Oracle: "Если я куплю MacBook за $2000, когда восстановится баланс?", "Покажи мне мои траты за последние 3 месяца". Интеграция с LLM (OpenAI API или self-hosted Llama).
Связь: [us](./user-stories.md#us-033) | [spec](./technical-spec.md#advanced-oracle)

---

## Сводная таблица всех задач

### MVP — Sprint 1

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-001 | Docker Compose setup | S | 1–2 |
| TASK-002 | NestJS monorepo scaffold | M | 2–4 |
| TASK-003 | Sequelize config + migration | S | 1–2 |
| TASK-004 | User model + migration | S | 1–2 |
| TASK-005 | Auth: register, login, JWT | L | 4–8 |
| TASK-006 | Auth: refresh token, logout | M | 2–4 |
| TASK-007 | Password reset flow | M | 2–4 |
| TASK-008 | Input validation setup | S | 1–2 |
| TASK-009 | Error handling filters | S | 1–2 |
| TASK-010 | Flutter scaffold | M | 2–4 |
| **Итого Sprint 1** | | | **17–34 ч** |

### MVP — Sprint 2

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-011 | Account model + migration | S | 1–2 |
| TASK-012 | Account CRUD API | M | 2–4 |
| TASK-013 | Category model + migration + seeder | S | 1–2 |
| TASK-014 | Category CRUD API | S | 1–2 |
| TASK-015 | Flutter auth screens | L | 4–8 |
| TASK-016 | Flutter auth BLoC | M | 2–4 |
| TASK-017 | Flutter Dio + JWT interceptor | M | 2–4 |
| TASK-018 | Flutter Isar setup | S | 1–2 |
| TASK-019 | Flutter account list screen | M | 2–4 |
| TASK-020 | Flutter GoRouter setup | S | 1–2 |
| **Итого Sprint 2** | | | **17–34 ч** |

### MVP — Sprint 3

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-021 | Transaction model + migration | M | 2–4 |
| TASK-022 | Transaction CRUD API | L | 4–8 |
| TASK-023 | Transaction filtering + pagination | M | 2–4 |
| TASK-024 | Transaction statistics endpoint | M | 2–4 |
| TASK-025 | transactionHash deduplication | S | 1–2 |
| TASK-026 | Flutter transaction list | L | 4–8 |
| TASK-027 | Flutter transaction create/detail | M | 2–4 |
| TASK-028 | Flutter transaction BLoC | M | 2–4 |
| **Итого Sprint 3** | | | **19–38 ч** |

### MVP — Sprint 4

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-029 | ImportJob model + migration | S | 1–2 |
| TASK-030 | NATS microservice setup | M | 2–4 |
| TASK-031 | Import Service scaffold | M | 2–4 |
| TASK-032 | CSV parser + import logic | L | 4–8 |
| TASK-033 | Bull queue для CSV | M | 2–4 |
| TASK-034 | Import progress events (NATS → Socket.IO) | M | 2–4 |
| TASK-035 | Socket.IO в API Gateway | M | 2–4 |
| TASK-036 | Flutter CSV import screen | M | 2–4 |
| TASK-037 | Flutter import progress UI | M | 2–4 |
| **Итого Sprint 4** | | | **19–38 ч** |

### MVP — Sprint 5

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-038 | Dashboard API | L | 4–8 |
| TASK-039 | Spending chart endpoint | M | 2–4 |
| TASK-040 | Balance trend endpoint | M | 2–4 |
| TASK-041 | Account summary endpoint | S | 1–2 |
| TASK-042 | Flutter Dashboard screen | XL | 8–16 |
| TASK-043 | Flutter charts (fl_chart) | L | 4–8 |
| TASK-044 | Pull-to-refresh + skeleton loading | M | 2–4 |
| TASK-045 | Redis caching для dashboard | M | 2–4 |
| **Итого Sprint 5** | | | **25–50 ч** |

### MVP — Sprint 6

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-046 | ScheduledPayment model + migration | S | 1–2 |
| TASK-047 | ScheduledPayment CRUD API | M | 2–4 |
| TASK-048 | Cron job обработка платежей | M | 2–4 |
| TASK-049 | Flutter scheduled payments screens | M | 2–4 |
| TASK-050 | Flutter scheduled payment BLoC | S | 1–2 |
| **Итого Sprint 6** | | | **8–16 ч** |

### MVP — Sprint 7

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-051 | Prediction model + migration | S | 1–2 |
| TASK-052 | Python prediction service scaffold | M | 2–4 |
| TASK-053 | NATS integration Python | M | 2–4 |
| TASK-054 | Базовая prediction model (Prophet) | XL | 8–16 |
| TASK-055 | Prediction API endpoints | M | 2–4 |
| TASK-056 | Oracle NL endpoint (базовый) | L | 4–8 |
| TASK-057 | Flutter Oracle screen | L | 4–8 |
| TASK-058 | Flutter prediction timeline widget | M | 2–4 |
| **Итого Sprint 7** | | | **25–50 ч** |

### MVP — Sprint 8

| ID | Название | Сложность | Часов (оценка) |
|---|---|---|---|
| TASK-059 | Notification Service scaffold | M | 2–4 |
| TASK-060 | Push notifications (FCM) | L | 4–8 |
| TASK-061 | Email notifications | M | 2–4 |
| TASK-062 | Flutter notification UI | M | 2–4 |
| TASK-063 | Notification preferences API | S | 1–2 |
| TASK-064 | End-to-end testing | XL | 8–16 |
| TASK-065 | Performance optimization | L | 4–8 |
| TASK-066 | Bug fixing sprint | XL | 8–16 |
| TASK-067 | App Store / Play Store preparation | M | 2–4 |
| **Итого Sprint 8** | | | **33–66 ч** |

---

## Итоговая оценка трудоёмкости

| Фаза | Задач | Мин. часов | Макс. часов |
|---|---|---|---|
| MVP (v1.0) | 67 | 163 | 326 |
| v1.1 | 9 | 47 | 94 |
| v2.0 | 10 | 58 | 116 |
| **Всего** | **86** | **268** | **536** |

> Оценки даны для команды из 2–3 разработчиков (1 fullstack/backend + 1 Flutter + частичная занятость ML-инженера). При работе в одиночку время удваивается. При команде 4+ человек — задачи без зависимостей выполняются параллельно и общее время сокращается.

---

## Приоритизация для одного разработчика

Если проект ведётся одним разработчиком, рекомендуется следующий порядок приоритетов:

1. **Must Have (MVP-ядро):** TASK-001–009, 011–014, 021–025, 029–035, 051–055 — backend-ядро без мобильного приложения
2. **Should Have:** TASK-010, 015–020, 026–028, 036–037, 038–045, 056–058 — мобильный клиент и Oracle UI
3. **Nice to Have в MVP:** TASK-046–050, 059–063 — scheduled payments и уведомления
4. **Post-MVP:** TASK-064–067, все v1.1 и v2.0

---

## Матрица рисков

| Риск | Задачи | Вероятность | Влияние | Митигация |
|---|---|---|---|---|
| Prophet даёт низкую точность прогнозов | TASK-054 | Средняя | Высокое | Иметь fallback на простую линейную экстраполяцию; в v2.0 перейти на LSTM (TASK-200) |
| Разнообразие форматов CSV разных банков | TASK-032 | Высокая | Среднее | Реализовать configurable parser с маппинг-конфигами; начать с 2–3 банков |
| App Store rejection | TASK-067 | Низкая | Высокое | Тщательно соблюдать HIG и privacy policy; проверить все разрешения заранее |
| Деградация производительности при росте данных | TASK-038, 045 | Средняя | Среднее | Redis caching (TASK-045); партиционирование таблицы transactions по дате |
| NATS single point of failure | TASK-030, 034 | Низкая | Высокое | Настроить NATS clustering с 3 нодами в production |
| Переработка архитектуры для multi-tenancy | TASK-205 | Средняя | Высокое | Заложить tenant_id в схему БД с MVP (TASK-003, 004) |

---

## Changelog

| Дата | Изменение |
|---|---|
| 2026-02-28 | Создан документ. MVP 8 спринтов, v1.1 4 спринта, v2.0 6 спринтов. Всего 86 задач. |

---

*AnticiFi Backlog — актуальная версия всегда в [backlog.md](./backlog.md). Последнее обновление: 2026-02-28.*
