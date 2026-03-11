# Task: Миграция NestJS с Express на Fastify
Date: 2026-03-11
Status: done

## Checklist
- [x] Установить `@nestjs/platform-fastify`, `@fastify/multipart`, `@fastify/static`
- [x] Удалить `@nestjs/platform-express`, `swagger-ui-express`, `@types/express`, `@types/multer`
- [x] Обновить `main.ts` — FastifyAdapter
- [x] Обновить `http-exception.filter.ts` — FastifyReply вместо express Response
- [x] Обновить `export.controller.ts` — FastifyReply вместо express Response
- [x] Обновить `import.controller.ts` — кастомный FastifyFileInterceptor вместо multer
- [x] Обновить `receipt.controller.ts` — кастомный FastifyFileInterceptor вместо multer
- [x] Обновить `receipt.service.ts` — убрать Express.Multer.File тип
- [x] Swagger работает автоматически с Fastify адаптером в NestJS

### Verification
- [x] build
- [ ] commit & push
