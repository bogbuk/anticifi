# Task: Admin Panel — управление пользователями
Date: 2026-03-09
Status: done

## Checklist

### Backend — admin infrastructure
- [x] Добавить `role` поле в User model (USER | ADMIN)
- [x] AdminGuard (проверка role === ADMIN)
- [x] AdminModule + AdminService + AdminController
- [x] JWT Strategy — включить role из БД
- [x] Setup endpoint (POST /admin/setup) для первоначальной настройки

### Backend — admin endpoints
- [x] GET /admin/stats — общая статистика
- [x] GET /admin/users — список с пагинацией и поиском
- [x] GET /admin/users/:id — детали пользователя
- [x] PATCH /admin/users/:id — редактирование
- [x] DELETE /admin/users/:id — soft delete
- [x] PATCH /admin/users/:id/subscription — управление подпиской

### Frontend — React + Vite + antd
- [x] Scaffold проекта (admin/)
- [x] Auth (login page + JWT)
- [x] Layout (sidebar + header)
- [x] Dashboard page (статистика)
- [x] Users list page (таблица с поиском/фильтрами)
- [x] User detail page (инфо + подписка + actions)

### Deployment
- [x] Subdomain admin.anticifi.com
- [x] Coolify app (UUID: x0ccooccss4w48oo48488gko)
- [x] Dockerfile + nginx config
- [x] Admin user promoted (bogbuk@gmail.com)

### Verification
- [x] backend build
- [x] frontend build
- [x] deploy backend + admin
- [x] promote admin via setup endpoint
