# Task: Biometric Authentication + Onboarding
Date: 2026-03-02
Status: done

## Checklist

### Backend
- [x] user.model.ts — поле `onboardingCompleted`
- [x] update-user.dto.ts — валидация `onboardingCompleted`
- [x] auth.service.ts — `onboardingCompleted` в `sanitizeUser()`

### Mobile — новые файлы
- [x] biometric_service.dart
- [x] onboarding_page.dart
- [x] onboarding_step.dart

### Mobile — изменяемые файлы
- [x] pubspec.yaml — `local_auth`
- [x] Info.plist — `NSFaceIDUsageDescription`
- [x] injection.dart — BiometricService + AuthBloc(biometric)
- [x] app_router.dart — redirect + маршрут /onboarding
- [x] user_entity.dart — `onboardingCompleted`
- [x] user_model.dart — fromJson
- [x] auth_event.dart — 3 новых events
- [x] auth_state.dart — AuthLoginSuccessState
- [x] auth_bloc.dart — BiometricService + handlers
- [x] splash_page.dart — biometric check
- [x] login_page.dart — biometric dialog
- [x] register_page.dart — biometric dialog
- [x] settings_page.dart — biometric toggle
- [x] user_profile_entity.dart — field
- [x] user_profile_model.dart — fromJson
- [x] auth_bloc_test.dart — updated for new constructor & states

### Verification
- [x] build backend
- [x] flutter analyze (No issues found!)
