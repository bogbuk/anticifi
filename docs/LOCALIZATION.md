# AnticiFi Localization (i18n/l10n)

## Overview

The mobile app supports **12 languages** using Flutter's built-in localization system (`flutter_localizations` + `intl` + ARB files).

## Supported Languages

| Code | Language | ARB File |
|------|----------|----------|
| `en` | English (default) | `app_en.arb` |
| `ru` | Русский | `app_ru.arb` |
| `ro` | Română | `app_ro.arb` |
| `es` | Español | `app_es.arb` |
| `fr` | Français | `app_fr.arb` |
| `de` | Deutsch | `app_de.arb` |
| `uk` | Українська | `app_uk.arb` |
| `pt` | Português | `app_pt.arb` |
| `it` | Italiano | `app_it.arb` |
| `tr` | Türkçe | `app_tr.arb` |
| `zh` | 中文 | `app_zh.arb` |
| `ja` | 日本語 | `app_ja.arb` |

## Architecture

### File Structure

```
mobile/
├── l10n.yaml                          # L10n generation config
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb                 # Template ARB (English, ~200 keys)
│   │   ├── app_ru.arb                 # Russian translations
│   │   ├── app_ro.arb                 # Romanian translations
│   │   ├── app_es.arb                 # Spanish translations
│   │   ├── app_fr.arb                 # French translations
│   │   ├── app_de.arb                 # German translations
│   │   ├── app_uk.arb                 # Ukrainian translations
│   │   ├── app_pt.arb                 # Portuguese translations
│   │   ├── app_it.arb                 # Italian translations
│   │   ├── app_tr.arb                 # Turkish translations
│   │   ├── app_zh.arb                 # Chinese translations
│   │   ├── app_ja.arb                 # Japanese translations
│   │   ├── app_localizations.dart     # Generated (DO NOT EDIT)
│   │   ├── app_localizations_en.dart  # Generated
│   │   └── ...                        # Generated for each locale
│   └── core/
│       └── locale/
│           ├── locale_cubit.dart      # Manages active locale via BLoC
│           └── locale_state.dart      # Equatable state with Locale
```

### Key Components

- **LocaleCubit** (`lib/core/locale/locale_cubit.dart`) — manages the active locale, persists selection to `SecureStorage` under key `app_locale`
- **LocaleState** — Equatable state holding a `Locale` object
- **AppLocalizations** — auto-generated class with all translation getters (generated from ARB files)

### Integration Points

- **`app.dart`** — `BlocBuilder<LocaleCubit, LocaleState>` wraps `MaterialApp.router`, providing `locale`, `supportedLocales`, and `localizationsDelegates`
- **`injection.dart`** — `LocaleCubit` registered as singleton with `SecureStorage` dependency
- **Settings page** — Language picker bottom sheet with all 12 languages, current selection indicated with checkmark

## How to Use in Code

### Reading translations

```dart
import '../../../../l10n/app_localizations.dart';

// In a widget's build method:
final l10n = AppLocalizations.of(context)!;
Text(l10n.dashboard)
Text(l10n.deleteAccountConfirm)
```

### Strings with parameters

ARB file:
```json
"successfullyLinkedAccounts": "Successfully linked {count} account(s)",
"@successfullyLinkedAccounts": {
  "placeholders": {
    "count": {"type": "int"}
  }
}
```

Dart usage:
```dart
Text(l10n.successfullyLinkedAccounts(3))
```

## Adding a New Language

1. Create `mobile/lib/l10n/app_XX.arb` (copy `app_en.arb` as template)
2. Set `"@@locale": "XX"` at the top
3. Translate all string values
4. Add language name keys (`"languageName": "Native Name"`) to ALL existing ARB files
5. Add `const Locale('XX'): l10n.languageName` to the language picker in `settings_page.dart`
6. Add case to `_localeLabel()` in `settings_page.dart`
7. Run `flutter gen-l10n` to regenerate

## Adding a New String

1. Add key + value to `app_en.arb` (template file)
2. Add translations to all other `app_XX.arb` files
3. For parametrized strings, add `@key` metadata with `placeholders`
4. Run `flutter gen-l10n`
5. Use `AppLocalizations.of(context)!.newKey` in code

## Regenerating Localizations

```bash
cd mobile
flutter gen-l10n
```

This regenerates `app_localizations.dart` and per-locale files in `lib/l10n/`. These generated files are committed to the repo.

## Current Localization Coverage

| Area | Status |
|------|--------|
| Settings page | Fully localized |
| Auth pages (login, register, onboarding) | ARB keys ready, hardcoded strings in code |
| Dashboard | ARB keys ready, hardcoded strings in code |
| Transactions | ARB keys ready, hardcoded strings in code |
| Accounts | ARB keys ready, hardcoded strings in code |
| Budgets | ARB keys ready, hardcoded strings in code |
| Debts | ARB keys ready, hardcoded strings in code |
| Oracle | ARB keys ready, hardcoded strings in code |
| Notifications | ARB keys ready, hardcoded strings in code |
| Subscription/Paywall | ARB keys ready, hardcoded strings in code |
| Import/Export | ARB keys ready, hardcoded strings in code |
| Receipt scan | ARB keys ready, hardcoded strings in code |
| Offline banner | ARB keys ready, hardcoded strings in code |

> All ~200 translation keys exist in all 12 ARB files. Remaining work is replacing hardcoded `'String'` with `l10n.key` calls in each page widget.
