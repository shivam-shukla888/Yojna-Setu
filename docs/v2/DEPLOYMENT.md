# Yojna Setu V2 — Production Deployment Guide

## 1. Target Architecture & Environment

Yojna Setu V2 is designed to run in containerized environments (AWS ECS / Fargate, Google Cloud Run, Azure Container Apps, or bare Kubernetes) backed by Supabase PostgreSQL (or any managed PostgreSQL 15+).

```
                 +-------------------------------+
                 |  End Users (WhatsApp Client)  |
                 +---------------+---------------+
                                 |
                                 v
                 +-------------------------------+
                 |       Twilio Messaging API    |
                 +---------------+---------------+
                                 |
                                 | Webhook HTTP POST
                                 v
                 +-------------------------------+
                 |   Cloudflare / Nginx (HTTPS)  |
                 |   - TLS Termination           |
                 |   - DDoS & Bot Mitigation     |
                 +---------------+---------------+
                                 |
                                 v
                 +-------------------------------+
                 |   Yojna Setu V2 Application   |
                 |   (Docker Container, Java 21) |
                 |   - Non-root User (10001)     |
                 |   - G1GC Memory Bounded       |
                 +---------------+---------------+
                                 |
           +---------------------+---------------------+
           |                                           |
           v                                           v
+-----------------------+                   +-----------------------+
| Supabase PostgreSQL   |                   | Groq Llama 3.1 &      |
| Schema: `yojna_setu`  |                   | Whisper Large Cloud   |
+-----------------------+                   +-----------------------+
```

---

## 2. Configuration & Secret Management

All secrets MUST be supplied through environment variables or secure secret managers (AWS Secrets Manager, HashiCorp Vault, Doppler). **Never hardcode secrets in source code.**

### 2.1 Essential Environment Variables

| Variable | Description | Example / Default |
| :--- | :--- | :--- |
| `SPRING_PROFILES_ACTIVE` | Active profile | `prod` |
| `APP_ENV` | Application environment | `production` |
| `SERVER_PORT` | HTTP listening port | `8080` |
| `DB_URL` | PostgreSQL JDBC connection URL | `jdbc:postgresql://<host>:5432/<db>?currentSchema=yojna_setu` |
| `DB_USER` | PostgreSQL user | `postgres` |
| `DB_PASSWORD` | PostgreSQL password | *Set securely* |
| `GROQ_API_KEY` | Groq LLM & Whisper API Key | `gsk_...` |
| `GROQ_MODEL` | Groq model identifier | `llama-3.1-8b-instant` |
| `TWILIO_ACCOUNT_SID` | Twilio Account SID | `AC...` |
| `TWILIO_AUTH_TOKEN` | Twilio Auth Token for signature validation | *Set securely* |
| `TWILIO_WHATSAPP_FROM` | Sender WhatsApp number | `whatsapp:+14155238886` |
| `SECURITY_INTERNAL_API_SECRET` | Secret token for `X-API-KEY` admin access | *Min 32 random characters* |
| `SECURITY_PHONE_HASH_PEPPER` | Cryptographic pepper for phone SHA-256 | *Min 32 random characters* |

---

## 3. Database Migration Strategy (Flyway)

Yojna Setu V2 utilizes Flyway migrations targeting the isolated `yojna_setu` schema.

1. Ensure the schema exists in PostgreSQL:
   ```sql
   CREATE SCHEMA IF NOT EXISTS yojna_setu;
   ```
2. When the application starts with `spring.flyway.enabled=true`, Flyway automatically applies pending migrations:
   - `V1__init_yojna_setu_schema.sql` (Tables, ENUMs, Indexes)
   - `V2__seed_normalized_schemes.sql` (82 normalized schemes from legacy dataset)
3. Zero Downtime: All new columns added in future migrations must be nullable or include default values.

---

## 4. Docker Deployment

### 4.1 Building the Production Container
```bash
docker build -t yojna-setu:2.0.0 .
```

### 4.2 Running with Docker Compose
```bash
# Populate .env with required keys
docker-compose up -d --build
```

### 4.3 Container Security Hardening
- **Unprivileged User**: The container drops privileges to UID `10001` (`yojnasetu`).
- **Memory Bounded**: JVM respects container memory limits via `-XX:MaxRAMPercentage=75.0`.
- **Healthcheck**: Periodically verifies `/actuator/health` via `curl`.

---

## 5. Reverse Proxy Configuration (Nginx)

When deploying behind Nginx, preserve headers so Twilio signature verification and rate limiting operate accurately:

```nginx
server {
    listen 443 ssl http2;
    server_name yojnasetu.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yojnasetu.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yojnasetu.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_connect_timeout 5s;
        proxy_read_timeout 60s;
    }
}
```
