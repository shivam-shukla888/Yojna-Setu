# YOJNA SETU V2 — SECURITY SPECIFICATION
**Document:** `docs/v2/SECURITY.md`  
**Version:** 2.1.0 (Phase F1 Remediated)  
**Compliance Standards:** OWASP Top 10, CWE Guidelines, Indian DPDPA 2023  
**Status:** REMEDIATED & HARDENED  

---

## 1. Security Architecture Principles

Yojna Setu V2 enforces strict defense-in-depth across the application lifecycle.

```
       [ Untrusted Inbound Traffic ]
                     |
                     v
   +------------------------------------+
   |     TLS 1.3 Termination            |
   +------------------------------------+
                     |
                     v
   +------------------------------------+
   |  Twilio HMAC-SHA1 Webhook Filter   |  <--- Rejects forged payloads (403 Forbidden)
   +------------------------------------+
                     |
                     v
   +------------------------------------+
   |   Bucket4j Token Bucket Limiter    |  <--- 20 req/min per sender (429 Too Many Requests)
   +------------------------------------+
                     |
                     v
   +------------------------------------+
   |  Durable Webhook Idempotency Store |  <--- Rejects duplicate deliveries (200 OK empty response)
   +------------------------------------+
                     |
                     v
   +------------------------------------+
   |   Spring Security Filter Chain     |  <--- API Key validation for /admin/** (401 Unauthorized)
   +------------------------------------+
                     |
                     v
   +------------------------------------+
   |   MediaUrlSecurityValidator & SSRF |  <--- Host allowlist, DNS IP check, redirect re-validation
   +------------------------------------+
                     |
                     v
   +------------------------------------+
   |   Domain Engine & AI Guardrails    |  <--- Strict XML isolation, deterministic eligibility engine
   +------------------------------------+
                     |
                     v
   +------------------------------------+
   |   Supabase PostgreSQL (yojna_setu) |  <--- Dedicated schema, blind-indexed PII (RLS at app-tier)
   +------------------------------------+
```

---

## 2. Authentication & Authorization

### 2.1 Provider Webhook Authentication (`INTERNAL_WEBHOOK`)
- All incoming requests to `/api/v1/webhooks/twilio/whatsapp` and `/webhook/whatsapp` route exclusively to `TwilioWebhookController`.
- Legacy unauthenticated webhook controllers have been permanently eliminated.
- The controller computes the expected HMAC-SHA1 signature using `com.twilio.security.RequestValidator` with the full HTTPS request URL, form POST parameters, and `TWILIO_AUTH_TOKEN`.
- In non-local environments (`app.env != local`), requests missing or failing signature verification are halted immediately with `403 Forbidden`.

### 2.2 Administrative Authentication (`ADMIN`)
- Administrative endpoints (`/api/v1/admin/**`) require the `X-API-KEY` HTTP header.
- The `ApiKeyAuthenticationFilter` verifies this header using constant-time string comparison against the server's `INTERNAL_API_SECRET` environment variable.
- Requests failing authentication receive `401 Unauthorized`.

### 2.3 Elimination of Public IDOR & Legacy Endpoints
- The legacy public endpoint `/api/eligibility/{phoneNumber}` has been **completely removed**.
- The legacy profile endpoints `/api/profile/{phoneNumber}` and `/api/profile/save` have been **completely removed**.
- The legacy conversation endpoint `/api/conversation` has been **completely removed**.
- Demographic and eligibility data cannot be enumerated or accessed by phone number through public APIs.

---

## 3. Rate Limiting & Abuse Prevention

Using **Bucket4j**:
- **Inbound Webhook Limit:** 20 messages per minute per sender phone number hash.
- **Burst Capacity:** 20 messages. Rapid requests exceeding capacity trigger HTTP `429 Too Many Requests` ("Rate limit exceeded").
- *Note:* Rate limiting is currently process-local memory. For multi-node container clusters, a distributed Redis/Hazelcast backing store is required.

---

## 4. Server-Side Request Forgery (SSRF) Defense

For inbound WhatsApp voice notes or media attachments, `MediaUrlSecurityValidator` and `SafeMediaDownloadService` enforce strict security controls:
1. **HTTPS Protocol Only:** HTTP URLs are strictly rejected.
2. **Strict Host Allowlist:** Suffix matching tricks (e.g. `attacker-twilio.com`) are defeated by regex allowlisting only exact authorized Twilio domains (`api.twilio.com`, `media.twiliocdn.com`, `mms.twiliocdn.com`, or `^[a-zA-Z0-9-]+\.(twilio\.com|twiliocdn\.com)$`).
3. **DNS Resolution & IP Boundary Check:** Resolves domain IPs and revalidates against:
   - Loopback (`127.0.0.0/8`, `::1`)
   - Private subnets (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`)
   - Link-local (`169.254.0.0/16`, `fe80::/10`)
   - Cloud metadata IP (`169.254.169.254`)
   - IPv6 unique local addresses (`fc00::/7`)
4. **Redirect Re-Validation:** Automatic redirects are disabled. Manual redirect handling intercepts 301/302/303/307/308 responses and revalidates the target URL before following (max depth: 2).
5. **Content-Type Validation:** Responses must declare an audio MIME type (`audio/ogg`, `audio/amr`, `audio/wav`, `audio/mpeg`, etc.).
6. **Payload Bounds:** Content-Length and streamed byte sizes are capped at 5 MB (5,242,880 bytes).
7. **Timeouts:** Connect timeout is bounded to 3,000 ms; read timeout is bounded to 5,000 ms.

---

## 5. PII Protection & DPDPA 2023 Alignment

1. **Blind Indexing:** Raw phone numbers are normalized to E.164 and hashed with SHA-256 (`phone_number_hash`) combined with an application salt pepper. Database lookups and session linkages use this hash.
2. **Log Redaction:** `PiiMaskingConverter` masks phone numbers (`+91-XXXXXX1234`) and redacts credentials before writing to console logs.
3. **Right to Erasure:** Sending `reset` in the conversation state machine purges demographic attributes in `user_profiles`.
4. **Database Tier Security:** Database-level Row Level Security (RLS) is currently **NOT IMPLEMENTED**; all tenant authorization is enforced at the Spring Boot application tier.
