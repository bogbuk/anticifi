# Subscriptions & Monetization

## Overview

AnticiFi uses **RevenueCat** to manage in-app subscriptions across App Store and Google Play.

## Plans

| Plan | Price | Features |
|------|-------|----------|
| **Free** | $0 | Up to 2 accounts, manual input, dashboard, scheduled payments, notifications |
| **Premium Monthly** | $4.99/mo | All features, cancel anytime |
| **Premium Yearly** | $34.99/yr | All features, 42% savings |
| **Premium Lifetime** | $99.99 | One-time payment, all features forever |

## Premium Features (gated)

- Unlimited bank accounts
- Plaid auto bank sync
- Receipt scanning (OCR)
- Oracle / ML predictions
- Smart ML categorization
- Budgets
- Debts tracking
- Data export (CSV/PDF)
- Multi-currency support

## Architecture

### Backend (NestJS)

- **SubscriptionsModule** (`backend/src/modules/subscriptions/`) - @Global module
  - `subscription.model.ts` - Subscription table (tier, status, period, revenuecatId, expiresAt)
  - `subscriptions.service.ts` - Business logic, account limit check (max 2 for free)
  - `subscriptions.controller.ts` - 3 endpoints:
    - `GET /subscriptions/status` - Current plan & entitlements (auth required)
    - `POST /subscriptions/sync` - Sync from mobile RevenueCat SDK (auth required)
    - `POST /subscriptions/webhook` - RevenueCat server-to-server webhook
- **PremiumGuard** (`backend/src/common/guards/premium.guard.ts`) - Applied to: Plaid, Receipts, Predictions, Budgets, Debts, Export controllers

### Mobile (Flutter)

- **Feature**: `mobile/lib/features/subscription/`
  - Domain: `SubscriptionEntity`, `SubscriptionRepository`
  - Data: `RevenueCatDataSource`, `SubscriptionRemoteDataSource`, `SubscriptionRepositoryImpl`
  - Presentation: `SubscriptionCubit`, `PaywallPage`, `PremiumGate` widget
- **Route**: `/subscription` - Paywall page
- **Settings**: Subscription section with dynamic FREE/PREMIUM badge

## RevenueCat Configuration

- **Project**: AnticiFi
- **Entitlement ID**: `AnticiFi Pro`
- **Products**: `monthly`, `yearly`, `lifetime` (all linked to "AnticiFi Pro" entitlement)
- **REST API Entitlement ID**: `entl0ed40c4024`

## Environment Variables

### Backend (.env)

```
REVENUECAT_WEBHOOK_SECRET=<from RevenueCat Dashboard -> Integrations -> Webhooks>
```

### Mobile (build-time)

```bash
flutter run \
  --dart-define=REVENUECAT_IOS_KEY=appl_xxxxxxxxxxxxx \
  --dart-define=REVENUECAT_ANDROID_KEY=goog_xxxxxxxxxxxxx
```

Keys are in: RevenueCat Dashboard -> Project -> API Keys (public app-specific keys).

## Store Setup (not yet done)

### Apple App Store

1. Register at [developer.apple.com](https://developer.apple.com) - Apple Developer Program ($99/year)
2. App Store Connect -> create App -> Bundle ID: `com.anticifi.app`
3. App -> Subscriptions -> create Subscription Group "AnticiFi Pro"
4. Add 3 products with matching product IDs: `monthly` ($4.99), `yearly` ($34.99), `lifetime` ($99.99)
5. App -> App Information -> App-Specific Shared Secret -> copy
6. RevenueCat Dashboard -> Apps -> + New App -> Apple -> paste Shared Secret

### Google Play

1. Register at [play.google.com/console](https://play.google.com/console) - Developer Account ($25 one-time)
2. Create App -> Package Name: `com.anticifi.app`
3. Monetize -> Products -> Subscriptions -> add same 3 products
4. Setup -> API Access -> create Service Account -> download JSON key
5. RevenueCat Dashboard -> Apps -> + New App -> Google -> upload Service Account JSON

### RevenueCat Webhook

1. RevenueCat Dashboard -> Integrations -> Webhooks
2. URL: `https://<your-api-domain>/api/subscriptions/webhook`
3. Copy Authorization header value -> set as `REVENUECAT_WEBHOOK_SECRET` in backend .env

## Pricing in Stores

Prices are configured **in the stores** (App Store Connect / Google Play Console), not in RevenueCat. RevenueCat reads prices from the stores automatically.

To change a price:
- **App Store**: App Store Connect -> My Apps -> [AnticiFi] -> Subscriptions -> select product -> Pricing
- **Google Play**: Play Console -> [AnticiFi] -> Monetize -> Products -> Subscriptions -> select product -> Pricing
