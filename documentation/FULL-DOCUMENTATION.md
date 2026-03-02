# AnticiFi — Full Technical Documentation

> Generated: 2026-03-01
> Based on actual source code analysis

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Backend API Reference](#3-backend-api-reference)
4. [Database Schema](#4-database-schema)
5. [Mobile App Structure](#5-mobile-app-structure)
6. [ML Service](#6-ml-service)
7. [Deployment Guide](#7-deployment-guide)
8. [Development Guide](#8-development-guide)

---

## 1. Project Overview

### Product Description

**AnticiFi** is a personal finance management platform with predictive analytics capabilities. The name combines "Anticipate" and "Finance" — reflecting its core value proposition: helping users anticipate their financial future rather than just track the past.

### Target Audience

Individual consumers who want to:
- Track income and expenses across multiple accounts
- Forecast their future balance using AI/ML
- Get natural language answers to financial questions ("Can I afford a $500 purchase next month?")
- Automate recurring payment tracking
- Import bank statements via CSV

### Key Features

| Feature | Description |
|---|---|
| Multi-account management | Checking, savings, credit, and cash accounts |
| Transaction tracking | Income/expense tracking with categories |
| AI Financial Oracle | Natural language Q&A about user's finances |
| Balance forecasting | 30–180 day balance predictions with confidence intervals |
| Scheduled payments | Recurring payment automation with cron execution |
| CSV import | Bulk transaction import from bank exports |
| Real-time notifications | WebSocket-based alerts and push notifications |
| Dashboard analytics | Monthly stats, spending by category, recent transactions |

---

## 2. Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                             │
└────────────────────────┬────────────────────────────────────┘
                         │ :80 / :443
                ┌────────▼────────┐
                │  Nginx (Reverse │
                │     Proxy)      │
                └────────┬────────┘
                         │ :3000
         ┌───────────────▼──────────────────┐
         │       NestJS Backend API          │
         │  REST + WebSocket (Socket.IO)     │
         │  Global prefix: /api             │
         │  Swagger: /api/docs              │
         └──┬──────────┬──────────┬─────────┘
            │          │          │
       :5432 │     :6379 │    :4222 │
    ┌────────▼─┐  ┌──────▼──┐  ┌───▼────┐
    │PostgreSQL│  │  Redis  │  │  NATS  │
    │  (data)  │  │(sessions│  │(events)│
    │          │  │/cache)  │  │        │
    └──────────┘  └─────────┘  └────────┘
            │
       :8001 │ (HTTP internal)
    ┌────────▼────────┐
    │  Python ML      │
    │  Service        │
    │  (FastAPI +     │
    │   Prophet)      │
    └─────────────────┘
            ▲
            │ REST (internal)
    ┌───────┴────────┐
    │  Flutter Mobile │
    │  App (iOS/      │
    │  Android)       │
    └─────────────────┘
```

### Tech Stack

#### Backend
| Layer | Technology | Version |
|---|---|---|
| Framework | NestJS | - |
| Language | TypeScript | - |
| ORM | Sequelize (sequelize-typescript) | - |
| Authentication | JWT (access: 15m, refresh: 30d) | - |
| Password hashing | bcrypt (rounds: 12) | - |
| HTTP client (ML calls) | Axios (via @nestjs/axios) | - |
| WebSockets | Socket.IO | - |
| Message broker | NATS | - |
| API docs | Swagger / OpenAPI | - |
| Task scheduling | NestJS cron (@nestjs/schedule) | - |

#### Infrastructure
| Component | Technology |
|---|---|
| Database | PostgreSQL 16 |
| Cache / Sessions | Redis 7 |
| Message broker | NATS 2 |
| Reverse proxy | Nginx (alpine) |
| Containerization | Docker + Docker Compose |

#### ML Service
| Component | Technology |
|---|---|
| Framework | FastAPI 0.104.1 |
| Language | Python 3 |
| Forecasting model | Prophet 1.1.5 (Facebook) |
| Data processing | Pandas 2.1.4 |
| Schema validation | Pydantic 2.5.3 |
| ASGI server | Uvicorn 0.24.0 |

#### Mobile App
| Component | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State management | flutter_bloc (BLoC + Cubit) |
| Navigation | go_router |
| HTTP client | Dio |
| Token storage | flutter_secure_storage |
| DI container | get_it |
| Fonts | Google Fonts (Inter) |

### Service Communication

```
Mobile App  ──[HTTP REST + JWT]──►  Backend (port 3000)
Mobile App  ──[WebSocket]─────────►  Backend (Socket.IO)
Backend     ──[HTTP POST]─────────►  ML Service (port 8001)
Backend     ──[Sequelize]─────────►  PostgreSQL (port 5432)
Backend     ──[ioredis]───────────►  Redis (port 6379)
Backend     ──[NATS client]───────►  NATS (port 4222)
```

---

## 3. Backend API Reference

All endpoints are prefixed with `/api`. Swagger UI is available at `/api/docs`.

### Authentication

JWT Bearer authentication. Access token lifetime: **15 minutes**. Refresh token lifetime: **30 days**.

Token payload: `{ userId: string, email: string }`

---

### Auth Module (`/api/auth`)

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | No | Register a new user |
| POST | `/api/auth/login` | No | Login and receive tokens |
| POST | `/api/auth/refresh` | No | Refresh access token |
| POST | `/api/auth/logout` | No | Logout (client-side token removal) |
| GET | `/api/auth/profile` | JWT | Get current user info from token |

#### POST /api/auth/register
```json
// Request
{
  "email": "user@example.com",
  "password": "securepassword",
  "firstName": "John",      // optional
  "lastName": "Doe"         // optional
}

// Response 201
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "isEmailVerified": false,
    "currency": "USD",
    "createdAt": "2026-01-01T00:00:00Z"
  }
}
```

#### POST /api/auth/login
```json
// Request
{
  "email": "user@example.com",
  "password": "securepassword"
}

// Response 200 — same structure as register
```

#### POST /api/auth/refresh
```json
// Request
{
  "refreshToken": "eyJ..."
}

// Response 200
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ..."
}
```

---

### Users Module (`/api/users`)

All endpoints require JWT.

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/users/profile` | JWT | Get full user profile |
| PATCH | `/api/users/profile` | JWT | Update user profile |
| DELETE | `/api/users/account` | JWT | Soft-delete user account |

#### PATCH /api/users/profile
```json
// Request (all fields optional)
{
  "firstName": "John",
  "lastName": "Doe",
  "avatarUrl": "https://...",
  "currency": "EUR",
  "locale": "en",
  "notificationsEnabled": true,
  "theme": "dark"    // "dark" | "light" | "system"
}
```

---

### Accounts Module (`/api/accounts`)

All endpoints require JWT. Resources are scoped to the authenticated user.

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/accounts` | JWT | List all accounts |
| GET | `/api/accounts/:id` | JWT | Get account by ID |
| POST | `/api/accounts` | JWT | Create account |
| PATCH | `/api/accounts/:id` | JWT | Update account |
| DELETE | `/api/accounts/:id` | JWT | Delete account |

#### POST /api/accounts
```json
// Request
{
  "name": "Main Checking",
  "type": "checking",        // "checking" | "savings" | "credit" | "cash"
  "bank": "Chase",           // optional
  "currency": "USD",
  "initialBalance": 1500.00
}

// Response 201
{
  "id": "uuid",
  "userId": "uuid",
  "name": "Main Checking",
  "type": "checking",
  "bank": "Chase",
  "currency": "USD",
  "balance": 1500.00,
  "initialBalance": 1500.00,
  "isActive": true,
  "createdAt": "...",
  "updatedAt": "..."
}
```

---

### Transactions Module (`/api/transactions`)

All endpoints require JWT.

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/transactions` | JWT | List transactions (with filters) |
| GET | `/api/transactions/:id` | JWT | Get transaction by ID |
| POST | `/api/transactions` | JWT | Create transaction |
| PATCH | `/api/transactions/:id` | JWT | Update transaction |
| DELETE | `/api/transactions/:id` | JWT | Soft-delete transaction |

#### GET /api/transactions — Query Parameters
| Param | Type | Description |
|---|---|---|
| accountId | string (UUID) | Filter by account |
| type | string | `income` or `expense` |
| categoryId | string (UUID) | Filter by category |
| startDate | string (YYYY-MM-DD) | Date range start |
| endDate | string (YYYY-MM-DD) | Date range end |
| page | string | Page number (default: 1) |
| limit | string | Items per page (default: 20) |

#### POST /api/transactions
```json
// Request
{
  "accountId": "uuid",
  "amount": 150.00,
  "type": "expense",         // "income" | "expense"
  "description": "Grocery store",  // optional
  "categoryId": "uuid",            // optional
  "date": "2026-03-01"
}

// Response 201
{
  "id": "uuid",
  "accountId": "uuid",
  "userId": "uuid",
  "amount": "150.00",
  "type": "expense",
  "description": "Grocery store",
  "categoryId": "uuid",
  "date": "2026-03-01",
  "transactionHash": null,
  "createdAt": "...",
  "updatedAt": "...",
  "category": { "id": "uuid", "name": "Food" },
  "account": { "id": "uuid", "name": "Main Checking" }
}
```

---

### Categories Module (`/api/categories`)

All endpoints require JWT.

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/categories` | JWT | List categories (user + defaults) |
| POST | `/api/categories` | JWT | Create custom category |
| PATCH | `/api/categories/:id` | JWT | Update category |
| DELETE | `/api/categories/:id` | JWT | Delete category |

#### POST /api/categories
```json
// Request
{
  "name": "Coffee",
  "icon": "coffee",      // optional — icon identifier
  "color": "#6B4EFF",   // optional — hex color
  "parentId": "uuid"    // optional — for subcategories
}
```

---

### Dashboard Module (`/api/dashboard`)

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/dashboard` | JWT | Get aggregated dashboard data |

#### GET /api/dashboard — Response
```json
{
  "totalBalance": 4250.00,
  "currentMonth": {
    "income": 3000.00,
    "expense": 1200.00,
    "net": 1800.00
  },
  "previousMonth": {
    "income": 2800.00,
    "expense": 1500.00,
    "net": 1300.00
  },
  "recentTransactions": [
    {
      "id": "uuid",
      "amount": 150.00,
      "type": "expense",
      "description": "Grocery store",
      "date": "2026-03-01",
      "categoryName": "Food",
      "accountName": "Main Checking"
    }
  ],
  "accounts": [
    {
      "id": "uuid",
      "name": "Main Checking",
      "type": "checking",
      "currency": "USD",
      "balance": 4250.00
    }
  ],
  "spendingByCategory": [
    { "categoryId": "uuid", "categoryName": "Food", "total": 450.00 }
  ]
}
```

---

### Scheduled Payments Module (`/api/scheduled-payments`)

All endpoints require JWT.

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/scheduled-payments` | JWT | List scheduled payments |
| GET | `/api/scheduled-payments/:id` | JWT | Get payment by ID |
| POST | `/api/scheduled-payments` | JWT | Create scheduled payment |
| PATCH | `/api/scheduled-payments/:id` | JWT | Update scheduled payment |
| DELETE | `/api/scheduled-payments/:id` | JWT | Soft-delete payment |
| POST | `/api/scheduled-payments/:id/execute` | JWT | Manually execute payment |

#### POST /api/scheduled-payments
```json
// Request
{
  "accountId": "uuid",
  "name": "Netflix",
  "amount": 15.99,
  "type": "expense",           // "income" | "expense"
  "frequency": "monthly",      // "daily"|"weekly"|"biweekly"|"monthly"|"quarterly"|"yearly"
  "startDate": "2026-03-01",
  "endDate": null,             // optional
  "categoryId": "uuid",        // optional
  "description": "Streaming"   // optional
}
```

---

### Predictions / Oracle Module (`/api/predictions`)

All endpoints require JWT. Backend fetches transaction data and calls ML service internally.

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/predictions` | JWT | Generate balance forecast |
| GET | `/api/predictions/forecast/:accountId` | JWT | Forecast for specific account |
| POST | `/api/predictions/chat` | JWT | Natural language financial Q&A |

#### POST /api/predictions
```json
// Request
{
  "accountId": "uuid",   // optional — omit for total balance forecast
  "daysAhead": 30        // optional, default: 30
}

// Response
{
  "predictions": [
    {
      "date": "2026-03-02",
      "predictedBalance": 4180.00,
      "lowerBound": 3950.00,
      "upperBound": 4410.00
    }
  ],
  "currentBalance": 4250.00,
  "confidence": 0.80
}
```

#### POST /api/predictions/chat
```json
// Request
{
  "question": "Can I afford a $500 purchase next month?"
}

// Response
{
  "answer": "Yes, you can likely afford a $500.00 purchase. Your lowest predicted balance over the next 30 days is $3,200.00, leaving you $2,700.00 after the purchase.",
  "predictions": [...]   // optional — included for visual charts
}
```

---

### Import Module (`/api/import`)

All endpoints require JWT.

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/import/csv` | JWT | Upload and process CSV file |
| GET | `/api/import/jobs` | JWT | List import jobs |
| GET | `/api/import/jobs/:id` | JWT | Get import job status |

#### POST /api/import/csv
```
Content-Type: multipart/form-data

Fields:
  file       — CSV file (required)
  accountId  — target account UUID (required)
```

```json
// Response 201
{
  "id": "uuid",
  "status": "completed",
  "importedCount": 45,
  "skippedCount": 3,
  "errorCount": 0
}
```

---

### Notifications Module (`/api/notifications`)

All endpoints require JWT.

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/notifications` | JWT | List notifications |
| GET | `/api/notifications/unread-count` | JWT | Get count of unread notifications |
| PATCH | `/api/notifications/:id/read` | JWT | Mark notification as read |
| PATCH | `/api/notifications/read-all` | JWT | Mark all notifications as read |

---

### Health Module (`/api/health`)

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/health` | No | Service health check |

---

### WebSocket Events

**Connection:** `ws://host:3000` with JWT token in handshake auth.

```javascript
// Client connection
const socket = io('http://localhost:3000', {
  auth: { token: 'Bearer eyJ...' }
});
```

Upon connection, the server verifies the JWT and places the socket into a user-specific room (`user:{userId}`).

**Events emitted by server:**
| Event | Trigger |
|---|---|
| `notification` | New notification created (scheduled payment executed, balance alert, etc.) |

---

## 4. Database Schema

**ORM:** Sequelize with sequelize-typescript decorators.
**Convention:** All tables use `snake_case` column names (`underscored: true`), UUIDs as primary keys.
**Soft deletes:** Models using `paranoid: true` have a `deleted_at` column and are never physically deleted.

---

### Table: `users`

| Column | Type | Constraints | Description |
|---|---|---|---|
| id | UUID | PK, default: UUIDV4 | Primary key |
| email | VARCHAR(255) | UNIQUE, NOT NULL | User's email address |
| password_hash | VARCHAR(255) | NOT NULL | bcrypt hash (12 rounds) |
| first_name | VARCHAR(100) | NULL | Optional first name |
| last_name | VARCHAR(100) | NULL | Optional last name |
| avatar_url | VARCHAR(500) | NULL | Profile avatar URL |
| currency | VARCHAR(3) | NOT NULL, default: 'USD' | Preferred currency |
| locale | VARCHAR(10) | NOT NULL, default: 'en' | Display locale |
| notifications_enabled | BOOLEAN | NOT NULL, default: true | Push notification toggle |
| theme | ENUM | NOT NULL, default: 'system' | 'dark' \| 'light' \| 'system' |
| is_email_verified | BOOLEAN | NOT NULL, default: false | Email verification status |
| last_login_at | TIMESTAMP | NULL | Last login timestamp |
| created_at | TIMESTAMP | NOT NULL | Auto-managed |
| updated_at | TIMESTAMP | NOT NULL | Auto-managed |
| deleted_at | TIMESTAMP | NULL | Soft delete (paranoid) |

**Relationships:**
- `hasMany` → accounts
- `hasMany` → transactions
- `hasMany` → categories
- `hasMany` → scheduled_payments
- `hasMany` → notifications
- `hasMany` → import_jobs

---

### Table: `accounts`

| Column | Type | Constraints | Description |
|---|---|---|---|
| id | UUID | PK | Primary key |
| user_id | UUID | FK → users, NOT NULL | Owner |
| name | VARCHAR(100) | NOT NULL | Account display name |
| type | ENUM | NOT NULL | 'checking' \| 'savings' \| 'credit' \| 'cash' |
| bank | VARCHAR(100) | NULL | Bank name (optional) |
| currency | VARCHAR(3) | NOT NULL, default: 'USD' | Account currency |
| balance | DECIMAL(15,2) | NOT NULL, default: 0 | Current balance |
| initial_balance | DECIMAL(15,2) | NOT NULL, default: 0 | Balance at account creation |
| is_active | BOOLEAN | NOT NULL, default: true | Account active flag |
| created_at | TIMESTAMP | NOT NULL | Auto-managed |
| updated_at | TIMESTAMP | NOT NULL | Auto-managed |

**Relationships:**
- `belongsTo` → users
- `hasMany` → transactions
- `hasMany` → scheduled_payments
- `hasMany` → import_jobs

---

### Table: `transactions`

| Column | Type | Constraints | Description |
|---|---|---|---|
| id | UUID | PK | Primary key |
| account_id | UUID | FK → accounts, NOT NULL | Source account |
| user_id | UUID | FK → users, NOT NULL | Owner (denormalized for queries) |
| amount | DECIMAL(15,2) | NOT NULL | Transaction amount (always positive) |
| type | ENUM | NOT NULL | 'income' \| 'expense' |
| description | VARCHAR(500) | NULL | Optional description |
| category_id | UUID | FK → categories, NULL | Optional category |
| date | DATE | NOT NULL | Transaction date (YYYY-MM-DD) |
| transaction_hash | VARCHAR(64) | UNIQUE, NULL | Dedup hash for CSV imports |
| created_at | TIMESTAMP | NOT NULL | Auto-managed |
| updated_at | TIMESTAMP | NOT NULL | Auto-managed |
| deleted_at | TIMESTAMP | NULL | Soft delete (paranoid) |

**Indexes:**
- `(account_id, date)` — filtering by account over time
- `(user_id, date)` — filtering all user transactions by date
- `(transaction_hash)` UNIQUE — CSV import deduplication

**Relationships:**
- `belongsTo` → accounts
- `belongsTo` → users
- `belongsTo` → categories (nullable)

---

### Table: `categories`

| Column | Type | Constraints | Description |
|---|---|---|---|
| id | UUID | PK | Primary key |
| name | VARCHAR(100) | NOT NULL | Category name |
| icon | VARCHAR(50) | NULL | Icon identifier |
| color | VARCHAR(20) | NULL | Hex color code |
| is_default | BOOLEAN | NOT NULL, default: false | System-wide default category |
| user_id | UUID | FK → users, NULL | NULL = system default |
| parent_id | UUID | FK → categories, NULL | Parent for subcategories |
| created_at | TIMESTAMP | NOT NULL | Auto-managed |
| updated_at | TIMESTAMP | NOT NULL | Auto-managed |
| deleted_at | TIMESTAMP | NULL | Soft delete (paranoid) |

**Notes:**
- Categories with `user_id = NULL` and `is_default = TRUE` are global defaults visible to all users.
- Users can create custom categories under their own `user_id`.
- Supports one level of nesting via `parent_id`.

**Relationships:**
- `belongsTo` → users (nullable)
- `belongsTo` → Category (self-reference via parentId)
- `hasMany` → Category (children, self-reference)

---

### Table: `scheduled_payments`

| Column | Type | Constraints | Description |
|---|---|---|---|
| id | UUID | PK | Primary key |
| user_id | UUID | FK → users, NOT NULL | Owner |
| account_id | UUID | FK → accounts, NOT NULL | Target account |
| category_id | UUID | FK → categories, NULL | Optional category |
| name | VARCHAR(255) | NOT NULL | Payment name |
| amount | DECIMAL(15,2) | NOT NULL | Payment amount |
| type | ENUM | NOT NULL | 'income' \| 'expense' |
| frequency | ENUM | NOT NULL | 'daily' \| 'weekly' \| 'biweekly' \| 'monthly' \| 'quarterly' \| 'yearly' |
| start_date | DATE | NOT NULL | First execution date |
| end_date | DATE | NULL | Optional end date |
| next_execution_date | DATE | NOT NULL | Next scheduled execution |
| is_active | BOOLEAN | NOT NULL, default: true | Active flag |
| last_executed_at | TIMESTAMP | NULL | Last actual execution |
| description | VARCHAR(500) | NULL | Optional notes |
| created_at | TIMESTAMP | NOT NULL | Auto-managed |
| updated_at | TIMESTAMP | NOT NULL | Auto-managed |
| deleted_at | TIMESTAMP | NULL | Soft delete (paranoid) |

**Indexes:**
- `(user_id, is_active)` — list active payments per user
- `(next_execution_date, is_active)` — cron job query for due payments

---

### Table: `notifications`

| Column | Type | Constraints | Description |
|---|---|---|---|
| id | UUID | PK | Primary key |
| user_id | UUID | FK → users, NOT NULL | Target user |
| title | VARCHAR(255) | NOT NULL | Notification title |
| body | VARCHAR(1000) | NOT NULL | Notification body text |
| type | ENUM | NOT NULL | 'balance_alert' \| 'payment_reminder' \| 'prediction_alert' \| 'system' |
| is_read | BOOLEAN | NOT NULL, default: false | Read status |
| metadata | JSONB | NULL | Arbitrary additional data |
| created_at | TIMESTAMP | NOT NULL | Auto-managed |
| updated_at | TIMESTAMP | NOT NULL | Auto-managed |

**Indexes:**
- `(user_id, is_read)` — unread count queries
- `(user_id, created_at)` — sorted listing

---

### Table: `import_jobs`

| Column | Type | Constraints | Description |
|---|---|---|---|
| id | UUID | PK | Primary key |
| user_id | UUID | FK → users, NOT NULL | Owner |
| account_id | UUID | FK → accounts, NOT NULL | Target account |
| status | ENUM | NOT NULL, default: 'pending' | 'pending' \| 'processing' \| 'completed' \| 'failed' |
| format | ENUM | NOT NULL | 'csv' \| 'ocr' |
| imported_count | INTEGER | NOT NULL, default: 0 | Successfully imported rows |
| skipped_count | INTEGER | NOT NULL, default: 0 | Duplicate/skipped rows |
| error_count | INTEGER | NOT NULL, default: 0 | Failed rows |
| error_details | JSON | NULL | Error details array |
| started_at | TIMESTAMP | NULL | Processing start time |
| completed_at | TIMESTAMP | NULL | Processing end time |
| created_at | TIMESTAMP | NOT NULL | Auto-managed |
| updated_at | TIMESTAMP | NOT NULL | Auto-managed |
| deleted_at | TIMESTAMP | NULL | Soft delete (paranoid) |

---

### Entity Relationship Diagram

```
users
  │
  ├──< accounts
  │       │
  │       ├──< transactions >── categories
  │       ├──< scheduled_payments >── categories
  │       └──< import_jobs
  │
  ├──< categories (user-owned)
  ├──< notifications
  └──< import_jobs
```

---

## 5. Mobile App Structure

### Architecture Pattern

The mobile app follows **Clean Architecture** with feature-first folder organization:

```
lib/
├── main.dart               — App entry point, DI setup
├── app.dart                — Root widget, BLoC providers, router creation
├── core/
│   ├── di/
│   │   └── injection.dart  — GetIt DI container setup
│   ├── network/
│   │   ├── dio_client.dart     — Dio HTTP client with auth interceptors
│   │   └── api_endpoints.dart  — API URL constants
│   ├── router/
│   │   └── app_router.dart     — GoRouter configuration
│   ├── storage/
│   │   └── secure_storage.dart — FlutterSecureStorage wrapper
│   └── theme/
│       ├── app_theme.dart      — Material3 dark theme
│       └── app_colors.dart     — Color palette
└── features/
    ├── auth/
    ├── home/
    ├── dashboard/
    ├── transactions/
    ├── accounts/
    ├── oracle/
    ├── settings/
    ├── notifications/
    ├── import/
    └── scheduled_payments/
```

### Feature Module Structure

Each feature follows the same three-layer pattern:

```
features/<feature>/
├── data/
│   ├── datasources/   — Remote API calls (Dio)
│   └── repositories/  — Repository implementations
├── domain/
│   ├── entities/      — Pure Dart data classes
│   └── repositories/  — Abstract repository interfaces
└── presentation/
    ├── bloc/          — BLoC or Cubit (state management)
    └── pages/         — Flutter widgets / screens
```

### Feature Modules

| Feature | State Manager | Description |
|---|---|---|
| auth | `AuthBloc` | Login, registration, token refresh, logout |
| home | (shell) | Bottom navigation shell wrapper |
| dashboard | `DashboardCubit` | Financial overview, stats, recent transactions |
| transactions | `TransactionsBloc` | Transaction list, create/edit/delete |
| accounts | `AccountsCubit` | Account CRUD |
| oracle | `OracleCubit` | AI financial Q&A and balance forecasting |
| settings | `SettingsCubit` | User profile edit, preferences |
| notifications | `NotificationsCubit` | Notification list, read/unread management |
| import | `ImportCubit` | CSV file upload and import status |
| scheduled_payments | `ScheduledPaymentsCubit` | Recurring payment CRUD |

### Navigation Flow

```
/ (Splash)
│
├── /auth/login          — Login page
│   └── /auth/register   — Registration page
│
└── [Shell: HomePage with BottomNav]
    ├── /dashboard        — Financial overview (default after login)
    ├── /transactions     — Transaction list
    ├── /oracle           — AI Oracle chat + forecast chart
    └── /settings         — User settings

    [Modal / Stack routes]
    ├── /accounts               — Accounts list
    ├── /accounts/add           — New account form
    ├── /accounts/:id/edit      — Edit account form
    ├── /transactions/add       — New transaction form
    ├── /transactions/:id/edit  — Edit transaction form
    ├── /import                 — CSV import page
    ├── /scheduled-payments     — Scheduled payments list
    ├── /scheduled-payments/add — New scheduled payment
    ├── /scheduled-payments/:id/edit — Edit scheduled payment
    ├── /notifications          — Notifications list
    └── /settings/edit-profile  — Edit profile page
```

### State Management Pattern

**BLoC** is used for complex event-driven features (auth, transactions).
**Cubit** is used for simpler state (dashboard, accounts, oracle, settings, notifications).

```dart
// Auth flow example
AuthBloc states:
  AuthInitial       — checking stored tokens
  AuthLoading       — login/register in progress
  AuthAuthenticated  — user is logged in
  AuthUnauthenticated — no valid session
  AuthError         — login failed
```

### Authentication Flow (Mobile)

1. App starts → `AuthBloc` reads tokens from `FlutterSecureStorage`
2. If tokens exist → validates and transitions to `AuthAuthenticated`
3. If no tokens → transitions to `AuthUnauthenticated` → GoRouter redirects to `/auth/login`
4. On 401 response → `DioClient._refreshInterceptor` automatically calls `/auth/refresh`
5. If refresh fails → tokens cleared → GoRouter redirects to `/auth/login`

### HTTP Client Configuration

```dart
// Base URL (platform-aware)
Android emulator: http://10.0.2.2:3000/api
iOS simulator:    http://localhost:3000/api

// Timeouts
connectTimeout: 10 seconds
receiveTimeout: 10 seconds

// Interceptors (in order)
1. _authInterceptor  — injects "Authorization: Bearer {token}" header
2. _refreshInterceptor — handles 401, refreshes token, retries request
```

### Design System

- **Theme:** Dark-only (`AppTheme.darkTheme`)
- **Material version:** Material 3 (`useMaterial3: true`)
- **Font:** Inter (Google Fonts)
- **Border radius:** 12px for all inputs and cards

---

## 6. ML Service

### Overview

The ML service is a standalone **FastAPI** application that provides balance forecasting. It is called exclusively by the NestJS backend — it is not exposed to the mobile app directly.

**Base URL (internal):** `http://ml-service:8001`

### Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Service health check |
| POST | `/api/predict` | Generate balance forecast |
| POST | `/api/predict/chat` | Process natural language financial question |
| GET | `/api/predict/health` | Prediction engine health |

---

#### POST /api/predict — Balance Forecast

```json
// Request
{
  "transactions": [
    {
      "date": "2026-01-15",
      "amount": 150.00,
      "type": "expense"
    }
  ],
  "currentBalance": 4250.00,
  "daysAhead": 30
}

// Response
{
  "predictions": [
    {
      "date": "2026-03-02",
      "predictedBalance": 4180.00,
      "lowerBound": 3950.00,
      "upperBound": 4410.00
    }
  ],
  "currentBalance": 4250.00,
  "confidence": 0.80
}
```

#### POST /api/predict/chat — Natural Language Q&A

```json
// Request
{
  "question": "Can I afford a $500 purchase next month?",
  "transactions": [...],
  "currentBalance": 4250.00,
  "scheduledPayments": [
    {
      "name": "Netflix",
      "amount": 15.99,
      "type": "expense",
      "frequency": "monthly",
      "nextExecutionDate": "2026-03-15"
    }
  ]
}

// Response
{
  "answer": "Yes, you can likely afford a $500.00 purchase...",
  "predictions": [...]   // null or array of PredictionPoint
}
```

---

### Prediction Algorithm

The ML service uses **Facebook Prophet** — a time-series forecasting model designed for business data with strong seasonal patterns.

#### Training Process (`BalancePredictor.train`)

1. Receives list of transactions with `date`, `amount`, `type`
2. Converts to Prophet-format DataFrame: `ds` (date), `y` (net daily change)
   - Income transactions: `y = +amount`
   - Expense transactions: `y = -amount`
3. Groups by date, sums net daily changes
4. Fills missing dates with `y = 0`
5. Fits Prophet model with:
   - `weekly_seasonality = True`
   - `yearly_seasonality = True`
   - `daily_seasonality = False`
   - `changepoint_prior_scale = 0.05` (conservative trend changes)
   - `interval_width = 0.80` (80% confidence intervals)
6. Requires minimum **7 data points** (configurable via `MIN_DATA_POINTS`)

#### Prediction Process (`BalancePredictor.predict`)

1. Prophet generates daily `yhat` (predicted change), `yhat_lower`, `yhat_upper`
2. Starting from `current_balance`, applies cumulative sum of daily changes
3. Returns list of `{ date, predictedBalance, lowerBound, upperBound }`
4. Falls back to flat prediction (current balance ±10%) if insufficient data

#### Confidence Scoring

| Condition | Confidence |
|---|---|
| Model not trained (< 7 transactions) | 0.30 |
| Model trained (baseline) | 0.75 |
| 30–89 transactions | +0.05 (max 0.90) |
| 90+ transactions | +0.15 (max 0.95) |

#### Natural Language Question Patterns

The `process_chat_question` function supports four question types via regex pattern matching:

| Pattern | Example | Handler |
|---|---|---|
| Balance on date | "What will my balance be on March 15?" | `_handle_balance_on_date` |
| Affordability | "Can I afford a $500 purchase next month?" | `_handle_afford_check` |
| Runout | "When will I run out of money?" | `_handle_runout_question` |
| Spending budget | "How much can I spend this month?" | `_handle_spending_budget` |
| Default | Anything else | `_handle_general_forecast` (30-day summary) |

#### Fallback Behavior

If Prophet cannot fit (insufficient or zero-value data), `_fallback_predict` returns:
- `predictedBalance = current_balance` (flat)
- `lowerBound = current_balance * 0.9`
- `upperBound = current_balance * 1.1`

### Configuration (`app/config.py`)

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8001` | Service port |
| `HOST` | `0.0.0.0` | Bind address |
| `LOG_LEVEL` | `info` | Logging level |
| `MIN_DATA_POINTS` | `7` | Minimum transactions required for training |
| `DEFAULT_FORECAST_DAYS` | `30` | Default forecast horizon |
| `SAFETY_BUFFER_PERCENT` | `0.10` | Buffer for spending budget calculations (10%) |

---

## 7. Deployment Guide

### Prerequisites

- Docker >= 24.0
- Docker Compose >= 2.0
- Domain name (for production)
- SSL certificates (for HTTPS)

### Docker Services

| Service | Image | Port | Purpose |
|---|---|---|---|
| nginx | nginx:alpine | 80, 443 | Reverse proxy, SSL termination |
| backend | ./backend (custom) | 3000 | NestJS API |
| ml-service | ./ml-service (custom) | 8001 | Python ML forecasting |
| postgres | postgres:16-alpine | 5432 | Primary database |
| redis | redis:7-alpine | 6379 | Cache / sessions |
| nats | nats:2-alpine | 4222, 8222 | Message broker |

### Environment Variables

Create `.env` file in the project root:

```bash
# Database
DB_NAME=anticifi_dev
DB_USER=anticifi
DB_PASSWORD=your_secure_password_here
DB_HOST=postgres
DB_PORT=5432

# JWT
JWT_SECRET=your_jwt_secret_at_least_32_chars
JWT_REFRESH_SECRET=your_refresh_secret_at_least_32_chars

# ML Service
ML_SERVICE_URL=http://ml-service:8001

# App
NODE_ENV=production
PORT=3000
```

### Starting the Stack

```bash
# Development
docker compose up

# Production (detached)
docker compose up -d

# View logs
docker compose logs -f backend
docker compose logs -f ml-service

# Stop
docker compose down

# Stop and remove volumes (destructive — deletes all data)
docker compose down -v
```

### Health Checks

| Service | Endpoint | Interval |
|---|---|---|
| backend | `GET http://localhost:3000/api/health` | 30s |
| postgres | `pg_isready` | 10s |
| redis | `redis-cli ping` | 10s |

Backend waits for postgres and redis to be healthy before starting (`depends_on: condition: service_healthy`).

### Nginx Configuration

Nginx serves as the entry point on ports 80/443. Config is mounted from `./nginx/nginx.conf`.
SSL certificates are mounted from `./nginx/ssl/` (read-only).

### Volume Persistence

| Volume | Purpose |
|---|---|
| `pgdata` | PostgreSQL data |
| `redisdata` | Redis persistence (saves every 6 hours if ≥1 change) |

### Production Checklist

- [ ] Change all default passwords in `.env`
- [ ] Set `JWT_SECRET` and `JWT_REFRESH_SECRET` to cryptographically random strings (≥32 chars)
- [ ] Configure real SSL certificates in `nginx/ssl/`
- [ ] Set `NODE_ENV=production`
- [ ] Enable PostgreSQL connection pooling (PgBouncer) for high traffic
- [ ] Set up external backup for `pgdata` volume
- [ ] Configure log aggregation (Loki, Datadog, etc.)
- [ ] Set up monitoring / alerting (Prometheus + Grafana)
- [ ] Review Nginx rate limiting configuration
- [ ] Set `CORS` origins to specific domains in backend (currently `*`)
- [ ] Set `allow_origins` in ML service CORS (currently `*`)

---

## 8. Development Guide

### Local Setup (without Docker)

#### 1. Backend

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env  # Edit with local values

# Run database migrations (Sequelize auto-sync in dev)
# Tables are created automatically on first start

# Start development server
npm run start:dev
```

Backend runs at: `http://localhost:3000`
Swagger UI: `http://localhost:3000/api/docs`

#### 2. ML Service

```bash
cd ml-service

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run service
uvicorn app.main:app --reload --port 8001
```

ML service runs at: `http://localhost:8001`
Auto-docs: `http://localhost:8001/docs`

#### 3. Mobile App

```bash
cd mobile

# Get Flutter dependencies
flutter pub get

# Verify setup
flutter doctor

# Run on connected device or emulator
flutter run

# Run on specific device
flutter run -d ios
flutter run -d android
```

**Note:** On Android emulator, the base URL is automatically set to `http://10.0.2.2:3000/api`. On iOS simulator, it uses `http://localhost:3000/api`.

### Running with Docker (recommended for full-stack)

```bash
# Start all services
docker compose up

# The mobile app connects to the backend
# Make sure backend is running before starting mobile app
```

### Running Tests

```bash
# Backend unit tests
cd backend && npm run test

# Backend e2e tests
cd backend && npm run test:e2e

# Backend test coverage
cd backend && npm run test:cov

# Mobile tests
cd mobile && flutter test
```

### Code Conventions

#### Backend (TypeScript / NestJS)

- **Architecture:** One module per domain feature in `src/modules/`
- **Naming:** `kebab-case` for files, `PascalCase` for classes, `camelCase` for methods
- **DTOs:** All request bodies use DTOs with class-validator decorators
- **Auth:** Use `@UseGuards(JwtAuthGuard)` + `@CurrentUser()` decorator
- **Response:** Services return data directly; controllers pass through
- **Errors:** Throw NestJS built-in exceptions (`NotFoundException`, `BadRequestException`, etc.)

#### Mobile (Dart / Flutter)

- **Architecture:** Clean Architecture — data / domain / presentation layers per feature
- **State:** BLoC for complex flows (auth), Cubit for simpler state (settings, dashboard)
- **DI:** All dependencies registered in `core/di/injection.dart` via GetIt
- **Navigation:** All routes defined in `core/router/app_router.dart`
- **API calls:** Through `DioClient` → remote data sources → repositories → BLoC/Cubit
- **Storage:** Tokens stored in `FlutterSecureStorage` via `SecureStorage` wrapper

#### ML Service (Python / FastAPI)

- **Architecture:** Routers → Services → Models (predictor)
- **Naming:** `snake_case` for all Python identifiers
- **Validation:** All request/response schemas defined with Pydantic models in `app/schemas/`
- **Logging:** Use `logging.getLogger(__name__)` per module

### Adding a New Backend Module

1. Create directory: `backend/src/modules/<name>/`
2. Create `<name>.module.ts`, `<name>.controller.ts`, `<name>.service.ts`
3. Create model in `<name>.model.ts` (if DB table needed)
4. Register module in `backend/src/app.module.ts`
5. Add Sequelize model to database config if new table

### Adding a New Mobile Feature

1. Create directory: `mobile/lib/features/<name>/`
2. Create `data/`, `domain/`, `presentation/` subdirectories
3. Implement data source, repository interface, repository impl
4. Create Cubit or BLoC in `presentation/bloc/`
5. Register in `core/di/injection.dart`
6. Add routes in `core/router/app_router.dart`

---

*Documentation reflects code as of 2026-03-01.*
