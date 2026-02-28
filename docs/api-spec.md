# AnticiFi — REST API Specification

> Назад к [README](./README.md)

**Связанные документы:**
- [Пользовательские истории](./user-stories.md)
- [Техническая спецификация](./technical-spec.md)
- [Схема базы данных](./database-schema.md)

---

## Содержание

1. [Общие принципы](#общие-принципы)
2. [Аутентификация](#аутентификация)
3. [Форматы ответов](#форматы-ответов)
4. [Модули API](#модули-api)
   - [Auth — Аутентификация](#auth--аутентификация)
   - [Users — Пользователи](#users--пользователи)
   - [Accounts — Счета](#accounts--счета)
   - [Transactions — Транзакции](#transactions--транзакции)
   - [Import — Импорт данных](#import--импорт-данных)
   - [Categories — Категории](#categories--категории)
   - [Scheduled Payments — Запланированные платежи](#scheduled-payments--запланированные-платежи)
   - [Predictions — Прогнозы (Oracle)](#predictions--прогнозы-oracle)
   - [Notifications — Уведомления](#notifications--уведомления)
   - [Dashboard — Дашборд](#dashboard--дашборд)
5. [WebSocket события](#websocket-события)
6. [Коды ошибок](#коды-ошибок)

---

## Общие принципы

- **Base URL:** `https://api.anticifi.com/api` (production) / `http://localhost:3000/api` (development)
- **Формат данных:** JSON (`Content-Type: application/json`) для всех запросов и ответов
- **Версионирование:** версия API включена в базовый путь (`/api` = v1)
- **Временные метки:** все даты передаются в формате ISO 8601 (`2024-01-15T10:30:00.000Z`)
- **UUID:** все идентификаторы сущностей — UUID v4
- **Мягкое удаление:** сущности не удаляются физически, помечаются флагом `deletedAt`
- **Rate Limiting:** 100 запросов / минута для обычных эндпоинтов, 10 запросов / минута для AI-эндпоинтов

---

## Аутентификация

Все эндпоинты, кроме публичных эндпоинтов модуля Auth, требуют заголовок:

```
Authorization: Bearer <accessToken>
```

### JWT Flow

**Получение токенов (Login / Register):**

```
POST /api/auth/login  →  { accessToken, refreshToken }
```

**Структура accessToken (payload):**

```json
{
  "userId": "uuid",
  "email": "user@example.com",
  "iat": 1705312200,
  "exp": 1705313100
}
```

**Время жизни:**
- `accessToken` — **15 минут**
- `refreshToken` — **7 дней**

**Обновление пары токенов:**

```
POST /api/auth/refresh
Body: { "refreshToken": "..." }
→ { accessToken, refreshToken }  (старый refreshToken инвалидируется)
```

**Logout:**

```
POST /api/auth/logout
Body: { "refreshToken": "..." }
→ refreshToken добавляется в blacklist
```

---

## Форматы ответов

### Успешный ответ (одна сущность)

```json
{
  "data": { ... }
}
```

### Успешный ответ (список с пагинацией)

```json
{
  "data": [ ... ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Ответ об ошибке

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    { "field": "email", "message": "Invalid email format" },
    { "field": "password", "message": "Password must be at least 8 characters" }
  ]
}
```

Поле `errors` присутствует только при ошибках валидации (400, 422). Для остальных ошибок возвращается только `statusCode` и `message`.

### Стандартные HTTP-коды

| Код | Смысл |
|-----|-------|
| `200` | OK — запрос выполнен успешно |
| `201` | Created — сущность создана |
| `204` | No Content — удаление выполнено успешно |
| `400` | Bad Request — ошибка валидации входных данных |
| `401` | Unauthorized — токен отсутствует или недействителен |
| `403` | Forbidden — нет прав на ресурс |
| `404` | Not Found — ресурс не найден |
| `409` | Conflict — конфликт (например, email уже зарегистрирован) |
| `422` | Unprocessable Entity — семантическая ошибка данных |
| `429` | Too Many Requests — превышен rate limit |
| `500` | Internal Server Error — внутренняя ошибка сервера |

---

## Модули API

---

## Auth — Аутентификация

Публичные эндпоинты (без токена).

---

### POST /api/auth/register

Регистрация нового пользователя. После регистрации отправляется письмо для подтверждения email.

**Request Body:**

```json
{
  "email": "ivan@example.com",
  "password": "SecurePass123!",
  "firstName": "Иван",
  "lastName": "Петров"
}
```

**Валидация:**
- `email` — валидный email, уникальный в системе
- `password` — минимум 8 символов, хотя бы одна цифра и одна заглавная буква
- `firstName`, `lastName` — обязательны, от 1 до 50 символов

**Response `201`:**

```json
{
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "ivan@example.com",
      "firstName": "Иван",
      "lastName": "Петров",
      "emailVerified": false,
      "createdAt": "2024-01-15T10:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации полей
- `409` — пользователь с таким email уже существует

---

### POST /api/auth/login

Вход в систему, возвращает пару JWT-токенов.

**Request Body:**

```json
{
  "email": "ivan@example.com",
  "password": "SecurePass123!"
}
```

**Response `200`:**

```json
{
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "ivan@example.com",
      "firstName": "Иван",
      "lastName": "Петров",
      "emailVerified": true,
      "avatarUrl": "https://cdn.anticifi.com/avatars/uuid.jpg"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `401` — неверный email или пароль

---

### POST /api/auth/refresh

Обновление пары токенов по действующему refreshToken. Старый refreshToken инвалидируется (rotation).

**Request Body:**

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response `200`:**

```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Возможные ошибки:**
- `401` — refreshToken недействителен или истёк

---

### POST /api/auth/logout

Инвалидация refreshToken (добавление в blacklist). AccessToken истекает естественным образом.

**Request Body:**

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response `204`:** _(пустое тело)_

**Возможные ошибки:**
- `400` — refreshToken не передан

---

### POST /api/auth/forgot-password

Отправка письма с ссылкой для сброса пароля. Всегда возвращает `200` вне зависимости от существования email (защита от перечисления пользователей).

**Request Body:**

```json
{
  "email": "ivan@example.com"
}
```

**Response `200`:**

```json
{
  "data": {
    "message": "If this email is registered, a password reset link has been sent."
  }
}
```

---

### POST /api/auth/reset-password

Сброс пароля по токену из письма. Токен действует 1 час.

**Request Body:**

```json
{
  "token": "a3f8b2c1d4e5...",
  "newPassword": "NewSecurePass456!"
}
```

**Response `200`:**

```json
{
  "data": {
    "message": "Password has been reset successfully."
  }
}
```

**Возможные ошибки:**
- `400` — слабый пароль или токен не передан
- `401` — токен недействителен или истёк

---

### GET /api/auth/verify-email/:token

Подтверждение email по токену из письма. Токен одноразовый, действует 24 часа.

**URL параметры:**
- `token` — строка токена из письма

**Response `200`:**

```json
{
  "data": {
    "message": "Email verified successfully.",
    "emailVerified": true
  }
}
```

**Возможные ошибки:**
- `401` — токен недействителен или истёк
- `409` — email уже подтверждён

---

## Users — Пользователи

Требуют `Authorization: Bearer <accessToken>`.

---

### GET /api/users/me

Получение профиля текущего авторизованного пользователя.

**Response `200`:**

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "ivan@example.com",
    "firstName": "Иван",
    "lastName": "Петров",
    "emailVerified": true,
    "avatarUrl": "https://cdn.anticifi.com/avatars/550e8400.jpg",
    "currency": "RUB",
    "locale": "ru-RU",
    "timezone": "Europe/Moscow",
    "createdAt": "2024-01-15T10:00:00.000Z",
    "updatedAt": "2024-01-20T14:30:00.000Z"
  }
}
```

**Возможные ошибки:**
- `401` — не авторизован

---

### PATCH /api/users/me

Обновление данных профиля. Все поля опциональны — передаются только те, что нужно изменить.

**Request Body:**

```json
{
  "firstName": "Иван",
  "lastName": "Сидоров",
  "currency": "USD",
  "locale": "en-US",
  "timezone": "America/New_York"
}
```

**Response `200`:**

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "ivan@example.com",
    "firstName": "Иван",
    "lastName": "Сидоров",
    "emailVerified": true,
    "avatarUrl": "https://cdn.anticifi.com/avatars/550e8400.jpg",
    "currency": "USD",
    "locale": "en-US",
    "timezone": "America/New_York",
    "updatedAt": "2024-01-21T09:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации полей
- `401` — не авторизован

---

### DELETE /api/users/me

Мягкое удаление аккаунта. Пользователь помечается как удалённый, все данные планируются к полному удалению через 30 дней. Все активные сессии инвалидируются.

**Request Body:**

```json
{
  "password": "SecurePass123!",
  "confirmation": "DELETE"
}
```

**Response `204`:** _(пустое тело)_

**Возможные ошибки:**
- `400` — confirmation не равен "DELETE"
- `401` — неверный пароль

---

### PATCH /api/users/me/password

Изменение пароля авторизованного пользователя. Требует текущий пароль. После смены все существующие refreshToken инвалидируются.

**Request Body:**

```json
{
  "currentPassword": "SecurePass123!",
  "newPassword": "NewSecurePass456!",
  "confirmPassword": "NewSecurePass456!"
}
```

**Response `200`:**

```json
{
  "data": {
    "message": "Password changed successfully. Please log in again."
  }
}
```

**Возможные ошибки:**
- `400` — newPassword и confirmPassword не совпадают, или слабый пароль
- `401` — неверный currentPassword

---

### POST /api/users/me/avatar

Загрузка аватара пользователя. Запрос отправляется как `multipart/form-data`.

**Request:**

```
Content-Type: multipart/form-data
```

| Поле | Тип | Описание |
|------|-----|----------|
| `avatar` | file | Изображение (JPG, PNG, WebP). Максимум 5 MB. Минимум 100x100 px. |

**Response `200`:**

```json
{
  "data": {
    "avatarUrl": "https://cdn.anticifi.com/avatars/550e8400-thumb.jpg"
  }
}
```

**Возможные ошибки:**
- `400` — файл не передан, неверный формат или превышен размер
- `413` — файл слишком большой (>5 MB)

---

## Accounts — Счета

Требуют `Authorization: Bearer <accessToken>`. Пользователь видит только свои счета.

---

### GET /api/accounts

Получение списка всех счетов пользователя.

**Response `200`:**

```json
{
  "data": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "name": "Основная карта",
      "type": "CHECKING",
      "currency": "RUB",
      "balance": 125430.50,
      "color": "#4CAF50",
      "icon": "credit-card",
      "isDefault": true,
      "createdAt": "2024-01-15T10:00:00.000Z"
    },
    {
      "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "name": "Накопительный",
      "type": "SAVINGS",
      "currency": "RUB",
      "balance": 500000.00,
      "color": "#2196F3",
      "icon": "piggy-bank",
      "isDefault": false,
      "createdAt": "2024-01-16T12:00:00.000Z"
    }
  ]
}
```

---

### POST /api/accounts

Создание нового счёта.

**Request Body:**

```json
{
  "name": "Дополнительная карта",
  "type": "CHECKING",
  "currency": "USD",
  "initialBalance": 1500.00,
  "color": "#FF9800",
  "icon": "wallet"
}
```

**Допустимые значения `type`:** `CHECKING`, `SAVINGS`, `CREDIT`, `INVESTMENT`, `CASH`

**Response `201`:**

```json
{
  "data": {
    "id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
    "name": "Дополнительная карта",
    "type": "CHECKING",
    "currency": "USD",
    "balance": 1500.00,
    "color": "#FF9800",
    "icon": "wallet",
    "isDefault": false,
    "createdAt": "2024-01-22T08:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `422` — недопустимый тип счёта или валюта

---

### GET /api/accounts/:id

Получение детальной информации о счёте с текущим балансом.

**URL параметры:**
- `id` — UUID счёта

**Response `200`:**

```json
{
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Основная карта",
    "type": "CHECKING",
    "currency": "RUB",
    "balance": 125430.50,
    "color": "#4CAF50",
    "icon": "credit-card",
    "isDefault": true,
    "transactionsCount": 248,
    "createdAt": "2024-01-15T10:00:00.000Z",
    "updatedAt": "2024-01-21T18:45:00.000Z"
  }
}
```

**Возможные ошибки:**
- `403` — счёт принадлежит другому пользователю
- `404` — счёт не найден

---

### PATCH /api/accounts/:id

Обновление данных счёта. Изменение баланса напрямую недоступно — только через транзакции.

**Request Body:**

```json
{
  "name": "Основная карта Сбер",
  "color": "#1CB954",
  "icon": "bank",
  "isDefault": true
}
```

**Response `200`:**

```json
{
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Основная карта Сбер",
    "type": "CHECKING",
    "currency": "RUB",
    "balance": 125430.50,
    "color": "#1CB954",
    "icon": "bank",
    "isDefault": true,
    "updatedAt": "2024-01-22T09:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `403` — нет доступа
- `404` — счёт не найден

---

### DELETE /api/accounts/:id

Удаление счёта. Если на счёте есть транзакции, удаление запрещено — сначала необходимо удалить или перенести транзакции.

**Response `204`:** _(пустое тело)_

**Возможные ошибки:**
- `403` — нет доступа
- `404` — счёт не найден
- `409` — на счёте есть связанные транзакции или платежи

---

### GET /api/accounts/:id/summary

Сводка по счёту: суммарный доход, расход и баланс за указанный период.

**Query параметры:**

| Параметр | Тип | Обязательный | Описание |
|----------|-----|:---:|---------|
| `startDate` | ISO 8601 date | да | Начало периода |
| `endDate` | ISO 8601 date | да | Конец периода |

**Response `200`:**

```json
{
  "data": {
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "period": {
      "startDate": "2024-01-01",
      "endDate": "2024-01-31"
    },
    "totalIncome": 85000.00,
    "totalExpense": 42350.75,
    "netBalance": 42649.25,
    "openingBalance": 82781.25,
    "closingBalance": 125430.50,
    "transactionsCount": 47
  }
}
```

**Возможные ошибки:**
- `400` — отсутствуют или некорректны параметры периода
- `403` — нет доступа
- `404` — счёт не найден

---

## Transactions — Транзакции

Требуют `Authorization: Bearer <accessToken>`.

---

### GET /api/accounts/:accountId/transactions

Получение списка транзакций по счёту с поддержкой фильтрации и пагинации.

**Query параметры:**

| Параметр | Тип | Описание |
|----------|-----|---------|
| `page` | integer | Номер страницы (по умолчанию: 1) |
| `limit` | integer | Записей на страницу (по умолчанию: 20, максимум: 100) |
| `startDate` | ISO 8601 date | Начало периода |
| `endDate` | ISO 8601 date | Конец периода |
| `categoryId` | UUID | Фильтр по категории |
| `type` | string | `INCOME` или `EXPENSE` |
| `minAmount` | number | Минимальная сумма |
| `maxAmount` | number | Максимальная сумма |
| `search` | string | Поиск по описанию и примечаниям |

**Response `200`:**

```json
{
  "data": [
    {
      "id": "d4e5f6a7-b8c9-0123-defa-234567890123",
      "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "type": "EXPENSE",
      "amount": 1250.00,
      "currency": "RUB",
      "description": "Продукты в Пятёрочке",
      "note": "Закупка на неделю",
      "category": {
        "id": "cat-uuid-001",
        "name": "Продукты",
        "icon": "shopping-cart",
        "color": "#8BC34A"
      },
      "date": "2024-01-20",
      "isManual": true,
      "importSource": null,
      "createdAt": "2024-01-20T19:30:00.000Z"
    },
    {
      "id": "e5f6a7b8-c9d0-1234-efab-345678901234",
      "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "type": "INCOME",
      "amount": 85000.00,
      "currency": "RUB",
      "description": "Зарплата январь",
      "note": null,
      "category": {
        "id": "cat-uuid-002",
        "name": "Зарплата",
        "icon": "briefcase",
        "color": "#4CAF50"
      },
      "date": "2024-01-10",
      "isManual": false,
      "importSource": "CSV",
      "createdAt": "2024-01-10T09:00:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 248,
    "totalPages": 13
  }
}
```

**Возможные ошибки:**
- `400` — некорректные параметры фильтрации
- `403` — нет доступа к счёту
- `404` — счёт не найден

---

### POST /api/accounts/:accountId/transactions

Создание ручной транзакции.

**Request Body:**

```json
{
  "type": "EXPENSE",
  "amount": 850.00,
  "description": "Обед в кафе",
  "note": "Деловой обед",
  "categoryId": "cat-uuid-003",
  "date": "2024-01-22"
}
```

**Response `201`:**

```json
{
  "data": {
    "id": "f6a7b8c9-d0e1-2345-fabc-456789012345",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "EXPENSE",
    "amount": 850.00,
    "currency": "RUB",
    "description": "Обед в кафе",
    "note": "Деловой обед",
    "category": {
      "id": "cat-uuid-003",
      "name": "Кафе и рестораны",
      "icon": "utensils",
      "color": "#FF5722"
    },
    "date": "2024-01-22",
    "isManual": true,
    "importSource": null,
    "createdAt": "2024-01-22T13:15:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `403` — нет доступа к счёту
- `404` — счёт или категория не найдены

---

### GET /api/accounts/:accountId/transactions/:id

Получение детальной информации об отдельной транзакции.

**Response `200`:**

```json
{
  "data": {
    "id": "d4e5f6a7-b8c9-0123-defa-234567890123",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "EXPENSE",
    "amount": 1250.00,
    "currency": "RUB",
    "description": "Продукты в Пятёрочке",
    "note": "Закупка на неделю",
    "category": {
      "id": "cat-uuid-001",
      "name": "Продукты",
      "icon": "shopping-cart",
      "color": "#8BC34A"
    },
    "date": "2024-01-20",
    "isManual": true,
    "importSource": null,
    "attachments": [],
    "createdAt": "2024-01-20T19:30:00.000Z",
    "updatedAt": "2024-01-20T19:30:00.000Z"
  }
}
```

**Возможные ошибки:**
- `403` — нет доступа
- `404` — транзакция не найдена

---

### PATCH /api/accounts/:accountId/transactions/:id

Обновление транзакции. Нельзя менять `accountId`, `importSource`.

**Request Body:**

```json
{
  "description": "Продукты Пятёрочка (уточнено)",
  "categoryId": "cat-uuid-001",
  "note": "Закупка на неделю + бытовая химия",
  "amount": 1380.00,
  "date": "2024-01-20"
}
```

**Response `200`:**

```json
{
  "data": {
    "id": "d4e5f6a7-b8c9-0123-defa-234567890123",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "EXPENSE",
    "amount": 1380.00,
    "currency": "RUB",
    "description": "Продукты Пятёрочка (уточнено)",
    "note": "Закупка на неделю + бытовая химия",
    "category": {
      "id": "cat-uuid-001",
      "name": "Продукты",
      "icon": "shopping-cart",
      "color": "#8BC34A"
    },
    "date": "2024-01-20",
    "isManual": true,
    "updatedAt": "2024-01-22T10:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `403` — нет доступа
- `404` — транзакция или категория не найдены

---

### DELETE /api/accounts/:accountId/transactions/:id

Удаление транзакции. Баланс счёта пересчитывается автоматически.

**Response `204`:** _(пустое тело)_

**Возможные ошибки:**
- `403` — нет доступа
- `404` — транзакция не найдена

---

### GET /api/accounts/:accountId/transactions/stats

Агрегированная статистика транзакций по категориям и периоду.

**Query параметры:**

| Параметр | Тип | Обязательный | Описание |
|----------|-----|:---:|---------|
| `startDate` | ISO 8601 date | да | Начало периода |
| `endDate` | ISO 8601 date | да | Конец периода |
| `groupBy` | string | нет | `category` (по умолчанию) или `month` |

**Response `200`:**

```json
{
  "data": {
    "period": {
      "startDate": "2024-01-01",
      "endDate": "2024-01-31"
    },
    "totalIncome": 85000.00,
    "totalExpense": 42350.75,
    "byCategory": [
      {
        "category": {
          "id": "cat-uuid-001",
          "name": "Продукты",
          "icon": "shopping-cart",
          "color": "#8BC34A"
        },
        "type": "EXPENSE",
        "total": 12500.00,
        "transactionsCount": 8,
        "percentage": 29.5
      },
      {
        "category": {
          "id": "cat-uuid-003",
          "name": "Кафе и рестораны",
          "icon": "utensils",
          "color": "#FF5722"
        },
        "type": "EXPENSE",
        "total": 8750.00,
        "transactionsCount": 12,
        "percentage": 20.7
      }
    ]
  }
}
```

**Возможные ошибки:**
- `400` — отсутствуют параметры периода
- `403` — нет доступа к счёту
- `404` — счёт не найден

---

## Import — Импорт данных

Требуют `Authorization: Bearer <accessToken>`.

---

### POST /api/import/csv

Загрузка CSV-файла с транзакциями для импорта. Запрос отправляется как `multipart/form-data`. Создаёт асинхронное задание на импорт.

**Request:**

```
Content-Type: multipart/form-data
```

| Поле | Тип | Описание |
|------|-----|----------|
| `file` | file | CSV-файл. Максимум 10 MB. |
| `accountId` | UUID | Счёт, на который импортируются транзакции |
| `delimiter` | string | Разделитель: `,` (по умолчанию) или `;` |
| `dateFormat` | string | Формат даты: `DD.MM.YYYY`, `YYYY-MM-DD`, `MM/DD/YYYY` |
| `mapping` | JSON string | Маппинг колонок CSV на поля транзакции |

**Пример `mapping`:**

```json
{
  "date": "Дата",
  "amount": "Сумма",
  "description": "Назначение платежа",
  "type": "Тип операции"
}
```

**Response `202`:**

```json
{
  "data": {
    "jobId": "job-uuid-001",
    "status": "PENDING",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "fileName": "transactions_jan2024.csv",
    "totalRows": 0,
    "processedRows": 0,
    "createdAt": "2024-01-22T11:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — файл не передан, некорректный маппинг
- `404` — счёт не найден
- `413` — файл слишком большой
- `422` — неверный формат CSV

---

### POST /api/import/ocr

Загрузка фотографии чека для распознавания через OCR. Создаёт транзакцию автоматически после обработки.

**Request:**

```
Content-Type: multipart/form-data
```

| Поле | Тип | Описание |
|------|-----|----------|
| `image` | file | Фото чека (JPG, PNG, HEIC). Максимум 20 MB. |
| `accountId` | UUID | Счёт для записи транзакции |

**Response `202`:**

```json
{
  "data": {
    "jobId": "job-uuid-002",
    "status": "PROCESSING",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "createdAt": "2024-01-22T11:05:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — файл не передан
- `404` — счёт не найден
- `413` — файл слишком большой
- `422` — не удалось распознать как чек

---

### GET /api/import/jobs

Получение списка всех заданий на импорт пользователя.

**Query параметры:**

| Параметр | Тип | Описание |
|----------|-----|---------|
| `page` | integer | Страница (по умолчанию: 1) |
| `limit` | integer | Записей на страницу (по умолчанию: 20) |
| `status` | string | `PENDING`, `PROCESSING`, `COMPLETED`, `FAILED` |

**Response `200`:**

```json
{
  "data": [
    {
      "jobId": "job-uuid-001",
      "type": "CSV",
      "status": "COMPLETED",
      "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "fileName": "transactions_jan2024.csv",
      "totalRows": 125,
      "processedRows": 125,
      "importedCount": 121,
      "skippedCount": 4,
      "createdAt": "2024-01-22T11:00:00.000Z",
      "completedAt": "2024-01-22T11:01:30.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "totalPages": 1
  }
}
```

---

### GET /api/import/jobs/:id

Получение детального статуса конкретного задания на импорт.

**Response `200`:**

```json
{
  "data": {
    "jobId": "job-uuid-001",
    "type": "CSV",
    "status": "COMPLETED",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "fileName": "transactions_jan2024.csv",
    "totalRows": 125,
    "processedRows": 125,
    "importedCount": 121,
    "skippedCount": 4,
    "errors": [
      { "row": 14, "reason": "Invalid date format" },
      { "row": 67, "reason": "Amount is missing" }
    ],
    "summary": {
      "totalImportedAmount": 287430.50,
      "incomeCount": 3,
      "expenseCount": 118
    },
    "createdAt": "2024-01-22T11:00:00.000Z",
    "completedAt": "2024-01-22T11:01:30.000Z"
  }
}
```

**Возможные ошибки:**
- `403` — задание принадлежит другому пользователю
- `404` — задание не найдено

---

## Categories — Категории

Требуют `Authorization: Bearer <accessToken>`. Системные категории доступны всем пользователям только для чтения. Пользовательские категории создаются и управляются каждым пользователем отдельно.

---

### GET /api/categories

Получение списка всех категорий: системных и пользовательских.

**Query параметры:**

| Параметр | Тип | Описание |
|----------|-----|---------|
| `type` | string | `INCOME` или `EXPENSE` — фильтр по типу |

**Response `200`:**

```json
{
  "data": [
    {
      "id": "sys-cat-001",
      "name": "Продукты",
      "icon": "shopping-cart",
      "color": "#8BC34A",
      "type": "EXPENSE",
      "isSystem": true,
      "parentId": null
    },
    {
      "id": "sys-cat-002",
      "name": "Зарплата",
      "icon": "briefcase",
      "color": "#4CAF50",
      "type": "INCOME",
      "isSystem": true,
      "parentId": null
    },
    {
      "id": "usr-cat-001",
      "name": "Хобби — рыбалка",
      "icon": "fish",
      "color": "#00BCD4",
      "type": "EXPENSE",
      "isSystem": false,
      "parentId": null
    }
  ]
}
```

---

### POST /api/categories

Создание пользовательской категории.

**Request Body:**

```json
{
  "name": "Спортзал",
  "icon": "dumbbell",
  "color": "#9C27B0",
  "type": "EXPENSE",
  "parentId": null
}
```

**Response `201`:**

```json
{
  "data": {
    "id": "usr-cat-002",
    "name": "Спортзал",
    "icon": "dumbbell",
    "color": "#9C27B0",
    "type": "EXPENSE",
    "isSystem": false,
    "parentId": null,
    "createdAt": "2024-01-22T12:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `409` — категория с таким именем уже существует у пользователя

---

### PATCH /api/categories/:id

Обновление пользовательской категории. Системные категории изменить нельзя.

**Request Body:**

```json
{
  "name": "Фитнес-клуб",
  "color": "#673AB7"
}
```

**Response `200`:**

```json
{
  "data": {
    "id": "usr-cat-002",
    "name": "Фитнес-клуб",
    "icon": "dumbbell",
    "color": "#673AB7",
    "type": "EXPENSE",
    "isSystem": false,
    "updatedAt": "2024-01-22T13:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `403` — попытка изменить системную категорию
- `404` — категория не найдена

---

### DELETE /api/categories/:id

Удаление пользовательской категории. Транзакции, использующие эту категорию, переносятся в родительскую или в категорию "Прочее".

**Response `204`:** _(пустое тело)_

**Возможные ошибки:**
- `403` — попытка удалить системную категорию
- `404` — категория не найдена

---

## Scheduled Payments — Запланированные платежи

Требуют `Authorization: Bearer <accessToken>`. Recurring-платежи, которые автоматически создают транзакции по расписанию.

---

### GET /api/accounts/:accountId/scheduled-payments

Получение списка запланированных платежей по счёту.

**Response `200`:**

```json
{
  "data": [
    {
      "id": "sp-uuid-001",
      "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "type": "EXPENSE",
      "amount": 990.00,
      "description": "Подписка Spotify",
      "category": {
        "id": "sys-cat-010",
        "name": "Подписки",
        "icon": "music",
        "color": "#1DB954"
      },
      "frequency": "MONTHLY",
      "dayOfMonth": 15,
      "startDate": "2024-01-15",
      "endDate": null,
      "nextPaymentDate": "2024-02-15",
      "isActive": true,
      "createdAt": "2024-01-15T10:00:00.000Z"
    }
  ]
}
```

---

### POST /api/accounts/:accountId/scheduled-payments

Создание нового запланированного платежа.

**Request Body:**

```json
{
  "type": "EXPENSE",
  "amount": 5000.00,
  "description": "Аренда парковки",
  "categoryId": "sys-cat-011",
  "frequency": "MONTHLY",
  "dayOfMonth": 1,
  "startDate": "2024-02-01",
  "endDate": null
}
```

**Допустимые значения `frequency`:** `DAILY`, `WEEKLY`, `BIWEEKLY`, `MONTHLY`, `QUARTERLY`, `YEARLY`

**Response `201`:**

```json
{
  "data": {
    "id": "sp-uuid-002",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "EXPENSE",
    "amount": 5000.00,
    "description": "Аренда парковки",
    "category": {
      "id": "sys-cat-011",
      "name": "Транспорт",
      "icon": "car",
      "color": "#607D8B"
    },
    "frequency": "MONTHLY",
    "dayOfMonth": 1,
    "startDate": "2024-02-01",
    "endDate": null,
    "nextPaymentDate": "2024-02-01",
    "isActive": true,
    "createdAt": "2024-01-22T14:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `404` — счёт или категория не найдены

---

### GET /api/accounts/:accountId/scheduled-payments/:id

Получение детальной информации о запланированном платеже.

**Response `200`:**

```json
{
  "data": {
    "id": "sp-uuid-001",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "EXPENSE",
    "amount": 990.00,
    "description": "Подписка Spotify",
    "category": {
      "id": "sys-cat-010",
      "name": "Подписки",
      "icon": "music",
      "color": "#1DB954"
    },
    "frequency": "MONTHLY",
    "dayOfMonth": 15,
    "startDate": "2024-01-15",
    "endDate": null,
    "nextPaymentDate": "2024-02-15",
    "lastExecutedAt": "2024-01-15T00:00:00.000Z",
    "executionsCount": 1,
    "isActive": true,
    "createdAt": "2024-01-15T10:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `403` — нет доступа
- `404` — платёж не найден

---

### PATCH /api/accounts/:accountId/scheduled-payments/:id

Обновление запланированного платежа.

**Request Body:**

```json
{
  "amount": 1190.00,
  "description": "Подписка Spotify Premium Duo",
  "isActive": true
}
```

**Response `200`:**

```json
{
  "data": {
    "id": "sp-uuid-001",
    "amount": 1190.00,
    "description": "Подписка Spotify Premium Duo",
    "isActive": true,
    "nextPaymentDate": "2024-02-15",
    "updatedAt": "2024-01-22T15:00:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — ошибка валидации
- `403` — нет доступа
- `404` — платёж не найден

---

### DELETE /api/accounts/:accountId/scheduled-payments/:id

Удаление запланированного платежа. Уже созданные транзакции не удаляются.

**Response `204`:** _(пустое тело)_

**Возможные ошибки:**
- `403` — нет доступа
- `404` — платёж не найден

---

## Predictions — Прогнозы (Oracle)

Требуют `Authorization: Bearer <accessToken>`. AI-модуль прогнозирования на основе истории транзакций и запланированных платежей.

---

### GET /api/accounts/:accountId/predictions

Получение прогнозов баланса на указанный период.

**Query параметры:**

| Параметр | Тип | Обязательный | Описание |
|----------|-----|:---:|---------|
| `startDate` | ISO 8601 date | да | Начало периода прогноза |
| `endDate` | ISO 8601 date | да | Конец периода (максимум: 90 дней от startDate) |

**Response `200`:**

```json
{
  "data": {
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "currentBalance": 125430.50,
    "generatedAt": "2024-01-22T16:00:00.000Z",
    "predictions": [
      {
        "date": "2024-01-23",
        "predictedBalance": 124180.50,
        "predictedIncome": 0,
        "predictedExpense": 1250.00,
        "confidence": 0.87,
        "breakdown": [
          {
            "description": "Продукты (прогноз)",
            "amount": 1250.00,
            "type": "EXPENSE",
            "source": "PATTERN"
          }
        ]
      },
      {
        "date": "2024-02-01",
        "predictedBalance": 75430.50,
        "predictedIncome": 0,
        "predictedExpense": 55000.00,
        "confidence": 0.95,
        "breakdown": [
          {
            "description": "Аренда парковки",
            "amount": 5000.00,
            "type": "EXPENSE",
            "source": "SCHEDULED"
          },
          {
            "description": "Коммунальные услуги (прогноз)",
            "amount": 8000.00,
            "type": "EXPENSE",
            "source": "PATTERN"
          }
        ]
      }
    ]
  }
}
```

**Поля `source`:** `SCHEDULED` — из запланированных платежей, `PATTERN` — из анализа паттернов, `AI` — AI-предсказание.

**Возможные ошибки:**
- `400` — некорректный период или период превышает 90 дней
- `403` — нет доступа к счёту
- `404` — счёт не найден
- `422` — недостаточно данных для формирования прогноза (менее 30 дней истории)

---

### POST /api/accounts/:accountId/predictions/generate

Принудительная генерация прогнозов (обход кэша). Полезно после крупных изменений в данных.

**Request Body:**

```json
{
  "startDate": "2024-01-23",
  "endDate": "2024-03-23"
}
```

**Response `202`:**

```json
{
  "data": {
    "jobId": "pred-job-001",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "PROCESSING",
    "estimatedSeconds": 15,
    "createdAt": "2024-01-22T16:05:00.000Z"
  }
}
```

**Возможные ошибки:**
- `400` — некорректный период
- `403` — нет доступа
- `404` — счёт не найден
- `429` — превышен лимит запросов к AI (max 10 генераций / час)

---

### GET /api/accounts/:accountId/predictions/accuracy

Исторические данные о точности прогнозов для оценки надёжности модели.

**Query параметры:**

| Параметр | Тип | Описание |
|----------|-----|---------|
| `period` | string | `30d`, `60d`, `90d` (по умолчанию: `30d`) |

**Response `200`:**

```json
{
  "data": {
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "period": "30d",
    "overallAccuracy": 0.83,
    "meanAbsoluteError": 2340.50,
    "metrics": [
      {
        "date": "2024-01-01",
        "predicted": 98000.00,
        "actual": 96500.00,
        "error": 1500.00,
        "errorPercent": 1.55
      },
      {
        "date": "2024-01-15",
        "predicted": 115000.00,
        "actual": 118200.00,
        "error": -3200.00,
        "errorPercent": 2.71
      }
    ]
  }
}
```

**Возможные ошибки:**
- `403` — нет доступа
- `404` — счёт не найден
- `422` — недостаточно исторических прогнозов для расчёта точности

---

### POST /api/oracle/ask

Запрос к AI-ассистенту Oracle на естественном языке. Позволяет задавать вопросы о финансах, прогнозах и трендах.

**Request Body:**

```json
{
  "question": "Когда у меня закончатся деньги на основном счёте, если я продолжу тратить в том же темпе?",
  "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

**Поля:**
- `question` (string, обязательно) — вопрос на естественном языке (макс. 500 символов)
- `accountId` (UUID, опционально) — контекст конкретного счёта

**Response `200`:**

```json
{
  "data": {
    "answer": "При текущем темпе расходов около 42 000 рублей в месяц ваш баланс достигнет нуля примерно через 3 месяца — ориентировочно к 22 апреля 2024 года. Однако учтите запланированные поступления зарплаты, которые значительно изменят эту картину.",
    "predictedBalance": 0,
    "confidence": 0.79,
    "date": "2024-04-22",
    "relatedPredictions": [
      {
        "date": "2024-02-22",
        "predictedBalance": 85000.00
      },
      {
        "date": "2024-03-22",
        "predictedBalance": 43000.00
      },
      {
        "date": "2024-04-22",
        "predictedBalance": 1200.00
      }
    ]
  }
}
```

**Возможные ошибки:**
- `400` — вопрос не передан или превышает 500 символов
- `403` — нет доступа к указанному счёту
- `404` — счёт не найден
- `422` — недостаточно данных для ответа
- `429` — превышен лимит запросов к Oracle (10 запросов / минута)

---

## Notifications — Уведомления

Требуют `Authorization: Bearer <accessToken>`.

---

### GET /api/notifications

Получение списка уведомлений текущего пользователя.

**Query параметры:**

| Параметр | Тип | Описание |
|----------|-----|---------|
| `page` | integer | Страница (по умолчанию: 1) |
| `limit` | integer | Записей на страницу (по умолчанию: 20) |
| `isRead` | boolean | `true` — только прочитанные, `false` — только непрочитанные |

**Response `200`:**

```json
{
  "data": [
    {
      "id": "notif-uuid-001",
      "type": "LOW_BALANCE_WARNING",
      "title": "Низкий баланс",
      "body": "Баланс счёта «Основная карта» опустился ниже 10 000 ₽",
      "isRead": false,
      "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "metadata": {
        "currentBalance": 9800.00,
        "threshold": 10000.00
      },
      "createdAt": "2024-01-22T08:00:00.000Z"
    },
    {
      "id": "notif-uuid-002",
      "type": "SCHEDULED_PAYMENT_UPCOMING",
      "title": "Предстоящий платёж",
      "body": "Завтра спишется 990 ₽ — Подписка Spotify",
      "isRead": true,
      "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "metadata": {
        "scheduledPaymentId": "sp-uuid-001",
        "amount": 990.00,
        "dueDate": "2024-02-15"
      },
      "createdAt": "2024-01-21T09:00:00.000Z",
      "readAt": "2024-01-21T10:30:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 12,
    "totalPages": 1,
    "unreadCount": 3
  }
}
```

---

### PATCH /api/notifications/:id/read

Пометить одно уведомление как прочитанное.

**Response `200`:**

```json
{
  "data": {
    "id": "notif-uuid-001",
    "isRead": true,
    "readAt": "2024-01-22T16:30:00.000Z"
  }
}
```

**Возможные ошибки:**
- `403` — уведомление принадлежит другому пользователю
- `404` — уведомление не найдено

---

### PATCH /api/notifications/read-all

Пометить все непрочитанные уведомления пользователя как прочитанные.

**Response `200`:**

```json
{
  "data": {
    "updatedCount": 3
  }
}
```

---

### GET /api/notifications/preferences

Получение настроек уведомлений пользователя.

**Response `200`:**

```json
{
  "data": {
    "email": {
      "enabled": true,
      "lowBalanceWarning": true,
      "scheduledPaymentReminder": true,
      "weeklyReport": true,
      "importCompleted": true
    },
    "push": {
      "enabled": true,
      "lowBalanceWarning": true,
      "scheduledPaymentReminder": true,
      "predictionUpdated": false,
      "importCompleted": true
    },
    "inApp": {
      "enabled": true,
      "lowBalanceWarning": true,
      "scheduledPaymentReminder": true,
      "predictionUpdated": true,
      "importCompleted": true
    },
    "thresholds": {
      "lowBalanceAmount": 10000.00,
      "scheduledPaymentReminderDays": 3
    }
  }
}
```

---

### PATCH /api/notifications/preferences

Обновление настроек уведомлений. Передаются только изменяемые поля.

**Request Body:**

```json
{
  "push": {
    "predictionUpdated": true
  },
  "thresholds": {
    "lowBalanceAmount": 5000.00
  }
}
```

**Response `200`:** _(полный объект preferences, как в GET)_

**Возможные ошибки:**
- `400` — ошибка валидации

---

## Dashboard — Дашборд

Требуют `Authorization: Bearer <accessToken>`. Агрегирующие эндпоинты для главного экрана приложения.

---

### GET /api/dashboard/overview

Полная сводка для дашборда: балансы всех счетов, последние транзакции, прогнозы и предстоящие платежи.

**Query параметры:**

| Параметр | Тип | Описание |
|----------|-----|---------|
| `days` | integer | Глубина истории транзакций в днях (по умолчанию: 30) |

**Response `200`:**

```json
{
  "data": {
    "totalBalance": 625430.50,
    "accounts": [
      {
        "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        "name": "Основная карта",
        "balance": 125430.50,
        "currency": "RUB",
        "type": "CHECKING"
      },
      {
        "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
        "name": "Накопительный",
        "balance": 500000.00,
        "currency": "RUB",
        "type": "SAVINGS"
      }
    ],
    "recentTransactions": [
      {
        "id": "d4e5f6a7-b8c9-0123-defa-234567890123",
        "type": "EXPENSE",
        "amount": 1250.00,
        "description": "Продукты в Пятёрочке",
        "categoryName": "Продукты",
        "date": "2024-01-20",
        "accountName": "Основная карта"
      }
    ],
    "upcomingPayments": [
      {
        "id": "sp-uuid-001",
        "description": "Подписка Spotify",
        "amount": 990.00,
        "nextPaymentDate": "2024-02-15",
        "accountName": "Основная карта"
      }
    ],
    "monthSummary": {
      "totalIncome": 85000.00,
      "totalExpense": 42350.75,
      "savingsRate": 50.2
    },
    "oracleInsight": {
      "message": "Вы тратите на 15% меньше, чем в прошлом месяце. Отличный результат!",
      "type": "POSITIVE_TREND"
    }
  }
}
```

**Возможные ошибки:**
- `401` — не авторизован

---

### GET /api/dashboard/spending-chart

Данные для графика расходов по категориям за указанный период.

**Query параметры:**

| Параметр | Тип | Обязательный | Описание |
|----------|-----|:---:|---------|
| `startDate` | ISO 8601 date | да | Начало периода |
| `endDate` | ISO 8601 date | да | Конец периода |
| `accountId` | UUID | нет | Фильтр по конкретному счёту |

**Response `200`:**

```json
{
  "data": {
    "period": {
      "startDate": "2024-01-01",
      "endDate": "2024-01-31"
    },
    "totalExpense": 42350.75,
    "categories": [
      {
        "categoryId": "cat-uuid-001",
        "categoryName": "Продукты",
        "color": "#8BC34A",
        "total": 12500.00,
        "percentage": 29.5,
        "transactionsCount": 8
      },
      {
        "categoryId": "cat-uuid-003",
        "categoryName": "Кафе и рестораны",
        "color": "#FF5722",
        "total": 8750.00,
        "percentage": 20.7,
        "transactionsCount": 12
      },
      {
        "categoryId": "other",
        "categoryName": "Прочее",
        "color": "#9E9E9E",
        "total": 21100.75,
        "percentage": 49.8,
        "transactionsCount": 27
      }
    ]
  }
}
```

**Возможные ошибки:**
- `400` — отсутствуют параметры периода

---

### GET /api/dashboard/balance-trend

История баланса за прошедший период + прогнозируемый будущий баланс. Используется для отображения графика тренда.

**Query параметры:**

| Параметр | Тип | Описание |
|----------|-----|---------|
| `historyDays` | integer | Дней истории (по умолчанию: 30, максимум: 365) |
| `forecastDays` | integer | Дней прогноза (по умолчанию: 30, максимум: 90) |
| `accountId` | UUID | Фильтр по конкретному счёту |

**Response `200`:**

```json
{
  "data": {
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "history": [
      {
        "date": "2024-01-01",
        "balance": 82781.25,
        "type": "ACTUAL"
      },
      {
        "date": "2024-01-15",
        "balance": 104200.75,
        "type": "ACTUAL"
      },
      {
        "date": "2024-01-22",
        "balance": 125430.50,
        "type": "ACTUAL"
      }
    ],
    "forecast": [
      {
        "date": "2024-01-23",
        "balance": 124180.50,
        "confidence": 0.87,
        "type": "PREDICTED"
      },
      {
        "date": "2024-02-15",
        "balance": 99800.50,
        "confidence": 0.72,
        "type": "PREDICTED"
      }
    ]
  }
}
```

**Возможные ошибки:**
- `400` — некорректные параметры периода
- `404` — счёт не найден

---

## WebSocket события

**Протокол:** Socket.IO v4
**Namespace:** `/` (default)
**Аутентификация:** токен передаётся при подключении:

```javascript
const socket = io('https://api.anticifi.com', {
  auth: { token: 'Bearer <accessToken>' }
});
```

---

### Клиент -> Сервер

#### `subscribe:account`

Подписка на обновления конкретного счёта.

```json
{ "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890" }
```

---

#### `unsubscribe:account`

Отписка от обновлений счёта.

```json
{ "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890" }
```

---

### Сервер -> Клиент

#### `transaction:created`

Новая транзакция создана (в том числе через импорт или scheduled payment).

```json
{
  "transaction": {
    "id": "d4e5f6a7-b8c9-0123-defa-234567890123",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "EXPENSE",
    "amount": 1250.00,
    "description": "Продукты в Пятёрочке",
    "date": "2024-01-20",
    "createdAt": "2024-01-20T19:30:00.000Z"
  }
}
```

---

#### `transaction:updated`

Транзакция обновлена.

```json
{
  "transaction": {
    "id": "d4e5f6a7-b8c9-0123-defa-234567890123",
    "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "amount": 1380.00,
    "updatedAt": "2024-01-22T10:00:00.000Z"
  }
}
```

---

#### `import:progress`

Прогресс выполнения задания на импорт.

```json
{
  "jobId": "job-uuid-001",
  "processedRows": 67,
  "totalRows": 125,
  "status": "PROCESSING"
}
```

---

#### `import:completed`

Задание на импорт завершено.

```json
{
  "jobId": "job-uuid-001",
  "summary": {
    "importedCount": 121,
    "skippedCount": 4,
    "totalImportedAmount": 287430.50
  }
}
```

---

#### `prediction:updated`

Прогнозы для счёта обновлены (после генерации или пересчёта).

```json
{
  "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "predictions": [
    {
      "date": "2024-01-23",
      "predictedBalance": 124180.50,
      "confidence": 0.87
    }
  ]
}
```

---

#### `notification:new`

Новое уведомление для пользователя.

```json
{
  "notification": {
    "id": "notif-uuid-003",
    "type": "LOW_BALANCE_WARNING",
    "title": "Низкий баланс",
    "body": "Баланс счёта «Основная карта» опустился ниже 10 000 ₽",
    "isRead": false,
    "createdAt": "2024-01-22T08:00:00.000Z"
  }
}
```

---

#### `balance:updated`

Баланс счёта изменился.

```json
{
  "accountId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "newBalance": 124180.50,
  "updatedAt": "2024-01-22T19:30:00.000Z"
}
```

---

## Коды ошибок

### Типы ошибок по модулям

| Код ошибки | HTTP статус | Описание |
|-----------|------------|---------|
| `AUTH_INVALID_CREDENTIALS` | 401 | Неверный email или пароль |
| `AUTH_TOKEN_EXPIRED` | 401 | Токен истёк |
| `AUTH_TOKEN_INVALID` | 401 | Токен недействителен |
| `AUTH_REFRESH_TOKEN_REUSED` | 401 | Refresh token уже был использован (атака replay) |
| `AUTH_EMAIL_NOT_VERIFIED` | 403 | Email не подтверждён |
| `USER_EMAIL_TAKEN` | 409 | Email уже зарегистрирован |
| `USER_NOT_FOUND` | 404 | Пользователь не найден |
| `ACCOUNT_NOT_FOUND` | 404 | Счёт не найден |
| `ACCOUNT_ACCESS_DENIED` | 403 | Нет доступа к счёту |
| `ACCOUNT_HAS_TRANSACTIONS` | 409 | Нельзя удалить счёт с транзакциями |
| `TRANSACTION_NOT_FOUND` | 404 | Транзакция не найдена |
| `CATEGORY_NOT_FOUND` | 404 | Категория не найдена |
| `CATEGORY_SYSTEM_READONLY` | 403 | Системную категорию нельзя изменить |
| `IMPORT_INVALID_FORMAT` | 422 | Неверный формат файла |
| `IMPORT_JOB_NOT_FOUND` | 404 | Задание не найдено |
| `PREDICTION_INSUFFICIENT_DATA` | 422 | Недостаточно данных для прогноза |
| `ORACLE_RATE_LIMIT` | 429 | Превышен лимит запросов к Oracle |
| `VALIDATION_FAILED` | 400 | Ошибка валидации входных данных |
| `INTERNAL_ERROR` | 500 | Внутренняя ошибка сервера |

### Структура ответа с кодом ошибки

```json
{
  "statusCode": 403,
  "error": "ACCOUNT_ACCESS_DENIED",
  "message": "You do not have access to this account"
}
```

---

*Документ актуален для API версии 1.0. Последнее обновление: 2026-02-28.*
