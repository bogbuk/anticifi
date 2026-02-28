# Инфраструктура и DevOps — AnticiFi

> Назад к [README](./README.md) | Смотрите также: [Архитектура системы](./architecture.md) · [Техническое задание](./technical-spec.md)

---

## Содержание

1. [Обзор инфраструктуры](#1-обзор-инфраструктуры)
2. [Docker Compose конфигурация](#2-docker-compose-конфигурация)
3. [CI/CD через GitHub Actions](#3-cicd-через-github-actions)
4. [Nginx конфигурация](#4-nginx-конфигурация)
5. [Переменные окружения](#5-переменные-окружения)
6. [Стратегия деплоя](#6-стратегия-деплоя)
7. [Мониторинг и наблюдаемость](#7-мониторинг-и-наблюдаемость)
8. [Резервное копирование](#8-резервное-копирование)
9. [Чеклист деплоя](#9-чеклист-деплоя)

---

## 1. Обзор инфраструктуры

AnticiFi построен на контейнерной архитектуре. Все сервисы упакованы в Docker-образы и оркестрируются через Docker Compose — как в локальном окружении, так и на staging/production серверах на этапе MVP.

Принципы, которым следует инфраструктура:

- **Среды идентичны** — один и тот же `docker-compose.yml` (с минимальными override-файлами) используется на всех уровнях: local, staging, production. Это исключает расхождение окружений и класс ошибок "у меня работает".
- **Конфигурация через переменные окружения** — сервисы не хранят настройки внутри образов. Все секреты и параметры передаются через `.env`-файлы или CI/CD secrets.
- **Иммутабельные образы** — каждый Docker-образ тегируется SHA коммита. Деплой нового кода — это всегда замена образа, а не изменение внутри работающего контейнера.
- **Обратная совместимость миграций** — схема базы данных изменяется только через накатываемые миграции, что позволяет делать rolling-деплой без простоя.

```
┌─────────────────────────────────────────────────────────┐
│                      Интернет                           │
└──────────────────────┬──────────────────────────────────┘
                       │ 80 / 443
              ┌────────▼────────┐
              │      Nginx      │  SSL termination, rate limit
              └────────┬────────┘
                       │ 3000
              ┌────────▼────────┐
              │   API Gateway   │  Auth, routing, WebSocket
              └──┬──────────────┘
                 │ (внутренняя сеть Docker)
    ┌────────────┼────────────────────────────┐
    │            │                            │
┌───▼───┐  ┌────▼─────┐  ┌──────────┐  ┌────▼──────────┐
│ Tx    │  │  Import  │  │Prediction│  │Notification   │
│Service│  │ Service  │  │ Service  │  │Service        │
└───┬───┘  └────┬─────┘  └──────────┘  └───────────────┘
    │            │              │NATS
    └────────────┴──────────────┘
              │            │
         ┌────▼────┐  ┌────▼────┐
         │PostgreSQL│  │  Redis  │
         └──────────┘  └─────────┘
```

---

## 2. Docker Compose конфигурация

### Полная конфигурация

```yaml
version: "3.9"

services:

  # ── Внешние точки входа ────────────────────────────────

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - api-gateway
    restart: unless-stopped

  api-gateway:
    build: ./services/api-gateway
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
      - nats
    env_file: .env
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  # ── Бизнес-сервисы ──────────────────────────────────────

  transaction-service:
    build: ./services/transaction-service
    depends_on:
      - postgres
      - nats
    env_file: .env
    restart: unless-stopped

  import-service:
    build: ./services/import-service
    depends_on:
      - postgres
      - redis
      - nats
    env_file: .env
    restart: unless-stopped
    volumes:
      - uploads_data:/app/uploads

  prediction-service:
    build: ./services/prediction-service
    depends_on:
      - nats
    env_file: .env
    restart: unless-stopped

  notification-service:
    build: ./services/notification-service
    depends_on:
      - redis
      - nats
    env_file: .env
    restart: unless-stopped

  # ── Инфраструктурные сервисы ────────────────────────────

  postgres:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: anticifi
      POSTGRES_USER: anticifi
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U anticifi"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --save 21600 1 --loglevel warning
    restart: unless-stopped

  nats:
    image: nats:2-alpine
    ports:
      - "4222:4222"   # клиентский порт
      - "8222:8222"   # HTTP monitoring UI
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  uploads_data:
```

### Описание сервисов

#### `nginx` — обратный прокси и SSL-терминатор

| Параметр | Значение |
|---|---|
| Образ | `nginx:alpine` |
| Порты | `80` (HTTP → редирект), `443` (HTTPS) |
| Зависимости | `api-gateway` |

Nginx — единственная точка входа для внешнего трафика. Он отвечает за:

- Терминацию TLS (расшифровка HTTPS на стороне сервера, дальнейшая передача трафика внутри Docker-сети по HTTP).
- Редирект HTTP → HTTPS.
- Rate limiting для защиты от DDoS и брутфорса.
- Проксирование обычных HTTP-запросов к `api-gateway:3000`.
- Апгрейд соединений до WebSocket для `/socket.io/`.
- Добавление security-заголовков (`X-Frame-Options`, `HSTS` и т.д.).

Конфигурационный файл монтируется read-only (`./nginx/nginx.conf`), SSL-сертификаты — из `./nginx/ssl/`. Такая схема позволяет обновлять сертификаты (certbot) без пересборки образа.

#### `api-gateway` — центральный шлюз API

| Параметр | Значение |
|---|---|
| Сборка | `./services/api-gateway` |
| Порт | `3000` |
| Зависимости | `postgres`, `redis`, `nats` |

API Gateway — это NestJS-приложение, которое выполняет роль единого входного узла для мобильного клиента. Его обязанности:

- Аутентификация и авторизация (JWT Access/Refresh tokens).
- Валидация входящих запросов.
- Маршрутизация запросов к внутренним сервисам через NATS.
- Обработка WebSocket-соединений (Socket.IO) для real-time уведомлений.
- Агрегация ответов от нескольких сервисов в единый HTTP-ответ.

Порт `3000` пробрасывается наружу для удобства локальной разработки (прямой доступ без Nginx). В production доступ к порту `3000` должен быть закрыт файрволом — весь трафик идёт только через Nginx.

Healthcheck (`/health`) позволяет Docker и оркестратору определять готовность сервиса перед направлением трафика.

#### `transaction-service` — сервис транзакций

| Параметр | Значение |
|---|---|
| Сборка | `./services/transaction-service` |
| Зависимости | `postgres`, `nats` |

Отвечает за всю бизнес-логику, связанную с финансовыми транзакциями:

- CRUD операции над транзакциями пользователей.
- Категоризация транзакций (алгоритмическая + на основе пользовательских правил).
- Расчёт агрегатов: суммы по периодам, по категориям, балансы.
- Публикация событий в NATS при создании/изменении транзакций (что тригерит перерасчёт прогноза в `prediction-service`).

Сервис не имеет открытых внешних портов — взаимодействие происходит исключительно через NATS и/или прямой вызов от `api-gateway`.

#### `import-service` — сервис импорта данных

| Параметр | Значение |
|---|---|
| Сборка | `./services/import-service` |
| Зависимости | `postgres`, `redis`, `nats` |
| Том | `uploads_data:/app/uploads` |

Обрабатывает загрузку и парсинг внешних финансовых данных:

- Парсинг CSV-выписок из разных банков (гибкий маппинг колонок).
- Дедупликация транзакций (через Redis для временного хранения хэшей).
- OCR чеков (интеграция с ML Kit / Google Vision API).
- Постановка задач в очередь (Bull через Redis) для асинхронной обработки больших файлов.
- Хранение загруженных файлов во временном томе `uploads_data`.

Redis используется двояко: как брокер очереди Bull (управление задачами парсинга) и как кэш для дедупликации (хранение хэшей уже обработанных транзакций).

#### `prediction-service` — AI-сервис предсказаний

| Параметр | Значение |
|---|---|
| Сборка | `./services/prediction-service` |
| Зависимости | `nats` |

Python/FastAPI микросервис — ядро предиктивного движка AnticiFi ("Oracle"):

- Получает события из NATS (новые транзакции, обновлённые данные пользователя).
- Запускает ML-модели для прогнозирования баланса на заданную дату.
- Детектирует регулярные платежи (паттерн-матчинг по историческим данным).
- Отвечает на прямые HTTP-запросы от `api-gateway` (`PREDICTION_SERVICE_URL`).
- Может работать автономно от основного PostgreSQL, получая данные через NATS-события или через HTTP-запрос к `transaction-service`.

Сервис не имеет прямого соединения с PostgreSQL — это намеренное архитектурное решение, реализующее принцип разделения ответственности. Prediction-сервис работает с агрегированными данными, а не с сырыми таблицами БД. Подробнее о причинах — в [Архитектуре системы](./architecture.md).

#### `notification-service` — сервис уведомлений

| Параметр | Значение |
|---|---|
| Сборка | `./services/notification-service` |
| Зависимости | `redis`, `nats` |

Отвечает за доставку уведомлений пользователям:

- Подписывается на NATS-события (например, `prediction.alert.low_balance`).
- Отправляет push-уведомления через Firebase Cloud Messaging (FCM).
- Отправляет email через SMTP (SendGrid).
- Управляет расписанием повторных попыток доставки через Redis (Bull queue).
- Хранит в Redis состояние "уведомление уже отправлено" для предотвращения дублей.

#### `postgres` — основная база данных

| Параметр | Значение |
|---|---|
| Образ | `postgres:16-alpine` |
| Порт | `5432` |
| Том | `postgres_data:/var/lib/postgresql/data` |

PostgreSQL 16 на Alpine Linux — минимальный образ без лишних пакетов. Основное хранилище всех структурированных данных:

- Пользователи, счета, транзакции, категории.
- Регулярные платежи.
- Результаты прогнозов (кэш).
- Настройки пользователей.

Порт `5432` пробрасывается для удобства локального подключения (pgAdmin, DBeaver). В production этот порт должен быть закрыт файрволом или не пробрасываться вовсе — доступ только из внутренней Docker-сети.

Полная схема БД описана в [Схеме базы данных](./database-schema.md).

#### `redis` — кэш и брокер очередей

| Параметр | Значение |
|---|---|
| Образ | `redis:7-alpine` |
| Порт | `6379` |
| Том | `redis_data:/data` |

Redis используется в нескольких ролях одновременно:

- **Кэш сессий**: хранение JWT refresh-токенов с TTL.
- **Брокер очередей**: Bull queue для `import-service` (задачи парсинга).
- **Кэш дедупликации**: хэши уже обработанных транзакций в `import-service`.
- **Rate limit счётчики**: вспомогательное хранилище для Nginx rate limiting.
- **Pub/Sub**: вспомогательный канал для некоторых real-time событий.

Команда `redis-server --save 21600 1` настраивает RDB-снапшот: сохранять на диск если за 6 часов изменилась хотя бы 1 запись. Том `redis_data` гарантирует, что данные переживают перезапуск контейнера.

#### `nats` — шина сообщений

| Параметр | Значение |
|---|---|
| Образ | `nats:2-alpine` |
| Порт | `4222` (клиентский), `8222` (HTTP UI) |

NATS — легковесный высокопроизводительный message broker. Используется как асинхронная шина для inter-service communication:

- Публикация событий при создании/изменении транзакций.
- Тригеринг перерасчёта прогнозов.
- Отправка событий для уведомлений.
- Request-Reply паттерн для синхронных запросов между сервисами.

Порт `8222` — HTTP monitoring endpoint NATS. В development на него можно зайти браузером и увидеть статистику подключений, топиков и сообщений. В production этот порт должен быть закрыт файрволом.

### Override-файлы для сред

```yaml
# docker-compose.override.yml (локальная разработка — игнорируется git)
services:
  api-gateway:
    command: npm run start:dev   # hot reload через nodemon
    volumes:
      - ./services/api-gateway/src:/app/src
  transaction-service:
    command: npm run start:dev
    volumes:
      - ./services/transaction-service/src:/app/src
```

```yaml
# docker-compose.prod.yml (production)
services:
  api-gateway:
    image: ghcr.io/anticifi/api-gateway:${VERSION}
    deploy:
      resources:
        limits:
          memory: 512M
  postgres:
    ports: []           # закрываем порт наружу
  redis:
    ports: []
  nats:
    ports:
      - "4222:4222"     # оставляем только клиентский, закрываем monitoring
```

---

## 3. CI/CD через GitHub Actions

Все пайплайны хранятся в директории `.github/workflows/`. Стратегия CI/CD следует принципу "build once, deploy many": Docker-образ собирается один раз и продвигается между средами по тегам, а не пересобирается.

### Общая схема пайплайнов

```
push (any branch)     →  ci.yml           Lint + TypeCheck + Tests + Build
push (develop)        →  deploy-staging   CI → Build images → Push → Deploy staging
push (Flutter файлы)  →  mobile-ci.yml    Analyze + Test + Build APK/IPA
release tag (v*)      →  deploy-prod.yml  CI → Build + Tag → Deploy prod → Smoke tests
```

### Workflow: `ci.yml` — базовые проверки

Запускается на каждый push в любую ветку и на все Pull Requests. Это обязательный статус-чек для мержа.

```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["**"]

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Check Prettier formatting
        run: npm run format:check

  typecheck:
    name: TypeScript Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci
      - name: Run TypeScript compiler (no emit)
        run: npm run typecheck

  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: anticifi_test
          POSTGRES_USER: anticifi
          POSTGRES_PASSWORD: test_password
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci
      - name: Run Jest
        run: npm run test:cov
        env:
          NODE_ENV: test
          DB_HOST: localhost
          DB_PORT: 5432
          DB_NAME: anticifi_test
          DB_USER: anticifi
          DB_PASSWORD: test_password
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/

  build-check:
    name: Build Check
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci
      - name: Build all services
        run: npm run build
```

**Что и зачем проверяется:**

- **ESLint** — статический анализ кода. Ловит потенциальные ошибки, неиспользуемые переменные, нарушения style guide до code review.
- **Prettier** — единый форматирование кода. Исключает "whitespace wars" в PR.
- **TypeScript** (`tsc --noEmit`) — компиляция без генерации файлов. Ловит ошибки типов, которые ESLint может пропустить.
- **Jest** — модульные тесты. Запускаются с реальной тестовой БД (PostgreSQL в Docker service).
- **Build check** — финальная проверка, что `npm run build` проходит без ошибок. Запускается только после прохождения всех предыдущих шагов (`needs`).

### Workflow: `deploy-staging.yml` — деплой на staging

Запускается автоматически при push в ветку `develop`.

```yaml
name: Deploy to Staging

on:
  push:
    branches: [develop]

jobs:
  ci:
    uses: ./.github/workflows/ci.yml   # переиспользуем CI job

  build-and-push:
    name: Build & Push Images
    needs: ci
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      image-tag: ${{ steps.meta.outputs.version }}
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/anticifi/anticifi
          tags: |
            type=sha,prefix=staging-,format=short

      - name: Build and push API Gateway
        uses: docker/build-push-action@v5
        with:
          context: ./services/api-gateway
          push: true
          tags: ghcr.io/anticifi/api-gateway:${{ steps.meta.outputs.version }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      # Аналогично для остальных сервисов:
      # transaction-service, import-service, prediction-service, notification-service

  deploy:
    name: Deploy to Staging Server
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /opt/anticifi
            export VERSION=${{ needs.build-and-push.outputs.image-tag }}
            docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
            docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-deps
            docker image prune -f
```

**Ключевые решения:**

- **GitHub Container Registry (GHCR)** — бесплатный реестр образов, интегрированный с GitHub. Аутентификация через `GITHUB_TOKEN` — не нужны отдельные credentials.
- **Docker layer caching** (`cache-from: type=gha`) — кэширует слои образа между запусками. Значительно ускоряет повторные сборки (только изменённые слои пересобираются).
- **SSH deployment** — минималистичный подход: подключаемся к серверу, тянем новые образы и перезапускаем. Для MVP это надёжнее и проще Kubernetes.
- **Environment protection** в GitHub — staging environment может требовать ручного одобрения деплоя или иметь свои secrets, изолированные от production.

### Workflow: `deploy-production.yml` — деплой на production

Запускается при создании release-тега вида `v1.2.3`.

```yaml
name: Deploy to Production

on:
  push:
    tags:
      - "v[0-9]+.[0-9]+.[0-9]+"

jobs:
  ci:
    uses: ./.github/workflows/ci.yml

  build-and-push:
    name: Build & Push Versioned Images
    needs: ci
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract version from tag
        id: version
        run: echo "VERSION=${GITHUB_REF_NAME}" >> $GITHUB_OUTPUT

      - name: Build and push with version tag
        uses: docker/build-push-action@v5
        with:
          context: ./services/api-gateway
          push: true
          tags: |
            ghcr.io/anticifi/api-gateway:${{ steps.version.outputs.VERSION }}
            ghcr.io/anticifi/api-gateway:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    name: Rolling Deploy to Production
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: production   # требует ручного одобрения в GitHub
    steps:
      - name: Run DB migrations
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PROD_HOST }}
          username: ${{ secrets.PROD_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            cd /opt/anticifi
            export VERSION=${{ github.ref_name }}
            docker compose run --rm api-gateway npx sequelize-cli db:migrate

      - name: Rolling restart
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PROD_HOST }}
          username: ${{ secrets.PROD_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            cd /opt/anticifi
            export VERSION=${{ github.ref_name }}
            # Обновляем по одному сервису, чтобы не было даунтайма
            for service in transaction-service import-service prediction-service notification-service; do
              docker compose -f docker-compose.yml -f docker-compose.prod.yml pull $service
              docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-deps $service
              sleep 10   # даём сервису время стартовать
            done
            # API Gateway обновляем последним
            docker compose pull api-gateway
            docker compose up -d --no-deps api-gateway

  smoke-tests:
    name: Smoke Tests
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run smoke tests
        run: |
          # Проверяем основные endpoint'ы
          curl -f https://api.anticifi.app/health || exit 1
          curl -f https://api.anticifi.app/api/v1/ping || exit 1
        env:
          PROD_URL: https://api.anticifi.app

  notify:
    name: Notify Team
    needs: [deploy, smoke-tests]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Send Slack notification
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "${{ needs.deploy.result == 'success' && '✅' || '❌' }} Production deploy *${{ github.ref_name }}*: ${{ needs.deploy.result }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*AnticiFi Deploy* — `${{ github.ref_name }}`\nStatus: ${{ needs.deploy.result }}\nSmoke tests: ${{ needs.smoke-tests.result }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

**Ключевые решения production-деплоя:**

- **Семантическое версионирование** — тег `v1.2.3` становится тегом Docker-образа. Всегда можно понять, какая версия кода запущена в production, и выполнить rollback командой `docker compose up -d` с предыдущим тегом.
- **Ручное одобрение** (`environment: production` в GitHub) — деплой в production требует нажатия кнопки "Approve" уполномоченным членом команды. Предотвращает случайные деплои.
- **Миграции перед рестартом** — сначала применяется новая схема БД, затем запускается новый код. Новая схема должна быть обратно совместима со старым кодом (принцип expand-contract).
- **Rolling restart** — сервисы перезапускаются по одному с паузой 10 секунд. При использовании Docker Compose без оркестратора это простейший способ достичь zero-downtime при наличии нескольких реплик или при поэтапной замене.
- **Smoke tests** — минимальные проверки работоспособности после деплоя. Если smoke tests падают, команда немедленно получает уведомление.

### Workflow: `mobile-ci.yml` — CI для Flutter

Запускается при изменениях в директории `apps/mobile/`.

```yaml
name: Mobile CI

on:
  push:
    paths:
      - "apps/mobile/**"
  pull_request:
    paths:
      - "apps/mobile/**"

jobs:
  analyze-and-test:
    name: Analyze & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.x"
          channel: "stable"
          cache: true

      - name: Install dependencies
        run: flutter pub get
        working-directory: apps/mobile

      - name: Run Flutter analyzer
        run: flutter analyze
        working-directory: apps/mobile

      - name: Run Flutter tests
        run: flutter test --coverage
        working-directory: apps/mobile

  build-android:
    name: Build APK (Staging)
    needs: analyze-and-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.x"
          channel: "stable"
          cache: true
      - run: flutter pub get
        working-directory: apps/mobile
      - name: Build APK
        run: flutter build apk --flavor staging --dart-define=ENV=staging
        working-directory: apps/mobile
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: staging-apk
          path: apps/mobile/build/app/outputs/flutter-apk/app-staging-release.apk

  build-ios:
    name: Build IPA (Staging)
    needs: analyze-and-test
    runs-on: macos-latest   # требует macOS runner
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.x"
          channel: "stable"
          cache: true
      - run: flutter pub get
        working-directory: apps/mobile
      - name: Build IPA (no codesign for CI)
        run: flutter build ipa --no-codesign --dart-define=ENV=staging
        working-directory: apps/mobile
      - name: Upload IPA artifact
        uses: actions/upload-artifact@v4
        with:
          name: staging-ipa
          path: apps/mobile/build/ios/archive/
```

**Почему macOS runner для iOS:**

iOS-сборка требует Xcode, который работает только на macOS. GitHub Actions предоставляет `macos-latest` runner — он дороже (тарифицируется в 10x от Linux), поэтому iOS-сборка запускается только после успешного прохождения analyze и tests. Флаг `--no-codesign` позволяет собрать IPA без сертификатов Apple — для проверки компилируемости. Для деплоя в TestFlight потребуется настройка Fastlane с сертификатами.

---

## 4. Nginx конфигурация

### Полная конфигурация

```nginx
# /nginx/nginx.conf

# Количество worker-процессов = числу CPU cores
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    # ── Upstream definition ─────────────────────────────
    upstream api {
        server api-gateway:3000;
        # keepalive для переиспользования соединений
        keepalive 64;
    }

    # ── Rate limiting ───────────────────────────────────
    # Выделяем 10mb памяти для хранения счётчиков по IP
    # Лимит: 100 запросов/секунду с IP
    limit_req_zone $binary_remote_addr zone=api:10m rate=100r/s;

    # Более строгий лимит для auth endpoints
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;

    # ── Logging ─────────────────────────────────────────
    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent" '
                    'rt=$request_time';

    access_log /var/log/nginx/access.log main;
    error_log  /var/log/nginx/error.log warn;

    # ── HTTP → HTTPS redirect ───────────────────────────
    server {
        listen 80;
        server_name api.anticifi.app;

        # Исключение для Let's Encrypt ACME challenge
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 301 https://$server_name$request_uri;
        }
    }

    # ── HTTPS server ────────────────────────────────────
    server {
        listen 443 ssl http2;
        server_name api.anticifi.app;

        # ── SSL / TLS ───────────────────────────────────
        ssl_certificate     /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        # Поддерживаем только TLS 1.2 и 1.3
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;

        # OCSP stapling — ускоряет TLS handshake
        ssl_stapling on;
        ssl_stapling_verify on;

        # Session resumption — снижает нагрузку на повторных соединениях
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1d;
        ssl_session_tickets off;

        # ── Security Headers ────────────────────────────
        # Запрет отображения сайта в iframe (защита от clickjacking)
        add_header X-Frame-Options "SAMEORIGIN" always;

        # Запрет MIME-sniffing браузером
        add_header X-Content-Type-Options "nosniff" always;

        # Встроенная защита браузера от XSS
        add_header X-XSS-Protection "1; mode=block" always;

        # Принудительный HTTPS на 1 год, включая поддомены
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Контроль referrer для приватности
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;

        # Content Security Policy
        add_header Content-Security-Policy "default-src 'self'; script-src 'self'; object-src 'none';" always;

        # ── CORS ────────────────────────────────────────
        # Мобильное приложение делает запросы с нативного клиента,
        # CORS для мобильного Flutter не требуется.
        # Но если появится web-клиент — настроить здесь.

        # ── Буферизация и таймауты ──────────────────────
        client_max_body_size 10m;       # максимальный размер загружаемого файла
        client_body_timeout 60s;
        client_header_timeout 60s;
        send_timeout 60s;
        proxy_read_timeout 120s;        # для долгих AI-запросов

        # ── API routes ──────────────────────────────────
        location /api/ {
            limit_req zone=api burst=20 nodelay;

            proxy_pass http://api;
            proxy_http_version 1.1;
            proxy_set_header Connection "";             # keepalive к upstream
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Буферизация ответов
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
        }

        # ── Auth routes (строгий rate limit) ────────────
        location /api/v1/auth/ {
            limit_req zone=auth burst=3 nodelay;

            proxy_pass http://api;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # ── WebSocket (Socket.IO) ────────────────────────
        location /socket.io/ {
            proxy_pass http://api;
            proxy_http_version 1.1;

            # Апгрейд HTTP до WebSocket
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # Длинный таймаут для постоянных соединений
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
        }

        # ── Health check (без rate limit) ───────────────
        location /health {
            proxy_pass http://api;
            access_log off;    # не засорять логи healthcheck-запросами
        }
    }
}
```

### Объяснение ключевых решений

**Dual zone rate limiting**

Используются два независимых rate limit zone:
- `api` — 100 запросов/сек на IP, burst 20. Защита от DDoS и злоупотреблений API.
- `auth` — 5 запросов/минуту на IP. Жёсткая защита endpoint'ов `/auth/login` и `/auth/register` от брутфорса паролей.

`burst=20 nodelay` для API: если пользователь отправляет 120 запросов за секунду, первые 20 сверх лимита пропускаются немедленно (burst), остальные получают 429. `nodelay` означает — не ставить в очередь, а сразу отдавать 429.

**WebSocket апгрейд**

Socket.IO сначала устанавливает соединение как обычный HTTP (long-polling), затем апгрейдится до WebSocket. Для этого Nginx должен:
1. Передать заголовок `Upgrade: websocket`.
2. Изменить `Connection` на `upgrade` (а не `keep-alive`, как для обычных запросов).
3. Использовать `proxy_http_version 1.1` — WebSocket не поддерживается в HTTP/1.0.

Таймаут `3600s` (1 час) для WebSocket — клиент может быть подключён долго, Nginx не должен разрывать соединение из-за "неактивности".

**OCSP Stapling**

Без OCSP stapling браузер при каждом новом TLS-соединении делает отдельный запрос к CA (Let's Encrypt) для проверки, не отозван ли сертификат. С OCSP stapling Nginx сам заранее получает OCSP-ответ от CA и "прикрепляет" его к TLS handshake. Это ускоряет установку соединения и улучшает privacy (браузер не "светит" посещаемые сайты перед CA).

**`client_max_body_size 10m`**

Ограничение размера тела запроса — 10 мегабайт. Соответствует переменной `MAX_FILE_SIZE=10mb` для upload'а банковских выписок. Nginx отклонит слишком большие файлы ещё до того, как они дойдут до приложения — экономит ресурсы.

**ACME challenge исключение**

Let's Encrypt при выдаче/обновлении сертификата делает HTTP (не HTTPS) запрос к `/.well-known/acme-challenge/`. Если редиректить всё на HTTPS — certbot не сможет пройти проверку. Поэтому этот путь явно исключён из redirect-правила.

---

## 5. Переменные окружения

Все сервисы конфигурируются через единый `.env` файл в корне проекта. Файл `.env.example` коммитится в репозиторий (без реальных значений секретов), `.env` добавлен в `.gitignore`.

### Полный `.env.example`

```env
# ═══════════════════════════════════════════════════════════
# AnticiFi — Environment Variables
# Скопировать в .env и заполнить реальными значениями.
# Никогда не коммитить .env в репозиторий.
# ═══════════════════════════════════════════════════════════

# ── Приложение ───────────────────────────────────────────
NODE_ENV=development
PORT=3000
API_URL=http://localhost:3000
LOG_LEVEL=debug

# ── База данных (PostgreSQL) ─────────────────────────────
DB_HOST=postgres
DB_PORT=5432
DB_NAME=anticifi
DB_USER=anticifi
DB_PASSWORD=change_me_in_production

# Пул соединений
DB_POOL_MIN=2
DB_POOL_MAX=10

# ── Redis ────────────────────────────────────────────────
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# ── NATS ────────────────────────────────────────────────
NATS_URL=nats://nats:4222

# ── JWT ─────────────────────────────────────────────────
JWT_ACCESS_SECRET=generate-a-strong-random-secret-here
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_SECRET=generate-another-strong-random-secret
JWT_REFRESH_EXPIRATION=7d

# ── Email (SMTP / SendGrid) ──────────────────────────────
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=SG.your-sendgrid-api-key
SMTP_FROM=noreply@anticifi.app

# ── Firebase (Push notifications) ───────────────────────
FIREBASE_PROJECT_ID=anticifi
FIREBASE_SERVICE_ACCOUNT=/run/secrets/firebase-service-account.json

# ── AI/ML (Prediction service) ──────────────────────────
PREDICTION_SERVICE_URL=http://prediction-service:8000
PREDICTION_TIMEOUT_MS=30000

# ── File Upload ──────────────────────────────────────────
MAX_FILE_SIZE=10mb
UPLOAD_DIR=./uploads

# ── Опционально: мониторинг ──────────────────────────────
SENTRY_DSN=
SLACK_WEBHOOK_URL=
```

### Справочник переменных

#### Приложение

| Переменная | Описание | Значения по умолчанию |
|---|---|---|
| `NODE_ENV` | Среда выполнения. Влияет на уровень логирования, оптимизации NestJS, поведение ORM. | `development` / `test` / `production` |
| `PORT` | TCP-порт, на котором API Gateway принимает HTTP-соединения. | `3000` |
| `API_URL` | Публичный URL API. Используется для генерации ссылок в письмах (email verification, password reset). | `http://localhost:3000` в dev |
| `LOG_LEVEL` | Уровень детализации логов. В production рекомендуется `warn` или `error`. | `debug` в dev, `warn` в prod |

#### База данных

| Переменная | Описание | Значение по умолчанию |
|---|---|---|
| `DB_HOST` | Hostname PostgreSQL. В Docker Compose — имя сервиса `postgres`. | `postgres` |
| `DB_PORT` | Порт PostgreSQL. | `5432` |
| `DB_NAME` | Имя базы данных. | `anticifi` |
| `DB_USER` | Пользователь PostgreSQL. | `anticifi` |
| `DB_PASSWORD` | Пароль PostgreSQL. **Обязательно заменить в production.** Рекомендуется минимум 32 символа, случайно сгенерированный. | — |
| `DB_POOL_MIN` | Минимальное количество соединений в пуле Sequelize. | `2` |
| `DB_POOL_MAX` | Максимальное количество соединений в пуле. Не превышать `max_connections` PostgreSQL (по умолчанию 100). | `10` |

#### Redis

| Переменная | Описание | Значение по умолчанию |
|---|---|---|
| `REDIS_HOST` | Hostname Redis. | `redis` |
| `REDIS_PORT` | Порт Redis. | `6379` |
| `REDIS_PASSWORD` | Пароль Redis. В локальной разработке можно оставить пустым. В production — обязательно установить. | пусто |
| `REDIS_DB` | Номер Redis database (0–15). Можно использовать разные DB для разных целей (0 — кэш, 1 — очереди). | `0` |

#### NATS

| Переменная | Описание | Значение по умолчанию |
|---|---|---|
| `NATS_URL` | URL подключения к NATS-серверу. Поддерживает несколько URL через запятую для кластера (`nats://host1:4222,nats://host2:4222`). | `nats://nats:4222` |

#### JWT

| Переменная | Описание | Рекомендации |
|---|---|---|
| `JWT_ACCESS_SECRET` | Секрет для подписи access-токенов. | Минимум 64 символа, случайный. `openssl rand -hex 64` |
| `JWT_ACCESS_EXPIRATION` | Срок жизни access-токена. Короткий срок — меньше окно атаки при компрометации. | `15m` |
| `JWT_REFRESH_SECRET` | Секрет для refresh-токенов. **Должен отличаться** от access secret. | Минимум 64 символа, другой секрет. |
| `JWT_REFRESH_EXPIRATION` | Срок жизни refresh-токена. Пользователь остаётся залогинен без повторного ввода пароля. | `7d` |

Access и refresh токены используют **разные секреты** намеренно: компрометация одного секрета не позволяет подделать токены другого типа. Access-токены не хранятся на сервере (stateless), refresh-токены хранятся в Redis с возможностью инвалидации.

#### Email

| Переменная | Описание | Значение по умолчанию |
|---|---|---|
| `SMTP_HOST` | SMTP-сервер для отправки писем. | `smtp.sendgrid.net` |
| `SMTP_PORT` | Порт SMTP. `587` — STARTTLS (рекомендуется). `465` — SSL/TLS. `25` — без шифрования (не использовать). | `587` |
| `SMTP_USER` | Имя пользователя SMTP. Для SendGrid — буквально строка `apikey`. | `apikey` |
| `SMTP_PASSWORD` | Пароль SMTP / API ключ SendGrid. | — |
| `SMTP_FROM` | Email-адрес отправителя. Должен быть верифицирован в SendGrid. | `noreply@anticifi.app` |

#### Firebase

| Переменная | Описание | Примечание |
|---|---|---|
| `FIREBASE_PROJECT_ID` | ID проекта в Firebase Console. | `anticifi` |
| `FIREBASE_SERVICE_ACCOUNT` | Путь к JSON-файлу service account credentials. В production лучше передавать через Docker secrets, не через файл. | Путь к файлу или JSON-строка |

В production рекомендуется передавать Firebase credentials через Docker secrets:

```yaml
secrets:
  firebase_service_account:
    file: ./secrets/firebase-service-account.json

services:
  notification-service:
    secrets:
      - firebase_service_account
    environment:
      FIREBASE_SERVICE_ACCOUNT: /run/secrets/firebase_service_account
```

#### AI/ML

| Переменная | Описание | Значение по умолчанию |
|---|---|---|
| `PREDICTION_SERVICE_URL` | URL Python/FastAPI сервиса предсказаний. Внутри Docker — имя сервиса. | `http://prediction-service:8000` |
| `PREDICTION_TIMEOUT_MS` | Таймаут ожидания ответа от prediction-service (в миллисекундах). ML-модели могут работать дольше обычных HTTP-запросов. | `30000` (30 сек) |

#### Загрузка файлов

| Переменная | Описание | Значение по умолчанию |
|---|---|---|
| `MAX_FILE_SIZE` | Максимальный размер загружаемого файла. Должен совпадать с `client_max_body_size` в Nginx. | `10mb` |
| `UPLOAD_DIR` | Директория для временного хранения загруженных файлов. В production должна быть смонтирована как том. | `./uploads` |

### Управление секретами по средам

| Среда | Способ хранения секретов |
|---|---|
| Local | `.env` файл (в `.gitignore`) |
| Staging | GitHub Actions secrets → передаются через SSH на сервер → `/opt/anticifi/.env` |
| Production | GitHub Actions secrets + Docker secrets для критичных credentials |
| Будущее | HashiCorp Vault или AWS Secrets Manager |

Генерация надёжных секретов:

```bash
# JWT secrets
openssl rand -hex 64

# DB password
openssl rand -base64 32

# Или через Python
python3 -c "import secrets; print(secrets.token_hex(64))"
```

---

## 6. Стратегия деплоя

### Матрица сред

| Параметр | Local Dev | Staging | Production (MVP) | Production (Scale) |
|---|---|---|---|---|
| Оркестрация | Docker Compose | Docker Compose | Docker Compose | Kubernetes (managed) |
| Сервер | Машина разработчика | 1 VPS (4 CPU / 8GB RAM) | 1 VPS (8 CPU / 16GB RAM) | Managed cluster (EKS/GKE) |
| БД | PostgreSQL в Docker | PostgreSQL в Docker | Managed PostgreSQL (RDS/Supabase) | Managed PostgreSQL |
| Redis | Redis в Docker | Redis в Docker | Managed Redis (Upstash/ElastiCache) | Managed Redis |
| SSL | — | Let's Encrypt | Let's Encrypt | Cloud load balancer |
| Деплой | Вручную | Auto (GitHub Actions) | Auto (GitHub Actions) | Helm charts |
| Мониторинг | Локально | Базовый (Uptime Robot) | Prometheus + Grafana | Full observability |

### Development (локальная среда)

Цель: быстрый цикл разработки с hot reload.

```bash
# Поднять только инфраструктуру (БД, Redis, NATS)
docker compose up -d postgres redis nats

# Запустить нужные сервисы с hot reload
cd services/api-gateway
npm run start:dev

# Или поднять всё через Docker Compose с override
docker compose -f docker-compose.yml -f docker-compose.override.yml up
```

Override-файл монтирует исходный код внутрь контейнера и запускает nodemon/ts-node-dev — изменения в `.ts` файлах применяются без пересборки образа.

### Staging

Цель: максимально близкая к production среда для QA и интеграционного тестирования.

Staging разворачивается на одном VPS (Hetzner Cloud CX31 или DigitalOcean Droplet с 4 CPU / 8GB RAM — ~$24/месяц). Деплой происходит автоматически при каждом push в ветку `develop`.

Начальная настройка сервера:

```bash
# На сервере
apt update && apt upgrade -y
apt install -y docker.io docker-compose-plugin nginx certbot

# Создать пользователя для деплоя (без sudo для Docker)
useradd -m -s /bin/bash deploy
usermod -aG docker deploy

# Настроить SSH ключ
mkdir -p /home/deploy/.ssh
echo "PUBLIC_KEY_CONTENT" >> /home/deploy/.ssh/authorized_keys

# Создать директорию проекта
mkdir -p /opt/anticifi
chown deploy:deploy /opt/anticifi

# Получить SSL-сертификат
certbot certonly --standalone -d api.anticifi.app
```

### Production — Option A: Single VPS (MVP)

Рекомендуется для фазы MVP до ~10 000 активных пользователей.

Конфигурация сервера: Hetzner CCX33 (8 vCPU, 32 GB RAM, 240 GB NVMe) — ~$95/месяц. Или DigitalOcean General Purpose 8 vCPU 16 GB — ~$96/месяц.

Преимущества подхода:
- Простота операционного обслуживания.
- Нет overhead Kubernetes.
- Предсказуемая стоимость.
- Быстрая итерация.

Ограничения:
- Нет горизонтального масштабирования.
- Single point of failure (можно частично решить через бэкапы и мониторинг).
- Ручной failover при сбое сервера.

Структура файлов на сервере:

```
/opt/anticifi/
├── docker-compose.yml          # основной compose
├── docker-compose.prod.yml     # prod override
├── .env                        # секреты (chmod 600)
├── nginx/
│   ├── nginx.conf
│   └── ssl/
│       ├── fullchain.pem
│       └── privkey.pem
└── backups/                    # локальные бэкапы (+ синхронизация в S3)
```

### Production — Option B: Kubernetes (масштабирование)

Переход на Kubernetes рекомендуется при:
- Более 50 000 активных пользователей.
- Необходимости автоматического горизонтального масштабирования.
- Требовании SLA > 99.9%.
- Росте команды DevOps.

Рекомендуемый провайдер: **Google Kubernetes Engine (GKE Autopilot)** — автоматическое управление нодами, pay-per-pod, минимальный операционный overhead.

При переходе на K8s Docker Compose конфигурация конвертируется в Helm charts:

```
helm/
├── Chart.yaml
├── values.yaml
├── values-staging.yaml
├── values-production.yaml
└── templates/
    ├── api-gateway/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── hpa.yaml           # Horizontal Pod Autoscaler
    ├── transaction-service/
    ├── prediction-service/
    └── ...
```

### Автоматическое обновление SSL-сертификатов

Let's Encrypt сертификаты действительны 90 дней. Certbot автоматически обновляет их через cron:

```bash
# /etc/cron.d/certbot
0 0,12 * * * root certbot renew --quiet --deploy-hook "docker compose -f /opt/anticifi/docker-compose.yml exec nginx nginx -s reload"
```

Хук `--deploy-hook` перезагружает Nginx после успешного обновления сертификата — без полного перезапуска, без прерывания текущих соединений.

---

## 7. Мониторинг и наблюдаемость

На этапе MVP реализуется базовый мониторинг. Полноценный стек observability планируется после выхода на 1000+ активных пользователей.

### Уровни наблюдаемости

```
Уровень 1 (MVP):     Uptime Robot + Sentry
Уровень 2 (Growth):  Prometheus + Grafana + Loki
Уровень 3 (Scale):   Full observability stack (Grafana Cloud / Datadog)
```

### Уровень 1: Базовый мониторинг (MVP)

**Uptime Robot** — мониторинг доступности:
- Проверяет `https://api.anticifi.app/health` каждые 5 минут.
- При недоступности отправляет уведомление в Slack/Email.
- Публичная страница статуса: `status.anticifi.app`.

**Sentry** — трекинг ошибок:
- Интегрируется в NestJS через `@sentry/node`.
- Автоматически перехватывает необработанные исключения.
- Группирует похожие ошибки, показывает stack trace с контекстом.
- Уведомления о новых типах ошибок в Slack.

```typescript
// Подключение Sentry в NestJS
import * as Sentry from "@sentry/node";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,  // 10% запросов — для performance monitoring
});
```

### Уровень 2: Prometheus + Grafana

**Prometheus** собирает метрики со всех сервисов. NestJS экспортирует метрики через `/metrics` endpoint:

```typescript
// Стандартные метрики Node.js + кастомные бизнес-метрики
import { PrometheusModule } from "@willsoto/nestjs-prometheus";

// Пример кастомной метрики
@InjectMetric("predictions_total")
private readonly predictionsTotal: Counter<string>,
```

Ключевые метрики для дашборда:

| Категория | Метрика | Алерт |
|---|---|---|
| Availability | `up` (1/0 per service) | < 1 → PagerDuty |
| Latency | `http_request_duration_seconds` (p50, p95, p99) | p99 > 2s |
| Errors | `http_requests_total{status=~"5.."}` | Error rate > 1% |
| Business | `predictions_total`, `imports_total` | Аномальное падение |
| Resources | `process_resident_memory_bytes` | > 80% от limit |
| DB | `pg_stat_activity_count` | > 80% от pool_max |

**Grafana** дашборды:
- **Overview**: все сервисы, latency, error rate, throughput.
- **Business metrics**: активные пользователи, созданные прогнозы, импорты.
- **Infrastructure**: CPU, память, диск, сеть по контейнерам.

### Уровень 3: Loki (логи)

Loki — как Prometheus, но для логов. Логи из всех Docker-контейнеров собираются через Promtail и индексируются в Loki:

```yaml
# logging driver в docker-compose.yml
services:
  api-gateway:
    logging:
      driver: loki
      options:
        loki-url: "http://loki:3100/loki/api/v1/push"
        loki-labels: "job=api-gateway,env=production"
```

Это позволяет в Grafana переходить от метрики к связанным логам одним кликом (Grafana Explore).

---

## 8. Резервное копирование

Стратегия бэкапов следует правилу 3-2-1: 3 копии данных, на 2 разных типах носителей, 1 копия offsite.

### PostgreSQL

```bash
#!/bin/bash
# /opt/anticifi/scripts/backup-postgres.sh

DATE=$(date +%Y-%m-%d-%H%M%S)
BACKUP_DIR="/opt/anticifi/backups/postgres"
S3_BUCKET="s3://anticifi-backups/postgres"

mkdir -p $BACKUP_DIR

# Полный дамп базы
docker compose exec -T postgres pg_dump \
  -U anticifi \
  -d anticifi \
  --format=custom \
  --compress=9 \
  > $BACKUP_DIR/anticifi-$DATE.dump

# Загрузить в S3-совместимое хранилище
aws s3 cp $BACKUP_DIR/anticifi-$DATE.dump $S3_BUCKET/

# Удалить локальные бэкапы старше 7 дней
find $BACKUP_DIR -name "*.dump" -mtime +7 -delete

echo "Backup completed: anticifi-$DATE.dump"
```

Расписание через cron:

```bash
# /etc/cron.d/anticifi-backup
0 2 * * * root /opt/anticifi/scripts/backup-postgres.sh >> /var/log/anticifi-backup.log 2>&1
```

**WAL archiving** для point-in-time recovery:

```bash
# В PostgreSQL конфигурации (postgresql.conf или через env)
archive_mode = on
archive_command = 'aws s3 cp %p s3://anticifi-backups/wal/%f'
```

С WAL archiving можно восстановить базу на любой момент времени (не только в момент снапшота). Критично при случайном удалении данных.

**Тестирование восстановления** — раз в месяц:

```bash
# Проверить, что бэкап валиден и восстанавливается
docker run --rm postgres:16-alpine \
  pg_restore --list /path/to/backup.dump | head -20
```

### Redis

Redis настроен на RDB-снапшоты (`--save 21600 1` — каждые 6 часов при наличии изменений). Том `redis_data` хранит снапшоты на диске.

Для production дополнительно включить AOF (Append-Only File):

```
appendonly yes
appendfsync everysec   # flush на диск каждую секунду
```

AOF гарантирует потерю данных не более чем за 1 секунду при сбое.

### Файлы загрузки (uploads)

Загруженные пользователями банковские выписки хранятся в томе `uploads_data`. Синхронизация в S3:

```bash
# Каждый час синхронизировать загрузки в S3
0 * * * * root aws s3 sync /opt/anticifi/uploads s3://anticifi-uploads/ --delete
```

Для production рекомендуется сразу использовать S3-совместимое хранилище (AWS S3, Cloudflare R2, Hetzner Object Storage) вместо локального тома — это исключает проблему с потерей файлов при пересоздании сервера.

---

## 9. Чеклист деплоя

### Pre-deployment

- [ ] Все тесты в CI прошли успешно.
- [ ] PR прошёл code review и merged.
- [ ] Миграции БД написаны и протестированы (обратно совместимы со старым кодом).
- [ ] `.env` на сервере обновлён, если добавились новые переменные.
- [ ] Создан backup БД перед деплоем (`/opt/anticifi/scripts/backup-postgres.sh`).
- [ ] Команда уведомлена о предстоящем деплое (если в рабочее время).

### Deployment

```bash
# 1. Подключиться к серверу
ssh deploy@server.anticifi.app

# 2. Перейти в директорию проекта
cd /opt/anticifi

# 3. Применить миграции БД
docker compose run --rm api-gateway npx sequelize-cli db:migrate

# 4. Скачать новые образы
docker compose -f docker-compose.yml -f docker-compose.prod.yml pull

# 5. Применить обновление (zero-downtime)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 6. Удалить старые образы
docker image prune -f

# 7. Проверить статус контейнеров
docker compose ps
```

### Post-deployment

- [ ] Проверить health endpoint: `curl https://api.anticifi.app/health`.
- [ ] Проверить логи на ошибки: `docker compose logs --tail=100 api-gateway`.
- [ ] Убедиться, что все контейнеры в состоянии `Up` (не `Restarting`).
- [ ] Пройти основные пользовательские сценарии вручную.
- [ ] Проверить дашборд ошибок в Sentry — нет ли новых issues.
- [ ] Убедиться, что Uptime Robot показывает "Up".

### Rollback

При обнаружении критической проблемы после деплоя:

```bash
# Вернуть предыдущую версию образа
# (замените на предыдущий тег из GHCR)
export VERSION=v1.2.2

docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Если проблема в миграции — откатить
docker compose run --rm api-gateway npx sequelize-cli db:migrate:undo
```

Rollback миграции возможен только если миграция была написана с методом `down`. Это обязательное требование к структуре всех миграций в проекте.

---

> Следующий документ по теме: [Архитектура системы](./architecture.md) — взаимодействие сервисов, диаграммы компонентов, технические решения.
>
> Документация по API: [Спецификация API](./api-spec.md).
>
> Схема базы данных: [Database Schema](./database-schema.md).

---

*AnticiFi — Know your balance before it happens.*
