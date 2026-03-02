# Task: Доработка Push Notifications — исправление багов и недостающего функционала
Date: 2026-03-02
Status: done

## Checklist

### Mobile — Критические
- [x] Перенести FCM инициализацию после авторизации (не в main.dart)
- [x] Удалять FCM токен при logout (BlocListener на AuthUnauthenticated)
- [x] Добавить flutter_local_notifications для foreground уведомлений
- [x] Создать Android notification channel (anticifi_notifications)

### Mobile — Deep-linking и UX
- [x] Обработать onMessageOpenedApp (тап на push → навигация)
- [x] Обработать getInitialMessage (тап на push при закрытом приложении)
- [x] Обновлять badge count при получении push в foreground

### Mobile — UI
- [x] Добавить иконки для budget_alert и debt_payment_due типов

### Backend
- [x] APNS badge: использовать реальный unread count вместо хардкода 1

### Verification
- [x] build backend — 0 errors
- [x] flutter analyze — No issues found
- [ ] commit & push
