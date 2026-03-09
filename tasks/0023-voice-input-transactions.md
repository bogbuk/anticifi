# Task: Голосовой ввод расходов
Date: 2026-03-05
Status: done

## Описание
Добавить голосовой ввод транзакций в форму создания расхода. Пользователь нажимает микрофон, говорит "кофе 300" — приложение парсит и заполняет description + amount. Лимиты: Free — 3 раза/день, Pro — безлимит.

## Checklist

### Зависимости и разрешения
- [x] Добавить `speech_to_text: ^6.1.1` в `mobile/pubspec.yaml`
- [x] `flutter pub get`
- [x] Добавить `NSSpeechRecognitionUsageDescription` в `mobile/ios/Runner/Info.plist`
- [x] Добавить `NSMicrophoneUsageDescription` в `mobile/ios/Runner/Info.plist`
- [x] Добавить `RECORD_AUDIO` permission в `mobile/android/app/src/main/AndroidManifest.xml`

### Новые файлы
- [x] Создать `mobile/lib/core/utils/voice_input_parser.dart`
- [x] Создать `mobile/lib/core/services/speech_service.dart`

### Регистрация в DI
- [x] Зарегистрировать `SpeechService` в `mobile/lib/core/di/injection.dart`

### Интеграция в форму транзакции
- [x] Изменить `mobile/lib/features/transactions/presentation/pages/transaction_form_page.dart`

### Verification
- [x] `cd mobile && flutter pub get`
- [x] `cd mobile && flutter analyze` — без ошибок
- [ ] build
- [ ] commit & push
