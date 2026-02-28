# Схема базы данных — AnticiFi

**Назад к:** [README](./README.md) | **Смежные документы:** [Техническое задание](./technical-spec.md) | [Спецификация API](./api-spec.md)

---

## Содержание

1. [Обзор и философия проектирования](#1-обзор-и-философия-проектирования)
2. [ER-диаграмма](#2-er-диаграмма)
3. [Сущности и таблицы](#3-сущности-и-таблицы)
   - 3.1 [User — пользователь](#31-user--пользователь)
   - 3.2 [Account — банковский счёт](#32-account--банковский-счёт)
   - 3.3 [Transaction — транзакция](#33-transaction--транзакция)
   - 3.4 [Category — категория](#34-category--категория)
   - 3.5 [ScheduledPayment — запланированный платёж](#35-scheduledpayment--запланированный-платёж)
   - 3.6 [Prediction — прогноз баланса](#36-prediction--прогноз-баланса)
   - 3.7 [ImportJob — задание на импорт](#37-importjob--задание-на-импорт)
4. [Стратегия индексирования](#4-стратегия-индексирования)
5. [Стратегия партиционирования таблицы Transaction](#5-стратегия-партиционирования-таблицы-transaction)
6. [Особенности Sequelize](#6-особенности-sequelize)
   - 6.1 [Soft delete (paranoid)](#61-soft-delete-paranoid)
   - 6.2 [Хуки (Hooks)](#62-хуки-hooks)
   - 6.3 [Миграции](#63-миграции)
   - 6.4 [Сидеры системных категорий](#64-сидеры-системных-категорий)
7. [Дедупликация транзакций через transactionHash](#7-дедупликация-транзакций-через-transactionhash)
8. [Соглашения и ограничения](#8-соглашения-и-ограничения)

---

## 1. Обзор и философия проектирования

AnticiFi — предиктивный финансовый ассистент. Схема базы данных отражает два ключевых направления системы:

- **Ретроспективный слой** — хранение реальных транзакций, счетов и категорий, импортируемых из банковских выписок и чеков. Этот слой является источником данных для обучения и работы AI-модели.
- **Предиктивный слой** — хранение прогнозов баланса (`Prediction`) с привязкой к версии модели, уровнем уверенности и разбивкой по факторам. Ретроактивное заполнение фактического баланса позволяет отслеживать точность прогнозов.

**Основные архитектурные решения:**

| Решение | Обоснование |
|---|---|
| PostgreSQL как основная БД | JSONB для гибких метаданных, нативное секционирование, транзакционность ACID, зрелость инструментов |
| UUID как первичные ключи | Безопасное распределённое генерирование ID без центрального счётчика; не раскрывает количество записей через инкремент |
| DECIMAL(15,2) для сумм | Точное хранение денежных значений без погрешностей floating point; поддерживает суммы до 9 999 999 999 999,99 |
| Soft delete только на User | Пользователь удаляется логически, его финансовые данные сохраняются для аудита; каскадное удаление защищает от осиротевших записей |
| transactionHash (SHA-256) | Идемпотентный импорт: повторный запуск CSV-импорта не создаёт дубликаты |
| JSONB для metadata и factors | Схема данных из разных банков различается; предиктивные факторы эволюционируют с версиями модели |

**Целевая СУБД:** PostgreSQL 15+

**ORM:** Sequelize 6 (Node.js, TypeScript)

---

## 2. ER-диаграмма

Ниже представлено текстовое описание связей между сущностями. Стрелки обозначают направление внешнего ключа (от дочерней таблицы к родительской).

```
┌─────────────────────────────────────────────────────────────────────┐
│                              User                                    │
│  id (PK)  email  passwordHash  firstName  lastName  currency  ...   │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 1
           ┌────────────────┼──────────────────────┐
           │ N              │ N                     │ N (nullable)
           ▼                ▼                       ▼
   ┌──────────────┐  ┌──────────────┐      ┌──────────────┐
   │   Account    │  │  ImportJob   │      │   Category   │
   │  id (PK)     │  │  id (PK)     │      │  id (PK)     │
   │  userId (FK) │  │  userId (FK) │      │  userId (FK) │
   │  name        │  │  accountId   │      │  name        │
   │  type        │  │  (FK)        │      │  type        │
   │  balance     │  │  type        │      │  isSystem    │
   │  currency    │  │  status      │      └──────┬───────┘
   └──────┬───────┘  └──────────────┘             │ 1
          │ 1                                      │
     ┌────┼─────────────────────────────┐          │ N (nullable)
     │ N  │ N                  │ N      │          │
     ▼    ▼                    ▼        │          │
┌──────────────┐  ┌──────────────────┐ │          │
│ Transaction  │  │ ScheduledPayment │ │          │
│  id (PK)     │  │  id (PK)         │ │          │
│  accountId   │  │  accountId (FK)  │ │          │
│  (FK)        │  │  name            │ │          │
│  type        │  │  amount          │ │          │
│  amount      │  │  frequency       │ │          │
│  description │  │  nextDueDate     │ │          │
│  date        │  │  categoryId (FK) ├─┘          │
│  categoryId  ├──┘  isActive        │            │
│  (FK)        │  └──────────────────┘            │
│  source      │                                  │
│  importJobId │◄─── ImportJob.id (nullable FK)   │
│  (FK)        │                                  │
│  transHash   │◄─────────────────────────────────┘
└──────────────┘          categoryId (FK) → Category.id

┌──────────────────────────────────────┐
│            Prediction                │
│  id (PK)                             │
│  accountId (FK) → Account.id         │
│  targetDate                          │
│  predictedBalance                    │
│  confidence (0.0000–1.0000)          │
│  modelVersion                        │
│  factors (JSONB)                     │
│  actualBalance (nullable)            │
└──────────────────────────────────────┘
```

**Ключевые связи:**

| Родительская таблица | Дочерняя таблица | Тип | ON DELETE |
|---|---|---|---|
| User | Account | 1:N | CASCADE |
| User | ImportJob | 1:N | RESTRICT |
| User | Category | 1:N (nullable) | SET NULL |
| Account | Transaction | 1:N | CASCADE |
| Account | ScheduledPayment | 1:N | CASCADE |
| Account | Prediction | 1:N | CASCADE |
| Account | ImportJob | 1:N | RESTRICT |
| Category | Transaction | 1:N (nullable) | SET NULL |
| Category | ScheduledPayment | 1:N (nullable) | SET NULL |
| ImportJob | Transaction | 1:N (nullable) | SET NULL |

---

## 3. Сущности и таблицы

### 3.1 User — пользователь

Центральная сущность системы. Хранит учётные данные и настройки пользователя. Поддерживает мягкое удаление (`paranoid: true` в Sequelize).

**Таблица:** `users`

| Колонка | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Уникальный идентификатор |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | Email-адрес, используется для входа |
| `passwordHash` | VARCHAR(255) | NOT NULL | Хеш пароля (bcrypt, cost factor 12) |
| `firstName` | VARCHAR(100) | NULL | Имя пользователя |
| `lastName` | VARCHAR(100) | NULL | Фамилия пользователя |
| `avatarUrl` | VARCHAR(500) | NULL | URL аватара (CDN или S3) |
| `currency` | VARCHAR(3) | DEFAULT 'USD' | ISO 4217 — валюта по умолчанию |
| `isEmailVerified` | BOOLEAN | DEFAULT false, NOT NULL | Флаг подтверждения email |
| `lastLoginAt` | TIMESTAMP WITH TIME ZONE | NULL | Время последнего входа |
| `createdAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата создания записи |
| `updatedAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата последнего обновления |
| `deletedAt` | TIMESTAMP WITH TIME ZONE | NULL | Дата мягкого удаления (paranoid) |

**Индексы:**

| Имя индекса | Колонки | Тип | Обоснование |
|---|---|---|---|
| `users_email_unique` | `email` | UNIQUE | Быстрый поиск при аутентификации; гарантирует уникальность |
| `users_deleted_at_idx` | `deletedAt` | B-Tree (partial: IS NOT NULL) | Эффективная фильтрация удалённых пользователей |

**Пример SQL:**

```sql
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name  VARCHAR(100),
  last_name   VARCHAR(100),
  avatar_url  VARCHAR(500),
  currency    VARCHAR(3) NOT NULL DEFAULT 'USD',
  is_email_verified BOOLEAN NOT NULL DEFAULT false,
  last_login_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ,
  CONSTRAINT users_email_unique UNIQUE (email)
);

CREATE INDEX users_deleted_at_idx ON users (deleted_at)
  WHERE deleted_at IS NOT NULL;
```

**Заметки:**
- Поле `deletedAt` управляется Sequelize автоматически при `paranoid: true`. Запросы через ORM автоматически добавляют условие `WHERE deleted_at IS NULL`.
- `currency` используется как валюта по умолчанию при создании нового счёта. Формат: трёхбуквенный код ISO 4217 (USD, EUR, UAH и т.д.).
- `avatarUrl` хранит внешнюю ссылку; бинарные данные изображения не хранятся в БД.

---

### 3.2 Account — банковский счёт

Представляет финансовый счёт пользователя. Один пользователь может иметь несколько счетов разных типов. Баланс хранится как снимок текущего состояния и обновляется при каждой операции.

**Таблица:** `accounts`

| Колонка | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Уникальный идентификатор |
| `userId` | UUID | FK → users.id, NOT NULL, ON DELETE CASCADE | Владелец счёта |
| `name` | VARCHAR(100) | NOT NULL | Человекочитаемое название счёта |
| `type` | ENUM | NOT NULL | Тип счёта (см. ниже) |
| `balance` | DECIMAL(15,2) | NOT NULL, DEFAULT 0 | Текущий баланс |
| `currency` | VARCHAR(3) | NOT NULL, DEFAULT 'USD' | Валюта счёта (ISO 4217) |
| `isActive` | BOOLEAN | NOT NULL, DEFAULT true | Флаг активности (архивирование без удаления) |
| `createdAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата создания |
| `updatedAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата последнего обновления |

**ENUM `account_type`:**

| Значение | Описание |
|---|---|
| `checking` | Расчётный (текущий) счёт |
| `savings` | Сберегательный счёт |
| `credit` | Кредитная карта / кредитная линия |
| `cash` | Наличные (виртуальный счёт) |

**Индексы:**

| Имя индекса | Колонки | Тип | Обоснование |
|---|---|---|---|
| `accounts_user_id_idx` | `userId` | B-Tree | Выборка всех счетов пользователя |
| `accounts_user_name_unique` | `(userId, name)` | UNIQUE | Предотвращение дублирования названий счетов у одного пользователя |

**Пример SQL:**

```sql
CREATE TYPE account_type AS ENUM ('checking', 'savings', 'credit', 'cash');

CREATE TABLE accounts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name        VARCHAR(100) NOT NULL,
  type        account_type NOT NULL,
  balance     DECIMAL(15,2) NOT NULL DEFAULT 0,
  currency    VARCHAR(3) NOT NULL DEFAULT 'USD',
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT accounts_user_name_unique UNIQUE (user_id, name)
);

CREATE INDEX accounts_user_id_idx ON accounts (user_id);
```

**Заметки:**
- `balance` является денормализованным полем — производным от суммы всех транзакций. Это осознанный компромисс в пользу производительности: чтение баланса происходит значительно чаще, чем изменение. При каждой записи транзакции обновляется атомарно в рамках одной транзакции БД.
- `isActive = false` используется для архивирования счёта без удаления истории транзакций.
- Поддержка нескольких валют в одном аккаунте пользователя предполагает конвертацию при агрегации — логика конвертации вынесена на уровень сервиса.

---

### 3.3 Transaction — транзакция

Ключевая рабочая таблица системы. Хранит все финансовые операции: ручные записи, импортированные из CSV, извлечённые через OCR. Является основным источником данных для предиктивного движка.

**Таблица:** `transactions`

| Колонка | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Уникальный идентификатор |
| `accountId` | UUID | FK → accounts.id, NOT NULL, ON DELETE CASCADE | Счёт, к которому относится операция |
| `transactionHash` | VARCHAR(64) | UNIQUE, NOT NULL | SHA-256 хеш для дедупликации |
| `type` | ENUM | NOT NULL | Тип операции (см. ниже) |
| `amount` | DECIMAL(15,2) | NOT NULL | Сумма операции (всегда положительная) |
| `description` | VARCHAR(500) | NULL | Описание / назначение платежа |
| `categoryId` | UUID | FK → categories.id, NULL, ON DELETE SET NULL | Категория расхода/дохода |
| `date` | DATE | NOT NULL | Дата операции (без времени) |
| `source` | ENUM | NOT NULL | Источник создания записи (см. ниже) |
| `importJobId` | UUID | FK → import_jobs.id, NULL, ON DELETE SET NULL | Ссылка на задание импорта |
| `metadata` | JSONB | NULL, DEFAULT '{}' | Дополнительные данные из источника |
| `createdAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата создания записи |
| `updatedAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата последнего обновления |

**ENUM `transaction_type`:**

| Значение | Описание |
|---|---|
| `income` | Доход (зачисление на счёт) |
| `expense` | Расход (списание со счёта) |
| `transfer` | Перевод между счетами пользователя |

**ENUM `transaction_source`:**

| Значение | Описание |
|---|---|
| `manual` | Введено пользователем вручную |
| `csv_import` | Импортировано из CSV-файла банковской выписки |
| `ocr` | Извлечено из фотографии чека через OCR |
| `api` | Получено через банковский API (будущий функционал) |

**Индексы:**

| Имя индекса | Колонки | Тип | Обоснование |
|---|---|---|---|
| `transactions_account_id_idx` | `accountId` | B-Tree | Выборка транзакций по счёту |
| `transactions_hash_unique` | `transactionHash` | UNIQUE | Дедупликация при импорте |
| `transactions_date_idx` | `date` | B-Tree | Диапазонные запросы по дате для прогнозирования |
| `transactions_category_id_idx` | `categoryId` | B-Tree | Агрегация расходов по категориям |
| `transactions_account_date_idx` | `(accountId, date)` | B-Tree (composite) | Основной запрос: история операций по счёту за период |

**Структура поля `metadata` (JSONB):**

Содержимое зависит от источника (`source`). Примеры:

```jsonc
// source: 'csv_import'
{
  "originalRow": 42,
  "rawAmount": "-1500.00",
  "bank": "PrivatBank",
  "csvColumns": {
    "date": "28.02.2026",
    "debit": "1500.00",
    "credit": "",
    "balance": "8540.00",
    "reference": "UA12345"
  }
}

// source: 'ocr'
{
  "receiptId": "ocr-job-uuid",
  "confidence": 0.94,
  "merchant": "Silpo Supermarket",
  "rawText": "СІЛЬПО\n28/02/26\nСума: 347.80 грн"
}

// source: 'api'
{
  "bankTransactionId": "TXN-ABC-123",
  "bankName": "Monobank",
  "mcc": 5411,
  "hold": false
}
```

**Пример SQL:**

```sql
CREATE TYPE transaction_type   AS ENUM ('income', 'expense', 'transfer');
CREATE TYPE transaction_source AS ENUM ('manual', 'csv_import', 'ocr', 'api');

CREATE TABLE transactions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id       UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  transaction_hash VARCHAR(64) NOT NULL,
  type             transaction_type NOT NULL,
  amount           DECIMAL(15,2) NOT NULL,
  description      VARCHAR(500),
  category_id      UUID REFERENCES categories(id) ON DELETE SET NULL,
  date             DATE NOT NULL,
  source           transaction_source NOT NULL,
  import_job_id    UUID REFERENCES import_jobs(id) ON DELETE SET NULL,
  metadata         JSONB NOT NULL DEFAULT '{}',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT transactions_hash_unique UNIQUE (transaction_hash)
);

CREATE INDEX transactions_account_id_idx   ON transactions (account_id);
CREATE INDEX transactions_date_idx         ON transactions (date);
CREATE INDEX transactions_category_id_idx  ON transactions (category_id);
CREATE INDEX transactions_account_date_idx ON transactions (account_id, date);
```

**Заметки:**
- `amount` всегда хранится как положительное число. Знак операции определяется полем `type`: `income` увеличивает баланс, `expense` — уменьшает. Это упрощает агрегацию и исключает ошибки знака.
- `date` имеет тип `DATE` (без времени), так как банковские выписки оперируют датами, а не точными временными метками. Это также корректно для прогнозирования на уровне дней.
- Для `transfer` создаются две транзакции: одна `expense` на счёте-источнике, одна `income` на счёте-получателе. Связь между ними хранится в `metadata.linkedTransactionId`.

---

### 3.4 Category — категория

Хранит категории расходов и доходов. Поддерживает два типа: системные категории (общие для всех пользователей, `isSystem = true`, `userId = NULL`) и пользовательские категории (созданные конкретным пользователем).

**Таблица:** `categories`

| Колонка | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Уникальный идентификатор |
| `userId` | UUID | FK → users.id, NULL, ON DELETE CASCADE | Владелец; NULL для системных категорий |
| `name` | VARCHAR(100) | NOT NULL | Название категории |
| `icon` | VARCHAR(50) | NULL | Имя иконки (из icon-set, например: 'shopping-cart') |
| `color` | VARCHAR(7) | NULL | HEX-цвет (#RRGGBB) для UI |
| `type` | ENUM | NOT NULL | Тип: доход или расход |
| `isSystem` | BOOLEAN | NOT NULL, DEFAULT false | true — системная (seeded), false — пользовательская |
| `createdAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата создания |
| `updatedAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата последнего обновления |

**ENUM `category_type`:**

| Значение | Описание |
|---|---|
| `income` | Категория для доходных транзакций |
| `expense` | Категория для расходных транзакций |

**Индексы:**

| Имя индекса | Колонки | Тип | Обоснование |
|---|---|---|---|
| `categories_user_name_unique` | `(userId, name)` | UNIQUE (partial: userId IS NOT NULL) | Уникальность пользовательских категорий по имени |
| `categories_is_system_idx` | `isSystem` | B-Tree (partial: isSystem = true) | Быстрая выборка системных категорий |

**Пример SQL:**

```sql
CREATE TYPE category_type AS ENUM ('income', 'expense');

CREATE TABLE categories (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID REFERENCES users(id) ON DELETE CASCADE,
  name      VARCHAR(100) NOT NULL,
  icon      VARCHAR(50),
  color     VARCHAR(7),
  type      category_type NOT NULL,
  is_system BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Уникальность имени в рамках пользователя (только для пользовательских категорий)
CREATE UNIQUE INDEX categories_user_name_unique
  ON categories (user_id, name)
  WHERE user_id IS NOT NULL;

-- Быстрый доступ к системным категориям
CREATE INDEX categories_is_system_idx
  ON categories (is_system)
  WHERE is_system = true;
```

**Пример системных категорий (сидеры):**

| name | icon | color | type |
|---|---|---|---|
| Продукты | `shopping-basket` | `#4CAF50` | expense |
| Транспорт | `car` | `#2196F3` | expense |
| Жильё | `home` | `#9C27B0` | expense |
| Здоровье | `heart` | `#F44336` | expense |
| Развлечения | `music` | `#FF9800` | expense |
| Рестораны | `cutlery` | `#795548` | expense |
| Одежда | `shirt` | `#E91E63` | expense |
| Образование | `book` | `#607D8B` | expense |
| Коммунальные услуги | `bolt` | `#FFC107` | expense |
| Связь | `phone` | `#00BCD4` | expense |
| Зарплата | `briefcase` | `#4CAF50` | income |
| Фриланс | `laptop` | `#8BC34A` | income |
| Инвестиции | `trending-up` | `#009688` | income |
| Подарки | `gift` | `#E91E63` | income |
| Прочее | `ellipsis` | `#9E9E9E` | expense |

**Заметки:**
- При запросе категорий пользователю возвращаются системные категории (`isSystem = true`) плюс его персональные (`userId = currentUser.id`). Запрос: `WHERE user_id = :userId OR is_system = true`.
- Системные категории не могут быть изменены или удалены через API. Защита реализуется на уровне сервиса.
- `color` валидируется регулярным выражением `/^#[0-9A-F]{6}$/i` на уровне приложения.

---

### 3.5 ScheduledPayment — запланированный платёж

Хранит регулярные платежи: аренда, подписки, кредит, коммунальные услуги. Является вторым (после исторических транзакций) источником данных для прогнозирования баланса.

**Таблица:** `scheduled_payments`

| Колонка | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Уникальный идентификатор |
| `accountId` | UUID | FK → accounts.id, NOT NULL, ON DELETE CASCADE | Счёт, к которому привязан платёж |
| `name` | VARCHAR(200) | NOT NULL | Название платежа (напр. "Аренда квартиры") |
| `amount` | DECIMAL(15,2) | NOT NULL | Сумма платежа |
| `type` | ENUM (`income`, `expense`) | NOT NULL | Тип: доход или расход |
| `frequency` | ENUM | NOT NULL | Периодичность (см. ниже) |
| `nextDueDate` | DATE | NOT NULL | Дата следующего платежа |
| `endDate` | DATE | NULL | Дата окончания (NULL — бессрочно) |
| `categoryId` | UUID | FK → categories.id, NULL, ON DELETE SET NULL | Категория |
| `isActive` | BOOLEAN | NOT NULL, DEFAULT true | Флаг активности |
| `lastProcessedAt` | TIMESTAMP WITH TIME ZONE | NULL | Время последней обработки планировщиком |
| `createdAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата создания |
| `updatedAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Дата последнего обновления |

**ENUM `payment_frequency`:**

| Значение | Описание | Пример |
|---|---|---|
| `daily` | Ежедневно | Аренда посуточного жилья |
| `weekly` | Еженедельно | Еженедельная подписка |
| `biweekly` | Раз в две недели | Зарплата раз в две недели (US-практика) |
| `monthly` | Ежемесячно | Аренда, Netflix, кредит |
| `quarterly` | Ежеквартально | Квартальные налоги, страховка |
| `yearly` | Ежегодно | Доменное имя, годовая подписка |

**Индексы:**

| Имя индекса | Колонки | Тип | Обоснование |
|---|---|---|---|
| `scheduled_payments_account_id_idx` | `accountId` | B-Tree | Выборка платежей по счёту |
| `scheduled_payments_next_due_idx` | `nextDueDate` | B-Tree | Планировщик: выборка платежей к исполнению |
| `scheduled_payments_active_idx` | `isActive` | B-Tree (partial: isActive = true) | Быстрый доступ только к активным платежам |

**Пример SQL:**

```sql
CREATE TYPE payment_frequency AS ENUM (
  'daily', 'weekly', 'biweekly', 'monthly', 'quarterly', 'yearly'
);

CREATE TABLE scheduled_payments (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id        UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  name              VARCHAR(200) NOT NULL,
  amount            DECIMAL(15,2) NOT NULL,
  type              transaction_type NOT NULL,
  frequency         payment_frequency NOT NULL,
  next_due_date     DATE NOT NULL,
  end_date          DATE,
  category_id       UUID REFERENCES categories(id) ON DELETE SET NULL,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  last_processed_at TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX scheduled_payments_account_id_idx ON scheduled_payments (account_id);
CREATE INDEX scheduled_payments_next_due_idx   ON scheduled_payments (next_due_date);
CREATE INDEX scheduled_payments_active_idx     ON scheduled_payments (is_active)
  WHERE is_active = true;
```

**Логика обновления `nextDueDate`:**

После обработки платежа планировщик вычисляет следующую дату:

```typescript
function advanceNextDueDate(current: Date, frequency: PaymentFrequency): Date {
  const next = new Date(current);
  switch (frequency) {
    case 'daily':     next.setDate(next.getDate() + 1);         break;
    case 'weekly':    next.setDate(next.getDate() + 7);         break;
    case 'biweekly':  next.setDate(next.getDate() + 14);        break;
    case 'monthly':   next.setMonth(next.getMonth() + 1);       break;
    case 'quarterly': next.setMonth(next.getMonth() + 3);       break;
    case 'yearly':    next.setFullYear(next.getFullYear() + 1); break;
  }
  return next;
}
```

После обработки планировщик также обновляет `lastProcessedAt = NOW()`. Если `nextDueDate > endDate` — платёж деактивируется (`isActive = false`).

---

### 3.6 Prediction — прогноз баланса

Хранит результаты работы AI-предиктивного движка. Каждая запись — это прогноз баланса конкретного счёта на конкретную дату в будущем. После наступления целевой даты поле `actualBalance` заполняется фактическим значением для оценки точности модели.

**Таблица:** `predictions`

| Колонка | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Уникальный идентификатор |
| `accountId` | UUID | FK → accounts.id, NOT NULL, ON DELETE CASCADE | Счёт, для которого сделан прогноз |
| `targetDate` | DATE | NOT NULL | Целевая дата прогноза |
| `predictedBalance` | DECIMAL(15,2) | NOT NULL | Прогнозируемый баланс |
| `confidence` | DECIMAL(5,4) | NOT NULL | Уровень уверенности (0.0000–1.0000) |
| `modelVersion` | VARCHAR(50) | NOT NULL | Версия AI-модели (напр. "v1.2.0") |
| `factors` | JSONB | NOT NULL, DEFAULT '{}' | Разбивка факторов прогноза |
| `actualBalance` | DECIMAL(15,2) | NULL | Фактический баланс (заполняется ретроактивно) |
| `createdAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Время генерации прогноза |

> `updatedAt` отсутствует намеренно: записи прогнозов иммутабельны. `actualBalance` заполняется отдельным процессом без изменения остальных полей.

**Индексы:**

| Имя индекса | Колонки | Тип | Обоснование |
|---|---|---|---|
| `predictions_account_date_unique` | `(accountId, targetDate)` | UNIQUE | Один прогноз на счёт на дату (актуальная версия) |
| `predictions_target_date_idx` | `targetDate` | B-Tree | Выборка прогнозов для заполнения actualBalance |

**Структура поля `factors` (JSONB):**

```jsonc
{
  "scheduledPayments": [
    {
      "name": "Аренда квартиры",
      "amount": -15000.00,
      "date": "2026-03-01",
      "confidence": 1.0
    },
    {
      "name": "Зарплата",
      "amount": 45000.00,
      "date": "2026-03-10",
      "confidence": 0.95
    }
  ],
  "historicalTrend": {
    "averageDailyExpense": -850.50,
    "trendDirection": "stable",
    "windowDays": 90
  },
  "seasonality": {
    "detected": true,
    "pattern": "monthly",
    "adjustment": -1200.00
  },
  "anomalies": [
    {
      "type": "large_expense_expected",
      "amount": -5000.00,
      "probability": 0.3,
      "description": "Крупная трата в конце месяца (паттерн из истории)"
    }
  ]
}
```

**Пример SQL:**

```sql
CREATE TABLE predictions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id        UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  target_date       DATE NOT NULL,
  predicted_balance DECIMAL(15,2) NOT NULL,
  confidence        DECIMAL(5,4) NOT NULL
                    CHECK (confidence BETWEEN 0 AND 1),
  model_version     VARCHAR(50) NOT NULL,
  factors           JSONB NOT NULL DEFAULT '{}',
  actual_balance    DECIMAL(15,2),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT predictions_account_date_unique UNIQUE (account_id, target_date)
);

CREATE INDEX predictions_target_date_idx ON predictions (target_date);
```

**Жизненный цикл записи прогноза:**

```
1. Пользователь запрашивает прогноз на дату X
         ↓
2. Predictor Service генерирует прогноз
         ↓
3. INSERT INTO predictions (upsert по account_id + target_date)
         ↓
4. Дата X наступает (cron-задача раз в сутки)
         ↓
5. UPDATE predictions SET actual_balance = accounts.balance
   WHERE target_date = CURRENT_DATE AND actual_balance IS NULL
```

**Заметки:**
- Уникальный индекс `(accountId, targetDate)` означает, что при перезапуске прогноза (новая версия модели) выполняется `INSERT ... ON CONFLICT DO UPDATE` (upsert). Старый прогноз перезаписывается.
- Поле `confidence` с CHECK constraint гарантирует корректность значений на уровне БД.
- `modelVersion` позволяет ретроспективно анализировать, насколько точнее стала новая версия модели по сравнению с предыдущей.

---

### 3.7 ImportJob — задание на импорт

Отслеживает статус и прогресс задания по импорту транзакций из CSV-файла или OCR-сканирования чека. Обеспечивает видимость процесса для пользователя и возможность диагностики ошибок.

**Таблица:** `import_jobs`

| Колонка | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Уникальный идентификатор задания |
| `userId` | UUID | FK → users.id, NOT NULL | Пользователь, инициировавший импорт |
| `accountId` | UUID | FK → accounts.id, NOT NULL | Целевой счёт для импорта |
| `type` | ENUM | NOT NULL | Тип импорта: CSV или OCR |
| `status` | ENUM | NOT NULL, DEFAULT 'pending' | Текущий статус задания |
| `fileName` | VARCHAR(255) | NULL | Исходное имя загруженного файла |
| `totalRows` | INTEGER | NULL | Общее количество строк в файле |
| `processedRows` | INTEGER | NOT NULL, DEFAULT 0 | Количество успешно обработанных строк |
| `skippedRows` | INTEGER | NOT NULL, DEFAULT 0 | Количество пропущенных строк (дубликаты) |
| `errorMessage` | TEXT | NULL | Сообщение об ошибке (при status = 'failed') |
| `createdAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Время создания задания |
| `updatedAt` | TIMESTAMP WITH TIME ZONE | NOT NULL | Время последнего обновления |

**ENUM `import_job_type`:**

| Значение | Описание |
|---|---|
| `csv` | Импорт из CSV-файла банковской выписки |
| `ocr` | Извлечение данных из фотографии чека |

**ENUM `import_job_status`:**

| Значение | Описание |
|---|---|
| `pending` | Задание создано, ожидает обработки в очереди |
| `processing` | Задание в процессе выполнения |
| `completed` | Импорт завершён успешно |
| `failed` | Импорт завершился с ошибкой |

**Индексы:**

| Имя индекса | Колонки | Тип | Обоснование |
|---|---|---|---|
| `import_jobs_user_id_idx` | `userId` | B-Tree | История импортов пользователя |
| `import_jobs_status_idx` | `status` | B-Tree (partial: status IN ('pending', 'processing')) | Планировщик: поиск незавершённых заданий |

**Пример SQL:**

```sql
CREATE TYPE import_job_type   AS ENUM ('csv', 'ocr');
CREATE TYPE import_job_status AS ENUM ('pending', 'processing', 'completed', 'failed');

CREATE TABLE import_jobs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES users(id),
  account_id     UUID NOT NULL REFERENCES accounts(id),
  type           import_job_type NOT NULL,
  status         import_job_status NOT NULL DEFAULT 'pending',
  file_name      VARCHAR(255),
  total_rows     INTEGER,
  processed_rows INTEGER NOT NULL DEFAULT 0,
  skipped_rows   INTEGER NOT NULL DEFAULT 0,
  error_message  TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX import_jobs_user_id_idx ON import_jobs (user_id);
CREATE INDEX import_jobs_status_idx  ON import_jobs (status)
  WHERE status IN ('pending', 'processing');
```

**Жизненный цикл задания:**

```
pending → processing → completed
                    ↘ failed
```

Обработка выполняется воркером Bull Queue (Redis). Прогресс обновляется в реальном времени через Socket.IO: клиент подписывается на события `import:progress:{jobId}` и `import:completed:{jobId}`.

---

## 4. Стратегия индексирования

### Принципы выбора индексов

При проектировании индексной стратегии применялось правило: индекс создаётся только при наличии конкретного запроса, который без него будет выполнять seq scan по большой таблице.

**Типы индексов в схеме:**

| Тип | Применение | Таблицы |
|---|---|---|
| **B-Tree (default)** | Точный поиск, диапазоны, сортировка | Все таблицы |
| **UNIQUE** | Гарантия уникальности + автоматический индекс | users.email, transactions.transaction_hash, predictions.(account_id, target_date) |
| **Partial index** | Индексирование только части строк (WHERE clause) | import_jobs (только активные), categories (только системные), users (только удалённые) |
| **Composite** | Покрытие многоколоночных WHERE/JOIN | transactions.(account_id, date), accounts.(user_id, name) |

### Сводная таблица всех индексов

| Таблица | Индекс | Колонки | Тип |
|---|---|---|---|
| users | `users_email_unique` | email | UNIQUE |
| users | `users_deleted_at_idx` | deleted_at | Partial (IS NOT NULL) |
| accounts | `accounts_user_id_idx` | user_id | B-Tree |
| accounts | `accounts_user_name_unique` | (user_id, name) | UNIQUE |
| transactions | `transactions_account_id_idx` | account_id | B-Tree |
| transactions | `transactions_hash_unique` | transaction_hash | UNIQUE |
| transactions | `transactions_date_idx` | date | B-Tree |
| transactions | `transactions_category_id_idx` | category_id | B-Tree |
| transactions | `transactions_account_date_idx` | (account_id, date) | Composite |
| categories | `categories_user_name_unique` | (user_id, name) | Partial UNIQUE |
| categories | `categories_is_system_idx` | is_system | Partial B-Tree |
| scheduled_payments | `scheduled_payments_account_id_idx` | account_id | B-Tree |
| scheduled_payments | `scheduled_payments_next_due_idx` | next_due_date | B-Tree |
| scheduled_payments | `scheduled_payments_active_idx` | is_active | Partial B-Tree |
| predictions | `predictions_account_date_unique` | (account_id, target_date) | UNIQUE |
| predictions | `predictions_target_date_idx` | target_date | B-Tree |
| import_jobs | `import_jobs_user_id_idx` | user_id | B-Tree |
| import_jobs | `import_jobs_status_idx` | status | Partial B-Tree |

### Почему не используется индекс на `transactions.description`

Поле `description` содержит произвольный текст. Поиск по нему выполняется через `ILIKE '%keyword%'`, который не использует обычный B-Tree индекс. При необходимости полнотекстового поиска следует добавить GIN-индекс на `to_tsvector('russian', description)`. Это отложено на пост-MVP фазу.

---

## 5. Стратегия партиционирования таблицы Transaction

### Проблема

Таблица `transactions` — самая быстрорастущая в системе. При 100 активных пользователях со средней историей 5 лет и 30 транзакциями в месяц: `100 * 60 * 30 = 180 000 строк`. При масштабировании до 10 000 пользователей — 18 миллионов строк.

Запросы предиктивного движка типично обращаются к последним 90–365 дням. Без партиционирования планировщик PostgreSQL будет сканировать всю таблицу.

### Стратегия: партиционирование по диапазону дат

```sql
-- Основная таблица — партиционированная
CREATE TABLE transactions (
  id               UUID NOT NULL DEFAULT gen_random_uuid(),
  account_id       UUID NOT NULL,
  transaction_hash VARCHAR(64) NOT NULL,
  type             transaction_type NOT NULL,
  amount           DECIMAL(15,2) NOT NULL,
  description      VARCHAR(500),
  category_id      UUID,
  date             DATE NOT NULL,
  source           transaction_source NOT NULL,
  import_job_id    UUID,
  metadata         JSONB NOT NULL DEFAULT '{}',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (date);

-- Партиции по кварталам (пример для 2025–2026)
CREATE TABLE transactions_2025_q1
  PARTITION OF transactions
  FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE transactions_2025_q2
  PARTITION OF transactions
  FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE transactions_2025_q3
  PARTITION OF transactions
  FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

CREATE TABLE transactions_2025_q4
  PARTITION OF transactions
  FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

CREATE TABLE transactions_2026_q1
  PARTITION OF transactions
  FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

-- Индексы создаются на уровне партиций автоматически
-- (если создать на родительской таблице — распространяются на все партиции)
CREATE INDEX ON transactions (account_id, date);
CREATE UNIQUE INDEX ON transactions (transaction_hash);
```

### Автоматическое создание партиций

Для production-среды рекомендуется использовать расширение `pg_partman`:

```sql
-- Установка pg_partman
CREATE EXTENSION pg_partman;

-- Настройка автоматического создания ежеквартальных партиций
SELECT create_parent(
  p_parent_table := 'public.transactions',
  p_control      := 'date',
  p_type         := 'range',
  p_interval     := '3 months',
  p_premake      := 4  -- создавать 4 партиции наперёд
);

-- Запуск обслуживания (в cron раз в день)
SELECT run_maintenance('public.transactions');
```

### Преимущества партиционирования

| Аспект | Без партиционирования | С партиционированием |
|---|---|---|
| Запрос за последние 90 дней | Seq scan по всей таблице | Scan только 1 партиции (квартал) |
| Удаление старых данных | DELETE (медленно, bloat) | DROP PARTITION (мгновенно) |
| Vacuum | По всей таблице | По отдельным партициям |
| Производительность индекса | Деградирует при росте | Индексы меньше, быстрее |

### Ограничения

- `UNIQUE` индекс на `transaction_hash` в партиционированной таблице должен включать колонку партиционирования (`date`). Это означает, что `UNIQUE (transaction_hash)` становится `UNIQUE (transaction_hash, date)`. Дедупликация по хешу должна учитывать этот факт — проверка уникальности выполняется на уровне приложения (lookup перед insert), а не только на уровне constraint.

---

## 6. Особенности Sequelize

### 6.1 Soft delete (paranoid)

Модель `User` использует `paranoid: true`. Sequelize автоматически:
- Добавляет `WHERE deleted_at IS NULL` ко всем запросам
- При вызове `user.destroy()` выполняет `UPDATE users SET deleted_at = NOW()` вместо `DELETE`
- Для жёсткого удаления: `user.destroy({ force: true })`

```typescript
// src/modules/user/user.model.ts
@Table({
  tableName: 'users',
  paranoid: true,       // включает soft delete
  underscored: true,    // snake_case колонки в БД
  timestamps: true,     // createdAt / updatedAt
})
export class User extends Model {
  @Column({ type: DataType.UUID, defaultValue: DataType.UUIDV4, primaryKey: true })
  id: string;

  @Column({ type: DataType.STRING(255), unique: true, allowNull: false })
  email: string;

  @Column({ type: DataType.STRING(255), allowNull: false })
  passwordHash: string;

  // ... остальные поля

  @DeletedAt
  deletedAt: Date;
}
```

### 6.2 Хуки (Hooks)

#### Хук хеширования пароля (User)

Выполняется до создания и обновления пользователя. Гарантирует, что пароль никогда не сохраняется в открытом виде.

```typescript
// src/modules/user/user.hooks.ts
import * as bcrypt from 'bcrypt';

const BCRYPT_ROUNDS = 12;

User.addHook('beforeCreate', async (user: User) => {
  if (user.passwordHash) {
    user.passwordHash = await bcrypt.hash(user.passwordHash, BCRYPT_ROUNDS);
  }
});

User.addHook('beforeUpdate', async (user: User) => {
  // Хешировать только если пароль действительно изменился
  if (user.changed('passwordHash')) {
    user.passwordHash = await bcrypt.hash(user.passwordHash, BCRYPT_ROUNDS);
  }
});
```

> Важно: хук на `beforeUpdate` использует `user.changed('passwordHash')` чтобы не перехешировать уже хешированное значение при обновлении других полей (email, firstName и т.д.).

#### Хук вычисления transactionHash (Transaction)

Выполняется до создания транзакции. Вычисляет детерминированный хеш для дедупликации.

```typescript
// src/modules/transaction/transaction.hooks.ts
import { createHash } from 'crypto';

Transaction.addHook('beforeCreate', (transaction: Transaction) => {
  const raw = [
    transaction.accountId,
    transaction.date,
    transaction.amount.toString(),
    (transaction.description ?? '').trim().toLowerCase(),
  ].join(':');

  transaction.transactionHash = createHash('sha256')
    .update(raw)
    .digest('hex');
});
```

Функция вычисления хеша должна быть детерминированной: одинаковые входные данные всегда дают одинаковый хеш. Поэтому `description` нормализуется: `trim()` и `toLowerCase()`.

### 6.3 Миграции

Все изменения схемы БД выполняются через пронумерованные миграции Sequelize. Ручное изменение схемы в production запрещено.

**Соглашение об именовании файлов:**

```
YYYYMMDDHHMMSS-описание-действия.ts
```

Примеры:

```
migrations/
├── 20260101000001-create-users.ts
├── 20260101000002-create-accounts.ts
├── 20260101000003-create-categories.ts
├── 20260101000004-create-import-jobs.ts
├── 20260101000005-create-transactions.ts
├── 20260101000006-create-scheduled-payments.ts
├── 20260101000007-create-predictions.ts
├── 20260215000001-add-avatar-url-to-users.ts
└── 20260228000001-add-metadata-index-to-transactions.ts
```

**Шаблон миграции:**

```typescript
// migrations/20260101000001-create-users.ts
import { QueryInterface, DataTypes } from 'sequelize';

module.exports = {
  async up(queryInterface: QueryInterface): Promise<void> {
    await queryInterface.createTable('users', {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      email: {
        type: DataTypes.STRING(255),
        allowNull: false,
        unique: true,
      },
      password_hash: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      // ... остальные колонки
      created_at: { type: DataTypes.DATE, allowNull: false },
      updated_at: { type: DataTypes.DATE, allowNull: false },
      deleted_at: { type: DataTypes.DATE, allowNull: true },
    });

    await queryInterface.addIndex('users', ['email'], {
      unique: true,
      name: 'users_email_unique',
    });
  },

  async down(queryInterface: QueryInterface): Promise<void> {
    await queryInterface.dropTable('users');
  },
};
```

**Команды:**

```bash
# Применить все pending-миграции
npm run migration:run
# npx sequelize-cli db:migrate

# Откатить последнюю миграцию
npm run migration:undo
# npx sequelize-cli db:migrate:undo

# Откатить все миграции
npm run migration:undo:all
# npx sequelize-cli db:migrate:undo:all

# Проверить статус миграций
npx sequelize-cli db:migrate:status
```

### 6.4 Сидеры системных категорий

Системные категории создаются через Sequelize seeders. Они запускаются один раз при первичном деплое и при создании тестовых окружений.

```typescript
// seeders/20260101000001-system-categories.ts
import { QueryInterface } from 'sequelize';
import { v4 as uuidv4 } from 'uuid';

const SYSTEM_CATEGORIES = [
  // Расходы
  { name: 'Продукты',          icon: 'shopping-basket', color: '#4CAF50', type: 'expense' },
  { name: 'Транспорт',         icon: 'car',             color: '#2196F3', type: 'expense' },
  { name: 'Жильё',             icon: 'home',            color: '#9C27B0', type: 'expense' },
  { name: 'Здоровье',          icon: 'heart',           color: '#F44336', type: 'expense' },
  { name: 'Развлечения',       icon: 'music',           color: '#FF9800', type: 'expense' },
  { name: 'Рестораны',         icon: 'cutlery',         color: '#795548', type: 'expense' },
  { name: 'Одежда',            icon: 'shirt',           color: '#E91E63', type: 'expense' },
  { name: 'Образование',       icon: 'book',            color: '#607D8B', type: 'expense' },
  { name: 'Коммунальные',      icon: 'bolt',            color: '#FFC107', type: 'expense' },
  { name: 'Связь',             icon: 'phone',           color: '#00BCD4', type: 'expense' },
  { name: 'Прочее',            icon: 'ellipsis',        color: '#9E9E9E', type: 'expense' },
  // Доходы
  { name: 'Зарплата',          icon: 'briefcase',       color: '#4CAF50', type: 'income'  },
  { name: 'Фриланс',           icon: 'laptop',          color: '#8BC34A', type: 'income'  },
  { name: 'Инвестиции',        icon: 'trending-up',     color: '#009688', type: 'income'  },
  { name: 'Подарки',           icon: 'gift',            color: '#E91E63', type: 'income'  },
];

const now = new Date();

module.exports = {
  async up(queryInterface: QueryInterface): Promise<void> {
    const records = SYSTEM_CATEGORIES.map(cat => ({
      id:         uuidv4(),
      user_id:    null,         // системная категория
      name:       cat.name,
      icon:       cat.icon,
      color:      cat.color,
      type:       cat.type,
      is_system:  true,
      created_at: now,
      updated_at: now,
    }));

    await queryInterface.bulkInsert('categories', records, {
      ignoreDuplicates: true,   // идемпотентный запуск
    });
  },

  async down(queryInterface: QueryInterface): Promise<void> {
    await queryInterface.bulkDelete('categories', { is_system: true });
  },
};
```

**Команды:**

```bash
# Запустить все сидеры
npx sequelize-cli db:seed:all

# Запустить конкретный сидер
npx sequelize-cli db:seed --seed 20260101000001-system-categories.ts
```

---

## 7. Дедупликация транзакций через transactionHash

### Проблема

При импорте CSV-файла пользователь может загрузить один и тот же файл повторно (случайно или намеренно). OCR может быть запущен на одном и том же чеке дважды. Без защиты это приведёт к дублированию транзакций и неверному балансу.

### Решение

Для каждой транзакции вычисляется SHA-256 хеш на основе четырёх полей, однозначно идентифицирующих операцию:

```
transactionHash = SHA-256( accountId + ":" + date + ":" + amount + ":" + normalizedDescription )
```

Нормализация `description`:
- `trim()` — удаление пробелов по краям
- `toLowerCase()` — приведение к нижнему регистру

Пример:

```typescript
const input = [
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',  // accountId
  '2026-02-28',                             // date
  '1500.00',                                // amount
  'оплата аренды офис',                    // description (нормализован)
].join(':');

// SHA-256('a1b2c3d4-...:2026-02-28:1500.00:оплата аренды офис')
// = 'a3f9b2c1d4e5...' (64 символа hex)
```

### Алгоритм идемпотентного импорта

```
Для каждой строки в CSV-файле:
  1. Распарсить строку → { accountId, date, amount, description }
  2. Вычислить transactionHash
  3. SELECT id FROM transactions WHERE transaction_hash = ?
     ├── НАЙДЕНО → увеличить skippedRows в ImportJob, перейти к следующей строке
     └── НЕ НАЙДЕНО → INSERT INTO transactions (...) → увеличить processedRows
```

```typescript
// src/modules/import/import.service.ts
async importRow(row: ParsedRow, jobId: string): Promise<'created' | 'skipped'> {
  const hash = computeTransactionHash({
    accountId:   row.accountId,
    date:        row.date,
    amount:      row.amount,
    description: row.description,
  });

  const existing = await Transaction.findOne({
    where: { transactionHash: hash },
    attributes: ['id'],
  });

  if (existing) {
    await ImportJob.increment('skipped_rows', { where: { id: jobId } });
    return 'skipped';
  }

  await Transaction.create({ ...row, transactionHash: hash, importJobId: jobId });
  await ImportJob.increment('processed_rows', { where: { id: jobId } });
  return 'created';
}
```

### Ограничения подхода

| Ситуация | Поведение | Комментарий |
|---|---|---|
| Тот же файл загружен повторно | Все строки пропускаются | Корректно |
| Разные файлы, одна операция | Дубликат пропускается | Корректно |
| Одна дата, одна сумма, разные операции | Коллизия хеша | Редко, если description различается |
| Банк не передаёт description | Высокий риск коллизий | Дополнительно использовать порядковый номер строки из metadata |

Для случаев без `description` рекомендуется включать `rowIndex` в хеш (из поля `metadata.originalRow`), что снижает риск ложных дедупликаций.

---

## 8. Соглашения и ограничения

### Именование

| Объект | Формат | Пример |
|---|---|---|
| Таблицы | snake_case, множественное число | `scheduled_payments` |
| Колонки | snake_case | `account_id`, `created_at` |
| Модели Sequelize | PascalCase | `ScheduledPayment` |
| Поля моделей | camelCase | `accountId`, `createdAt` |
| Индексы | `{table}_{columns}_{type}` | `transactions_account_date_idx` |
| ENUM-типы | snake_case, суффикс `_type` / без | `transaction_type`, `payment_frequency` |

> Sequelize опция `underscored: true` обеспечивает автоматическую конвертацию между camelCase (TypeScript) и snake_case (PostgreSQL).

### Денежные значения

- Тип: `DECIMAL(15,2)` — не `FLOAT`, не `DOUBLE`
- `FLOAT` и `DOUBLE` недопустимы для денежных сумм из-за погрешностей floating-point
- Максимальная поддерживаемая сумма: 9 999 999 999 999,99 (почти 10 триллионов)
- `amount` в `transactions` всегда положительный; знак определяется `type`

### Временные зоны

- Все `TIMESTAMP` поля хранятся в UTC (`TIMESTAMPTZ`)
- Конвертация в локальную временную зону пользователя выполняется на клиенте
- Поле `date` в `transactions` — тип `DATE` (без времени), так как финансовые операции датируются днём, а не моментом

### Валюты

- Хранятся как трёхбуквенный ISO 4217 код: `USD`, `EUR`, `UAH`, `GBP`
- Конвертация между валютами при агрегации — ответственность сервисного слоя
- Курсы валют в текущей версии получаются от внешнего API (не хранятся в БД)

### Ограничения MVP

Следующие функции намеренно исключены из текущей схемы и запланированы на пост-MVP:

| Функция | Обоснование исключения |
|---|---|
| Таблица `budgets` | Нет в MVP scope |
| Таблица `notifications` | Уведомления хранятся в Redis (ephemeral) |
| Таблица `audit_log` | Добавить при необходимости compliance-аудита |
| Полнотекстовый поиск по `description` | Требует GIN-индекс; добавить при росте нагрузки |
| Таблица обменных курсов `exchange_rates` | Внешний API достаточен для MVP |
| Мультивалютные переводы | Сложная логика; откложено |

---

**Документ актуален на:** 2026-02-28

**Смотрите также:**
- [Техническое задание](./technical-spec.md) — функциональные требования и scope MVP
- [Спецификация API](./api-spec.md) — REST endpoints, работающие с этими моделями
- [Архитектура системы](./architecture.md) — как БД встроена в общую инфраструктуру
- [README](./README.md) — обзор проекта и навигация по документации
