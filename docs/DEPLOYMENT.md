# AnticiFi Deployment Guide

## Infrastructure Overview

| Service | Domain / Host | Port | Platform |
|---------|--------------|------|----------|
| Landing (Astro + Nginx) | `https://anticifi.com` | 80 | Coolify |
| Backend (NestJS) | `https://api.anticifi.com` | 3000 | Coolify |
| Admin Panel (React + Nginx) | `https://admin.anticifi.com` | 80 | Coolify |
| PostgreSQL 16 | `dss4w00kcc08sk08s0owok4c` (internal) | 5432 | Coolify DB |
| Redis 7 | `fs40ggs00skko44ks8c0o0ko` (internal) | 6379 | Coolify DB |
| NATS 2 | `ycw44w00gwgw4w84gkg08s4o-nats` (internal) | 4222 | Coolify Service |

**Coolify Dashboard:** `https://dashboard.banquetcalc.click`
**Server:** localhost (Coolify host)
**Project UUID:** `p4ow4c0cc0gwscwooc0kwo0w`

## Coolify Resource UUIDs

| Resource | UUID |
|----------|------|
| Landing app | `agg8w0kwss80o8k8wwkggw48` |
| Backend app | `dos0gk0cg4gk08s8o44s0og4` |
| Admin Panel | `x0ccooccss4w48oo48488gko` |
| PostgreSQL | `dss4w00kcc08sk08s0owok4c` |
| Redis | `fs40ggs00skko44ks8c0o0ko` |
| NATS service | `ycw44w00gwgw4w84gkg08s4o` |

## Prerequisites

- Coolify CLI installed and configured (`coolify context list`)
- GitHub App `bogbuk-github` (UUID: `oc04ocs80k4okkgsw48oks00`) connected
- DNS A-records for `anticifi.com` and `api.anticifi.com` pointing to server IP

## Deploy Steps

### 1. Deploy Landing

```bash
# Push code to main, then:
coolify deploy uuid agg8w0kwss80o8k8wwkggw48

# Check status:
coolify deploy get <deployment_uuid>
```

- Source: `landing/` directory, Dockerfile build (multi-stage: node -> nginx)
- Domain: `https://anticifi.com`
- SSL: auto Let's Encrypt via Coolify/Traefik

### 2. Deploy Backend

```bash
coolify deploy uuid dos0gk0cg4gk08s8o44s0og4

# Check status:
coolify deploy get <deployment_uuid>

# Check health:
curl https://api.anticifi.com/api/health
```

- Source: `backend/` directory, multi-stage Dockerfile
- Domain: `https://api.anticifi.com`
- ENV: runtime-only (not build-time) to avoid `NODE_ENV=production` breaking `npm ci`

### 3. Deploy Admin Panel

```bash
coolify deploy uuid x0ccooccss4w48oo48488gko
```

- Source: `admin/` directory, multi-stage Dockerfile (node build → nginx serve)
- Domain: `https://admin.anticifi.com`
- ENV: `VITE_API_URL=https://api.anticifi.com` (build-time)

### 4. Restart Backend (after env changes)

```bash
coolify app restart dos0gk0cg4gk08s8o44s0og4
```

### 4. View Logs

```bash
coolify app logs agg8w0kwss80o8k8wwkggw48   # Landing
coolify app logs dos0gk0cg4gk08s8o44s0og4   # Backend
```

### 5. Check All Statuses

```bash
coolify app get agg8w0kwss80o8k8wwkggw48    # Landing
coolify app get dos0gk0cg4gk08s8o44s0og4    # Backend
coolify database get dss4w00kcc08sk08s0owok4c  # PostgreSQL
coolify database get fs40ggs00skko44ks8c0o0ko  # Redis
coolify service get ycw44w00gwgw4w84gkg08s4o   # NATS
```

## Environment Variables

Template: `.env.example.prod` (root of repo).

### Syncing env to Backend

```bash
# Edit your .env file, then:
coolify app env sync dos0gk0cg4gk08s8o44s0og4 --file .env.prod --is-literal

# Restart to apply:
coolify app restart dos0gk0cg4gk08s8o44s0og4
```

### Key internal hostnames

```
DB_HOST=dss4w00kcc08sk08s0owok4c
DATABASE_URL=postgres://anticifi:<password>@dss4w00kcc08sk08s0owok4c:5432/anticifi_prod
REDIS_URL=redis://default:<password>@fs40ggs00skko44ks8c0o0ko:6379/0
NATS_URL=nats://ycw44w00gwgw4w84gkg08s4o-nats:4222
```

**Important:** `NODE_ENV` must be runtime-only (`is_buildtime: false`), otherwise `npm ci` skips devDependencies and `nest build` fails.

## DNS Setup (GoDaddy)

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | `@` | `<SERVER_IP>` | 600 |
| A | `api` | `<SERVER_IP>` | 600 |
| A | `admin` | `<SERVER_IP>` | 600 |

## Dockerfiles

### Landing (`landing/Dockerfile`)
Multi-stage: `node:22-alpine` builds Astro, `nginx:alpine` serves static files on port 80.

### Backend (`backend/Dockerfile`)
Multi-stage: `node:20-alpine` installs all deps + builds NestJS, second stage copies only `dist/` and `node_modules/` for runtime on port 3000.

## Troubleshooting

### Backend build fails with "nest: not found"
- Cause: `NODE_ENV=production` set as build-time variable, `npm ci` skips devDependencies
- Fix: set `NODE_ENV` to runtime-only in Coolify env settings

### Redis shows "exited:unhealthy"
```bash
coolify database restart fs40ggs00skko44ks8c0o0ko
```

### Check deployment logs
```bash
coolify deploy list --format json
coolify deploy get <deployment_uuid> --format json
```
