# Task: Implement OCR, Multi-Currency, Export, ML Categorization
Date: 2026-03-02
Status: done

## Checklist

### Feature 2: Multi-Currency
- [x] backend: currency-rate.model.ts
- [x] backend: currency.service.ts
- [x] backend: currency.cron.ts
- [x] backend: currency.controller.ts
- [x] backend: currency.module.ts
- [x] backend: dashboard.service.ts changes
- [x] backend: dashboard.module.ts changes
- [x] mobile: currency_utils.dart
- [x] mobile: dashboard entity/model — baseCurrency + convertedTotalBalance via API

### Feature 4: ML Categorization
- [x] ml-service: categorization.py schema
- [x] ml-service: categorization_service.py
- [x] ml-service: categorization router
- [x] ml-service: main.py update
- [x] ml-service: requirements.txt update
- [x] backend: categorization.service.ts
- [x] backend: categorization.controller.ts
- [x] backend: categorization.module.ts
- [x] backend: dto files
- [x] mobile: transaction entity + datasource changes
- [x] mobile: bloc changes (SuggestCategory event + debounce)
- [x] mobile: transaction form changes (suggestion chips)

### Feature 1: OCR Receipts
- [x] backend: receipt.model.ts
- [x] backend: dto files (scan-receipt, confirm-receipt)
- [x] backend: receipt.service.ts
- [x] backend: receipt.controller.ts
- [x] backend: receipt.module.ts
- [x] mobile: receipt_scan_entity.dart
- [x] mobile: receipt_repository.dart
- [x] mobile: receipt_scan_model.dart
- [x] mobile: receipt_remote_datasource.dart
- [x] mobile: receipt_repository_impl.dart
- [x] mobile: receipt_cubit.dart + state
- [x] mobile: receipt_scan_page.dart

### Feature 3: Data Export
- [x] backend: export.service.ts
- [x] backend: export.controller.ts
- [x] backend: export.module.ts
- [x] mobile: export entity/repo
- [x] mobile: export datasource/repo_impl
- [x] mobile: export cubit + state
- [x] mobile: export_page.dart

### Common Changes
- [x] backend: app.module.ts
- [x] mobile: pubspec.yaml
- [x] mobile: api_endpoints.dart
- [x] mobile: injection.dart
- [x] mobile: app_router.dart
- [x] mobile: settings_page.dart

### Verification
- [x] backend build
- [x] mobile analyze
- [x] ml-service import check (requires venv)
