# Task: Offline Mode with SQLite Local Caching and Sync
Date: 2026-03-05
Status: done

## Checklist
- [x] Add sqflite, connectivity_plus, path dependencies
- [x] Create LocalDatabase service with SQLite tables
- [x] Create ConnectivityService for network monitoring
- [x] Create SyncService for queue processing
- [x] Create TransactionLocalDatasource
- [x] Create AccountLocalDatasource
- [x] Create BudgetLocalDatasource
- [x] Update TransactionsRepositoryImpl with offline-first logic
- [x] Update AccountsRepositoryImpl with offline-first logic
- [x] Update BudgetsRepositoryImpl with offline-first logic
- [x] Create OfflineBanner widget
- [x] Register all new services in DI (injection.dart)
- [x] Update main.dart to init connectivity and sync
- [x] Add OfflineBanner to app.dart

### Verification
- [x] flutter analyze
