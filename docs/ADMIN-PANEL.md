# AnticiFi Admin Panel

## Overview

Full-featured admin panel for managing the AnticiFi fintech application.

- **URL:** https://admin.anticifi.com
- **Stack:** React 19 + Vite + Ant Design 5 + Recharts
- **Auth:** JWT (same as mobile API, requires role=ADMIN)

## Pages

| Page | Route | Description |
|------|-------|-------------|
| Dashboard | `/dashboard` | 8 stat cards + user growth & transaction volume charts |
| Users | `/users` | Paginated list with search, role/tier filters |
| User Detail | `/users/:id` | Info, subscription, role management + tabs (transactions, accounts, budgets, debts) |
| Transactions | `/transactions` | Global transaction viewer with type/date filters |
| Subscriptions | `/subscriptions` | All subscriptions with tier/status filters |
| Analytics | `/analytics` | DAU/WAU/MAU, user growth, transaction volume, revenue, category pie chart |
| Notifications | `/notifications` | Broadcast push notifications (all users or specific) |
| Receipts (OCR) | `/receipts` | OCR scan monitoring — status, confidence, parsed data |
| Audit Logs | `/audit-logs` | Admin action history |
| System | `/system` | API health check, environment info |

## Backend API Endpoints

### Stats & Analytics
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/stats` | Dashboard stats (8 metrics + 30d charts) |
| GET | `/admin/analytics/user-growth?days=90` | User registrations over time |
| GET | `/admin/analytics/transactions?days=90` | Transaction count + volume over time |
| GET | `/admin/analytics/revenue?days=90` | Premium subscription creation over time |
| GET | `/admin/analytics/retention` | DAU / WAU / MAU / total |
| GET | `/admin/analytics/categories` | Top 20 categories by spend |
| GET | `/admin/analytics/subscriptions` | Subscription breakdown by tier+status |

### User Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/users` | Paginated user list (search, role, tier filters) |
| GET | `/admin/users/:id` | User detail with counts |
| PATCH | `/admin/users/:id` | Update user (role, name) |
| DELETE | `/admin/users/:id` | Soft delete user |
| PATCH | `/admin/users/:id/subscription` | Update subscription tier/status |

### User Data (admin access to any user)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/users/:id/transactions` | User's transactions (paginated, filters) |
| GET | `/admin/users/:id/accounts` | User's accounts |
| GET | `/admin/users/:id/budgets` | User's budgets |
| GET | `/admin/users/:id/debts` | User's debts |

### Global Views
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/transactions` | All transactions (paginated, filters) |
| GET | `/admin/subscriptions` | All subscriptions (paginated, filters) |
| GET | `/admin/receipts` | All receipt scans (paginated, status filter) |

### Actions
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/admin/notifications/broadcast` | Send notification to all/specific users |
| GET | `/admin/audit-logs` | Admin action audit trail |

### Setup (no auth, secret-protected)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/admin/setup` | Promote user to ADMIN (x-admin-secret header) |
| POST | `/admin/reset-password` | Reset user password (x-admin-secret header) |

## Architecture

```
admin/
├── src/
│   ├── api/
│   │   ├── client.ts          # Axios instance (baseURL + JWT interceptor)
│   │   ├── admin.ts           # All admin API calls
│   │   ├── auth.ts            # Login/logout
│   │   ├── users.ts           # User CRUD
│   │   └── stats.ts           # Re-exports from admin.ts
│   ├── pages/
│   │   ├── Dashboard.tsx      # Stats + charts
│   │   ├── Users.tsx          # User table
│   │   ├── UserDetail.tsx     # User info + data tabs
│   │   ├── Transactions.tsx   # Global transactions
│   │   ├── Subscriptions.tsx  # All subscriptions
│   │   ├── Analytics.tsx      # Charts & retention
│   │   ├── Notifications.tsx  # Broadcast form
│   │   ├── Receipts.tsx       # OCR monitoring
│   │   ├── AuditLogs.tsx      # Audit trail
│   │   ├── System.tsx         # Health check
│   │   └── Login.tsx          # Auth
│   ├── layouts/
│   │   └── AdminLayout.tsx    # Sidebar + header
│   ├── components/
│   │   └── ProtectedRoute.tsx
│   ├── store/
│   │   └── auth.ts            # Token storage
│   └── App.tsx                # Routes
├── Dockerfile                 # Multi-stage: node build → nginx
├── nginx.conf                 # SPA fallback
└── package.json
```

## Backend Modules

```
backend/src/modules/admin/
├── admin.module.ts              # 9 models registered
├── admin.controller.ts          # 20+ endpoints
├── admin.service.ts             # User management + data access
├── admin-analytics.service.ts   # SQL-based analytics
├── audit-log.model.ts           # Sequelize model
├── audit-log.service.ts         # Logging service
└── dto/
    ├── query-users.dto.ts
    ├── update-user-admin.dto.ts
    └── update-subscription-admin.dto.ts
```

## Deployment

```bash
# Build & deploy admin panel
coolify deploy uuid x0ccooccss4w48oo48488gko

# Build & deploy backend (for new API endpoints)
coolify deploy uuid dos0gk0cg4gk08s8o44s0og4
```

## Access

- Admin user: `bogbuk@gmail.com` (role: ADMIN)
- Setup secret header: `x-admin-secret: anticifi-admin-setup-2026`
