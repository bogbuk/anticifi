# Task: Admin Panel — управление пользователями
Date: 2026-03-09
Status: in_progress

## Checklist

### Backend — admin infrastructure
- [ ] Добавить `role` поле в User model (USER | ADMIN)
- [ ] Sequelize migration для role column
- [ ] AdminGuard (проверка role === ADMIN)
- [ ] AdminModule + AdminService + AdminController

### Backend — admin endpoints
- [ ] GET /admin/stats — общая статистика
- [ ] GET /admin/users — список с пагинацией и поиском
- [ ] GET /admin/users/:id — детали пользователя
- [ ] PATCH /admin/users/:id — редактирование
- [ ] DELETE /admin/users/:id — soft delete
- [ ] PATCH /admin/users/:id/subscription — управление подпиской

### Frontend — React + Vite + antd
- [ ] Scaffold проекта (admin/)
- [ ] Auth (login page + JWT)
- [ ] Layout (ProLayout + sidebar)
- [ ] Dashboard page (статистика)
- [ ] Users list page (ProTable)
- [ ] User detail page

### Deployment
- [ ] Subdomain admin.anticifi.com
- [ ] Coolify конфигурация

### Verification
- [ ] backend build
- [ ] frontend build
- [ ] commit & push
