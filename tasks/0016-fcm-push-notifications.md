# Task: Push Notifications через Firebase Cloud Messaging (FCM)
Date: 2026-03-02
Status: done

## Checklist

### Backend
- [x] npm install firebase-admin
- [x] Добавить fcmToken в User модель
- [x] Создать DTO register-fcm-token.dto.ts
- [x] Обновить notifications.controller.ts — эндпоинты FCM-токена
- [x] Обновить notifications.module.ts — инициализация Firebase Admin
- [x] Обновить notifications.service.ts — sendPushNotification()

### Mobile
- [x] Добавить firebase зависимости в pubspec.yaml
- [x] Создать firebase_options.dart (placeholder)
- [x] Создать fcm_service.dart
- [x] Обновить main.dart — инициализация Firebase + FCM
- [x] Добавить API endpoint для FCM-токена
- [x] Обновить datasource, repository (abstract + impl), cubit
- [x] Обновить DI

### Verification
- [x] build backend — 0 errors
- [x] flutter analyze — No issues found
- [ ] commit & push
