# Task: Monetization - Subscriptions with RevenueCat
Date: 2026-03-05
Status: done

## Plans
- Free: 2 accounts, manual input, dashboard, scheduled payments, notifications
- Premium ($4.99/mo, $34.99/yr): unlimited accounts, Plaid, OCR, Oracle/ML, budgets, debts, export, multi-currency

## Checklist

### Backend (NestJS)
- [x] Subscription model (separate table, not on users)
- [x] SubscriptionsModule (@Global - model, service, controller)
- [x] RevenueCat webhook endpoint (verify + update subscription status)
- [x] PremiumGuard (guard for gating premium endpoints)
- [x] Apply PremiumGuard to: Plaid, Receipts, Predictions, Budgets, Debts, Export
- [x] Account limit enforcement (max 2 for free tier)
- [x] Endpoint: GET /subscriptions/status (return current plan + entitlements)
- [x] Endpoint: POST /subscriptions/sync (sync from mobile RevenueCat SDK)
- [x] Endpoint: POST /subscriptions/webhook (RevenueCat server-to-server)

### Mobile (Flutter)
- [x] Add `purchases_flutter` dependency
- [x] Domain: SubscriptionEntity, SubscriptionRepository
- [x] Data: SubscriptionModel, RevenueCatDatasource, SubscriptionRemoteDataSource, RepositoryImpl
- [x] Presentation: SubscriptionCubit + State
- [x] Paywall page (plans comparison, purchase buttons, restore)
- [x] PremiumGate widget (wraps premium features, shows upgrade prompt)
- [x] Update Settings page (subscription status, manage subscription, dynamic badge)
- [x] Update DI (injection.dart), Router, ApiEndpoints

### Verification
- [x] backend build
- [x] flutter analyze
- [ ] commit & push
