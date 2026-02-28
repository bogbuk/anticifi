# Архитектура системы AnticiFi

> Назад к [README](./README.md) | Смежные документы: [Техническое задание](./technical-spec.md) · [Спецификация API](./api-spec.md) · [Инфраструктура и DevOps](./infrastructure.md)

---

## Содержание

1. [Обзор архитектуры](#1-обзор-архитектуры)
2. [Диаграмма компонентов](#2-диаграмма-компонентов)
3. [Описание сервисов](#3-описание-сервисов)
4. [Data Flow: импорт CSV](#4-data-flow-импорт-csv)
5. [Data Flow: OCR-сканирование чека](#5-data-flow-ocr-сканирование-чека)
6. [NATS: темы сообщений](#6-nats-темы-сообщений)
7. [Bull Queues: фоновые задачи](#7-bull-queues-фоновые-задачи)
8. [Кеширование в Redis](#8-кеширование-в-redis)
9. [Real-time через Socket.IO](#9-real-time-через-socketio)
10. [Prediction Engine: архитектура ML-движка](#10-prediction-engine-архитектура-ml-движка)
11. [Принципы масштабирования](#11-принципы-масштабирования)
12. [Безопасность](#12-безопасность)

---

## 1. Обзор архитектуры

AnticiFi построен на **микросервисной архитектуре** с паттерном **API Gateway**. Система проектировалась с учётом трёх ключевых требований: горизонтальная масштабируемость, изоляция ответственности каждого сервиса и надёжность при пиковых нагрузках.

### Ключевые архитектурные решения

| Решение | Технология | Обоснование |
|---|---|---|
| Межсервисное взаимодействие | NATS message broker | Асинхронный обмен сообщениями, низкая задержка, publish/subscribe без прямых зависимостей |
| Фоновые задачи | Bull + Redis | Надёжные очереди с retry-стратегией, dead letter queue, мониторинг через UI |
| Real-time обновления | Socket.IO | Двунаправленный WebSocket с fallback-механизмами, поддержка горизонтального масштабирования через Redis Adapter |
| Хранилище данных | PostgreSQL | ACID-транзакции критичны для финансовых данных; поддержка сложных аналитических запросов |
| Кеширование | Redis | Единый слой для кеша, очередей и сессий Socket.IO |
| ML-движок | Python (отдельный микросервис) | Изоляция ML-зависимостей от Node.js-окружения; независимый деплой и масштабирование |
| Контейнеризация | Docker | Воспроизводимость окружения, единообразный деплой на всех стадиях |

### Технологический стек

```
Слой             Технологии
─────────────────────────────────────────────────────────────
API Gateway      NestJS, Socket.IO, JWT (RS256)
Import Service   NestJS, csv-parse, Sharp (image processing)
Prediction Srv   NestJS (proxy), Python FastAPI (ML core)
Notification     NestJS, Firebase FCM, NodeMailer
Брокер           NATS 2.x
Очереди          Bull 4.x (Redis-backed)
База данных      PostgreSQL 16, Sequelize ORM
Кеш              Redis 7
Прокси           Nginx (TLS termination, reverse proxy)
Мобильный клиент Flutter 3.x (BLoC/Cubit, Isar DB, ML Kit)
ML               Python 3.11, Prophet, PyTorch (LSTM), FastAPI
Инфраструктура   Docker Compose, GitHub Actions
```

---

## 2. Диаграмма компонентов

```
┌─────────────────────┐     ┌──────────────────────┐
│    Flutter App       │     │     Web Client        │
│    (Mobile)          │     │     (Future)          │
│                      │     │                       │
│  BLoC / Cubit        │     │  React (planned)      │
│  Isar DB (offline)   │     │                       │
│  ML Kit OCR (local)  │     │                       │
└──────────┬───────────┘     └──────────┬────────────┘
           │                             │
           └──────────────┬──────────────┘
                          │  HTTPS / WSS
                 ┌────────▼────────┐
                 │      Nginx       │
                 │  (Reverse Proxy) │
                 │  TLS Termination │
                 │  Rate Limiting   │
                 └────────┬─────────┘
                          │  HTTP / WS
                 ┌────────▼─────────┐
                 │   API Gateway     │
                 │   (NestJS)        │
                 │                   │
                 │  REST API         │
                 │  WebSocket        │
                 │  JWT Auth         │
                 │  Request routing  │
                 │  Response cache   │
                 └────────┬──────────┘
                          │
                  ── NATS Message Broker ──
          ┌───────────────┼───────────────┬──────────────┐
          │               │               │              │
  ┌───────▼──────┐ ┌──────▼──────┐ ┌────▼──────┐ ┌────▼──────┐
  │  Transaction  │ │   Import    │ │Prediction │ │Notification│
  │   Service     │ │   Service   │ │  Service  │ │  Service   │
  │               │ │             │ │           │ │            │
  │ CRUD trans.   │ │ CSV parser  │ │ NATS proxy│ │ FCM push   │
  │ Categories    │ │ OCR parser  │ │ Result    │ │ Email       │
  │ Balance calc  │ │ Dedup hash  │ │ cache     │ │ Scheduling │
  └───────┬───────┘ └──────┬──────┘ └────┬──────┘ └────┬───────┘
          │                │             │              │
          └────────┬───────┘             │              │
                   │                     │              │
          ┌────────▼────────┐    ┌───────▼───────┐  ┌──▼────────┐
          │   PostgreSQL     │    │  Python ML     │  │ FCM /     │
          │                  │    │  Service       │  │ SMTP      │
          │  transactions    │    │  (FastAPI)     │  │           │
          │  accounts        │    │                │  │           │
          │  users           │    │  Prophet       │  └───────────┘
          │  predictions     │    │  LSTM          │
          │  import_jobs     │    │  Rule Engine   │
          └────────┬─────────┘    └───────────────┘
                   │
          ┌────────▼─────────┐
          │      Redis        │
          │                   │
          │  Response Cache   │
          │  Bull Queues      │
          │  Socket.IO Rooms  │
          │  Rate Limit Store │
          └───────────────────┘
```

### Потоки взаимодействия

Система поддерживает два режима взаимодействия:

- **Синхронный (REST)** — клиент -> Nginx -> API Gateway -> ответ. Используется для CRUD-операций, запросов данных, аутентификации.
- **Асинхронный (NATS + Socket.IO)** — клиент инициирует операцию, получает `jobId`, результат прилетает через WebSocket. Используется для импорта, генерации предсказаний, уведомлений.

---

## 3. Описание сервисов

### 3.1 API Gateway (NestJS)

Единая точка входа для всех клиентских запросов. Gateway не содержит бизнес-логики — он маршрутизирует, аутентифицирует и проксирует.

**Зоны ответственности:**
- JWT-аутентификация (RS256, accessToken 15 мин / refreshToken 30 дней)
- Валидация входящих данных (class-validator, class-transformer)
- Rate limiting (throttle по userId и IP)
- Проксирование запросов к соответствующим микросервисам через NATS
- WebSocket-сервер (Socket.IO): управление комнатами, трансляция событий клиентам
- Возврат кешированных ответов из Redis

**Ключевые модули:**
```
AuthModule          — регистрация, логин, refresh, logout
UsersModule         — профиль, настройки
AccountsModule      — счета пользователя
TransactionsModule  — CRUD транзакций, фильтрация
ImportModule        — загрузка CSV / OCR
PredictionsModule   — запрос и отдача предсказаний
NotificationsModule — управление подписками и настройками
WebSocketGateway    — Socket.IO rooms, event dispatch
```

### 3.2 Transaction Service (NestJS)

Отвечает за всё, что связано с транзакциями: создание, обновление, удаление, расчёт баланса, категоризация.

**Зоны ответственности:**
- Хранение и выборка транзакций из PostgreSQL
- Автоопределение категории по описанию (keyword matching + обращение к ML)
- Пересчёт баланса счёта при изменении транзакций
- Публикация событий `transaction.created`, `transaction.updated`, `transaction.deleted` в NATS

### 3.3 Import Service (NestJS)

Обрабатывает входящие данные из внешних источников — CSV-выписки банков и текст, извлечённый OCR.

**Зоны ответственности:**
- Парсинг CSV (поддержка нескольких форматов банков)
- Парсинг OCR-текста: извлечение суммы, даты, описания из неструктурированного текста
- Дедупликация: вычисление `transactionHash = SHA-256(accountId:date:amount:description)`, проверка на существование
- Bulk insert транзакций через Transaction Service
- Публикация прогресса через NATS (`import.progress`, `import.completed`)
- Управление статусом `ImportJob` в базе данных

**Хэш дедупликации:**
```
transactionHash = SHA-256(
  accountId + ":" +
  date.toISOString() + ":" +
  amount.toFixed(2) + ":" +
  description.toLowerCase().trim()
)
```

### 3.4 Prediction Service (NestJS)

Тонкая обёртка над Python ML-сервисом. Принимает запросы через NATS, формирует датасет, вызывает Python FastAPI, сохраняет результат.

**Зоны ответственности:**
- Выборка истории транзакций за последние 90 дней
- Выборка запланированных платежей
- Формирование payload для Python ML API
- Вызов FastAPI (`POST /predict`)
- Сохранение предсказаний в PostgreSQL
- Публикация `prediction.result` в NATS
- Инвалидация кеша `cache:predictions:{accountId}`

### 3.5 Notification Service (NestJS)

Доставка уведомлений пользователям через различные каналы.

**Зоны ответственности:**
- Firebase Cloud Messaging (FCM) для push-уведомлений на мобильные устройства
- Email-уведомления через SMTP (NodeMailer)
- Управление подписками на уведомления
- Шедулинг: ежедневные summary, предупреждения о нехватке средств

### 3.6 Python ML Service (FastAPI)

Ядро предиктивного движка. Работает как самостоятельный микросервис, общается с NestJS через HTTP (внутренняя сеть Docker).

**Зоны ответственности:**
- Обучение и инференс ансамблевой модели (Prophet + LSTM)
- Генерация прогнозов на 30/60/90 дней
- Расчёт доверительных интервалов
- Применение детерминистических правил (запланированные платежи)

Детальная архитектура ML-движка описана в [разделе 10](#10-prediction-engine-архитектура-ml-движка).

---

## 4. Data Flow: импорт CSV

Полный путь данных от загрузки файла пользователем до обновления Dashboard.

```
Шаг 1: Загрузка файла
─────────────────────
Пользователь выбирает CSV в Flutter
  └─► POST /api/import/csv (multipart/form-data)
        Header: Authorization: Bearer <accessToken>

Шаг 2: API Gateway — приём и роутинг
──────────────────────────────────────
  ├─ Валидация JWT
  ├─ Валидация файла (size, mimetype)
  ├─ Создание записи ImportJob в БД (status: pending)
  ├─ Сохранение файла во временное хранилище
  └─► Публикация в NATS: subject = "import.process"
        payload = { jobId, userId, accountId, filePath, format: "csv" }

Шаг 3: Import Service — обработка
───────────────────────────────────
Import Service подписан на "import.process":

  3a. Обновление ImportJob.status = "processing"
  3b. Парсинг CSV построчно (csv-parse, streaming mode)
  3c. Для каждой строки:
        ├─ Нормализация даты, суммы, описания
        ├─ Вычисление transactionHash (SHA-256)
        ├─ Проверка: SELECT 1 FROM transactions WHERE hash = ?
        │     ├─ EXISTS → пропустить (дубликат)
        │     └─ NOT EXISTS → добавить в batch
        └─ Автокатегоризация описания (keyword dict + ML fallback)
  3d. Bulk INSERT batch транзакций в PostgreSQL
  3e. UPDATE accounts SET balance = recalculated WHERE id = accountId
  3f. Публикация прогресса:
        NATS: "import.progress" → { jobId, processed: N, total: M, percent }
        └─► API Gateway → Socket.IO room "user:{userId}" → Flutter
  3g. По завершении:
        NATS: "import.completed" → { jobId, imported: N, skipped: K, errors: E }
        Update ImportJob.status = "completed"

Шаг 4: Генерация предсказаний
───────────────────────────────
API Gateway получает "import.completed":
  └─► NATS: "prediction.generate" → { userId, accountId }

Prediction Service:
  ├─ SELECT транзакции за 90 дней
  ├─ SELECT scheduled_payments WHERE accountId = ?
  ├─ POST http://ml-service/predict { transactions, payments, balance }
  ├─ INSERT predictions (per day for 30/60/90 days + confidence)
  ├─ DELETE cache:predictions:{accountId}
  └─► NATS: "prediction.result" → { accountId, predictionsReady: true }

Шаг 5: Push на клиент
────────────────────────
API Gateway получает "prediction.result":
  └─► Socket.IO room "account:{accountId}":
        emit("predictions:updated", { accountId })
        Flutter перезапрашивает GET /api/predictions/{accountId}
        Dashboard обновляется
```

### Обработка ошибок при импорте

| Сценарий | Поведение |
|---|---|
| Файл не парсится | `ImportJob.status = "failed"`, ошибка через Socket.IO |
| Частичный сбой строк | Пропустить строку, записать в `import_errors`, продолжить |
| Таймаут ML-сервиса | Fallback: категория "Other", импорт продолжается |
| NATS недоступен | Bull queue принимает задачу, повтор через exponential backoff |
| Дубликаты | Тихо пропускаются, учитываются в `skipped` счётчике |

---

## 5. Data Flow: OCR-сканирование чека

```
Шаг 1: Локальное распознавание на устройстве
──────────────────────────────────────────────
Пользователь фотографирует чек в Flutter
  └─► Google ML Kit (on-device OCR)
        Результат: { rawText: "...", confidence: 0.94 }

Шаг 2: Отправка на сервер
───────────────────────────
POST /api/import/ocr
  Body: {
    rawText: "extracted text from ML Kit",
    imageBase64: "<optional, for re-processing>",
    accountId: "uuid"
  }

Шаг 3-5: Аналогично CSV
─────────────────────────
Import Service:
  ├─ Парсинг OCR-текста (regex extraction):
  │     ├─ Сумма: ищет паттерны "Total: 12.50", "ИТОГО 12,50 руб"
  │     ├─ Дата: ищет форматы DD.MM.YYYY, MM/DD/YY, "28 Feb 2026"
  │     └─ Описание: первая значимая строка или название магазина
  ├─ Создание одной транзакции (не batch)
  └─► Далее: тот же flow, что и при CSV (дедупликация, баланс, предсказание)
```

**Примечание об OCR-качестве:** если `confidence < 0.7` или парсинг не извлёк сумму — транзакция создаётся со статусом `needs_review`, пользователь получает уведомление с просьбой уточнить данные вручную.

---

## 6. NATS: темы сообщений

NATS используется как единый асинхронный транспорт между микросервисами. Все subjects следуют dot-нотации: `<домен>.<действие>`.

### Полный реестр subjects

```
Subject                       Publisher           Subscriber(s)
────────────────────────────────────────────────────────────────────
transaction.created           Transaction Svc     API GW, Pred. Svc
transaction.updated           Transaction Svc     API GW
transaction.deleted           Transaction Svc     API GW
transaction.batch.created     Import Svc          Pred. Svc

import.process                API Gateway         Import Svc
import.progress               Import Svc          API GW → Socket.IO
import.completed              Import Svc          API GW, Pred. Svc
import.failed                 Import Svc          API GW → Socket.IO

prediction.generate           API GW / Import Svc Prediction Svc
prediction.result             Prediction Svc      API GW → Socket.IO

notification.send             Any service         Notification Svc
notification.scheduled        Cron (API GW)       Notification Svc

account.balance.updated       Transaction Svc     API GW → Socket.IO
account.deleted               API GW              All services (cleanup)

user.deleted                  API GW              All services (cascade)
```

### Формат сообщений

Все сообщения сериализуются в JSON. Базовая структура:

```json
{
  "eventId": "uuid-v4",
  "timestamp": "2026-02-28T10:00:00.000Z",
  "version": "1.0",
  "payload": { ... }
}
```

### Стратегия при недоступности NATS

При временной недоступности NATS запросы, требующие надёжной доставки, маршрутизируются через Bull Queue. Subscriber-сервисы при перезапуске восстанавливают пропущенные сообщения из очереди. Идемпотентность операций обеспечивается через `eventId`.

---

## 7. Bull Queues: фоновые задачи

Bull Queue используется для задач, требующих гарантированного выполнения, retry-логики и отслеживаемости состояния. Все очереди хранятся в Redis.

### Реестр очередей

```
Очередь                   Concurrency  Назначение
──────────────────────────────────────────────────────────────────
import-csv-queue          3            Обработка CSV-файлов
import-ocr-queue          5            Обработка OCR-результатов
prediction-queue          2            Запуск ML-предсказаний
notification-queue        10           Отправка push/email уведомлений
scheduled-payment-queue   1            Cron: проверка плановых платежей
cleanup-queue             1            Очистка: токены, старые jobs
```

### Конфигурация retry-стратегии

Применяется единая стратегия для всех очередей с настройкой per-queue при необходимости:

```typescript
// Глобальная конфигурация Bull
const defaultJobOptions = {
  attempts: 3,
  backoff: {
    type: 'exponential',
    delay: 2000,          // начальная задержка 2 сек
                          // повторы: 2s → 4s → 8s
  },
  removeOnComplete: 100,  // хранить последние 100 завершённых
  removeOnFail: 500,      // хранить последние 500 упавших
};

// Dead Letter Queue: при исчерпании attempts
// job переходит в failed-очередь для ручного анализа
```

| Параметр | Значение | Обоснование |
|---|---|---|
| `attempts` | 3 | Достаточно для покрытия кратковременных сбоев |
| `backoff.type` | exponential | Не перегружает восстанавливающийся сервис |
| `backoff.delay` | 2000 мс | Стартовая задержка перед первым повтором |
| `removeOnComplete` | 100 | Балансировка между историей и памятью Redis |
| `removeOnFail` | 500 | Сохранение упавших jobs для анализа |

### Scheduled Jobs (Cron)

```typescript
// scheduled-payment-queue: каждый день в 06:00 UTC
@Cron('0 6 * * *')
async checkScheduledPayments() {
  // Для каждого пользователя:
  // 1. Выбрать scheduled_payments WHERE next_date <= NOW() + 3 days
  // 2. Если баланс - сумма < 0: отправить уведомление
  // 3. Обновить next_date (следующее вхождение)
}
```

---

## 8. Кеширование в Redis

Redis используется как единый кеш-слой для снижения нагрузки на PostgreSQL. Ключи структурированы по домену и идентификатору ресурса.

### Реестр кеш-ключей

```
Ключ                              TTL     Содержимое
────────────────────────────────────────────────────────────────────
cache:user:{userId}               1h      UserProfile (без пароля)
cache:accounts:{userId}           30min   Account[] с балансами
cache:dashboard:{userId}          5min    DashboardSummary
cache:predictions:{accountId}     15min   PredictionResult[]
cache:categories:system           24h     Category[] (системные)
cache:transactions:{accountId}    5min    Последние 50 транзакций
cache:import-job:{jobId}          1h      ImportJob статус
```

### Стратегия инвалидации

Применяется паттерн **Write-Through Invalidation**: при любой мутирующей операции соответствующие ключи удаляются синхронно, до ответа клиенту.

```typescript
// Пример: при создании транзакции
async createTransaction(dto: CreateTransactionDto) {
  const tx = await this.txRepository.create(dto);

  // Инвалидировать связанные кеши
  await this.redis.del(`cache:accounts:${dto.userId}`);
  await this.redis.del(`cache:dashboard:${dto.userId}`);
  await this.redis.del(`cache:transactions:${dto.accountId}`);
  await this.redis.del(`cache:predictions:${dto.accountId}`);

  // Оповестить через NATS (для других инстансов)
  await this.nats.publish('transaction.created', { userId: dto.userId, accountId: dto.accountId });

  return tx;
}
```

**Broadcast-инвалидация при горизонтальном масштабировании:** когда один инстанс сервиса инвалидирует ключ, он публикует событие в NATS. Остальные инстансы получают событие и также удаляют свои локальные копии (если применяется in-memory cache поверх Redis).

### Стратегия при cache miss

```
Client Request
    │
    ▼
Redis GET key
    │
    ├─ HIT ──────────────────────────────► Return cached value
    │
    └─ MISS
         │
         ▼
    PostgreSQL SELECT
         │
         ▼
    Redis SET key value EX {ttl}
         │
         ▼
    Return value
```

---

## 9. Real-time через Socket.IO

Socket.IO обеспечивает двунаправленную связь между сервером и клиентами для получения обновлений без опроса (polling).

### Жизненный цикл соединения

```
1. HANDSHAKE
   ─────────
   Flutter SDK устанавливает соединение:
     wss://api.anticifi.com/socket.io/?token=<accessToken>

2. AUTHENTICATION MIDDLEWARE
   ─────────────────────────
   Server-side middleware (до accept соединения):
     ├─ Извлекает token из handshake.auth.token
     ├─ Проверяет JWT (RS256)
     ├─ Загружает userId из payload
     └─ REJECT если токен истёк / невалиден

3. AUTO-JOIN ROOMS
   ────────────────
   После успешной аутентификации:
     socket.join(`user:${userId}`)

4. ACCOUNT ROOM SUBSCRIPTION
   ──────────────────────────
   Клиент отправляет: emit("subscribe:account", { accountId })
   Server: socket.join(`account:${accountId}`)
           (с проверкой, что accountId принадлежит userId)

5. EVENT DISPATCH
   ──────────────
   API Gateway получает событие из NATS:
     └─► io.to(`user:${userId}`).emit(eventName, payload)
     └─► io.to(`account:${accountId}`).emit(eventName, payload)

6. DISCONNECTION
   ─────────────
   socket.on('disconnect'):
     ├─ Socket.IO автоматически удаляет из всех rooms
     └─ Логируется для аналитики активных сессий
```

### Реестр событий (Server → Client)

```
Событие                   Данные                      Когда
────────────────────────────────────────────────────────────────────────
import:progress           { jobId, percent, processed } В процессе импорта
import:completed          { jobId, imported, skipped } Импорт завершён
import:failed             { jobId, error }             Импорт упал
transaction:created       { transaction }              Новая транзакция
transaction:updated       { transaction }              Обновлена транзакция
account:balance:updated   { accountId, balance }       Изменился баланс
predictions:updated       { accountId }                Готовы новые прогнозы
notification:new          { notification }             Входящее уведомление
```

### Горизонтальное масштабирование Socket.IO

При запуске нескольких инстансов API Gateway Socket.IO использует **Redis Adapter** для синхронизации состояния комнат:

```typescript
// main.ts
import { createAdapter } from '@socket.io/redis-adapter';

const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();
io.adapter(createAdapter(pubClient, subClient));
```

Это позволяет любому инстансу Gateway публиковать событие в комнату, даже если сокет клиента подключён к другому инстансу.

---

## 10. Prediction Engine: архитектура ML-движка

Предиктивный движок — ключевая ценность продукта. Архитектура рассчитана на точность предсказаний при минимальной истории данных (от 30 дней).

### Архитектурная схема

```
┌─────────────────────────────────────────────────────────┐
│                    INPUT LAYER                           │
│                                                         │
│  Transaction history    Scheduled payments   Balance    │
│  (last 90 days)         (future dates)       (current)  │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                 FEATURE EXTRACTION                       │
│                                                         │
│  Daily aggregation:       Temporal features:            │
│  ├─ income_total          ├─ day_of_week (0-6)          │
│  ├─ expense_total         ├─ day_of_month (1-31)        │
│  ├─ net_flow              ├─ week_of_month              │
│  └─ category breakdown    └─ month_of_year              │
│                                                         │
│  Statistical features:    Income features:              │
│  ├─ 7d rolling avg        ├─ income_regularity_score    │
│  ├─ 30d rolling avg       ├─ avg_income_amount          │
│  └─ volatility (σ)        └─ income_day_pattern         │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                  ENSEMBLE MODELS                         │
│                                                         │
│  ┌──────────────────┐  ┌──────────────────────────────┐ │
│  │  Prophet         │  │  LSTM Neural Network          │ │
│  │  (Time Series)   │  │  (Pattern Recognition)        │ │
│  │                  │  │                               │ │
│  │  Handles:        │  │  Architecture:                │ │
│  │  ├─ Seasonality  │  │  ├─ Input: 30-day window      │ │
│  │  ├─ Trends       │  │  ├─ 2x LSTM layers (64 units) │ │
│  │  └─ Holidays     │  │  ├─ Dropout 0.2               │ │
│  │                  │  │  └─ Dense output layer         │ │
│  │  Weight: 0.4     │  │  Weight: 0.4                  │ │
│  └──────────────────┘  └──────────────────────────────┘ │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Deterministic Rule Engine                        │   │
│  │                                                   │   │
│  │  Scheduled payments: точная сумма в точную дату   │   │
│  │  Weight: 0.2 (override для известных платежей)    │   │
│  └──────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                   ENSEMBLE FUSION                        │
│                                                         │
│  Weighted average с динамической коррекцией весов:      │
│  ├─ При малой истории (<30 дней): Prophet weight += 0.2 │
│  ├─ При высокой волатильности: LSTM weight += 0.1       │
│  └─ Scheduled payments: детерминистический override     │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                   OUTPUT LAYER                           │
│                                                         │
│  Для каждого дня в горизонте [30 / 60 / 90 дней]:       │
│  {                                                      │
│    date: "2026-03-15",                                  │
│    predicted_balance: 1250.00,                          │
│    lower_bound: 980.00,     // 95% confidence           │
│    upper_bound: 1520.00,                                │
│    confidence_score: 0.87,  // 0.0 - 1.0               │
│    risk_level: "low"        // low | medium | high      │
│  }                                                      │
└─────────────────────────────────────────────────────────┘
```

### FastAPI эндпоинты ML-сервиса

```
POST /predict
  Body: {
    transactions: Transaction[],
    scheduled_payments: ScheduledPayment[],
    current_balance: number,
    account_id: string,
    horizon_days: 30 | 60 | 90
  }
  Response: { predictions: DayPrediction[] }

GET /health
  Response: { status: "ok", models_loaded: true }

POST /retrain
  Body: { account_id: string }
  — Переобучить модель для конкретного аккаунта (персонализация)
```

### Холодный старт (новый пользователь)

При недостаточной истории (< 14 дней) применяется **cold start strategy**:

1. Prophet работает на глобальной модели (усреднённые паттерны по всем пользователям той же страны/категории)
2. LSTM пропускается
3. Confidence score снижается пропорционально нехватке данных
4. Пользователю показывается предупреждение: "Прогноз станет точнее через N дней"

---

## 11. Принципы масштабирования

### Горизонтальное масштабирование

Каждый сервис спроектирован как stateless и может быть масштабирован независимо:

```
Компонент          Stateless?  Как масштабируется
──────────────────────────────────────────────────────────────
Nginx              Да          L4/L7 load balancer выше
API Gateway        Да          Несколько инстансов, Socket.IO → Redis Adapter
Import Service     Да          Bull Queue обеспечивает единую очередь
Transaction Svc    Да          Stateless NATS subscriber
Prediction Svc     Да          NATS queue group — один обрабатывает задачу
Notification Svc   Да          Bull Queue, идемпотентные отправки
Python ML          Частично    Stateless инференс; модели в shared volume
PostgreSQL         Нет         Read replicas для SELECT-heavy queries
Redis              Нет         Redis Cluster или Sentinel
```

### Bottlenecks и митигация

| Потенциальный bottleneck | Митигация |
|---|---|
| CSV парсинг больших файлов (>50MB) | Streaming parser, chunked processing, лимит 10MB на MVP |
| ML инференс (> 5 сек для 90 дней) | Async через NATS + Bull; результат через Socket.IO |
| PostgreSQL при bulk insert | Bulk INSERT с `ON CONFLICT DO NOTHING`; подготовленные запросы |
| Redis перегрузка | TTL на все ключи; `maxmemory-policy allkeys-lru` |
| Socket.IO при тысячах соединений | Redis Adapter + горизонтальное масштабирование Gateway |

---

## 12. Безопасность

### Аутентификация и авторизация

```
Схема: JWT (RS256)
  ├─ Access Token:  15 минут, payload: { userId, email, plan }
  ├─ Refresh Token: 30 дней, хранится в httpOnly cookie
  └─ Ротация:       каждый refresh выдаёт новую пару токенов

Авторизация:
  └─ Каждый запрос проходит Guards:
       AuthGuard       — проверка JWT
       OwnershipGuard  — проверка, что ресурс принадлежит userId
```

### Защита данных

| Мера | Реализация |
|---|---|
| Транспорт | TLS 1.3 на Nginx; WSS для WebSocket |
| Пароли | bcrypt, cost factor 12 |
| Финансовые данные | Шифрование sensitive полей в БД (pgcrypto) |
| API Rate Limiting | Throttle: 100 req/min per userId, 20 req/min per IP |
| Input Validation | class-validator на каждом DTO |
| SQL Injection | Sequelize параметризованные запросы (ORM, no raw SQL) |
| CSV Injection | Санитизация значений перед INSERT |
| CORS | Whitelist разрешённых origins |

### Изоляция микросервисов

Сервисы общаются только через NATS и не имеют прямого HTTP-доступа друг к другу (за исключением Prediction Service → Python ML через внутреннюю Docker-сеть). Каждый сервис имеет собственный database schema или префикс таблиц для логической изоляции данных.

---

> Смежные документы:
> - [Техническое задание](./technical-spec.md) — функциональные и нефункциональные требования
> - [Спецификация API](./api-spec.md) — полный реестр REST-эндпоинтов с форматами запросов/ответов
> - [Инфраструктура и DevOps](./infrastructure.md) — Docker Compose конфигурация, CI/CD, мониторинг
> - [Схема базы данных](./database-schema.md) — модели данных, таблицы, индексы

---

*AnticiFi — Know your balance before it happens.*
