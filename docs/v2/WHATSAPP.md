# Yojna Setu V2 — WhatsApp Integration Architecture

## 1. Overview & Architecture

Yojna Setu V2 provides a hardened, asynchronous, and dual-mode messaging boundary. In legacy V1, incoming Twilio webhooks lacked signature verification, processed requests synchronously on the HTTP request thread, suffered from race conditions under network retries, and leaked sensitive credentials.

V2 introduces the **Provider Abstraction Pattern** via the `WhatsAppMessageProvider` interface:

```
                  +---------------------------+
                  |  Inbound Webhook HTTP POST|
                  +-------------+-------------+
                                |
                                v
               +---------------------------------+
               | TwilioWebhookController         |
               | - Bucket4j Rate Limiting (IP/No)|
               | - HMAC-SHA1 Signature Verify   |
               | - In-Memory Fast Deduplication  |
               +----------------+----------------+
                                |
                                v
               +---------------------------------+
               | DB Idempotency Filter           |
               | - INSERT webhook_events         |
               |   (payload_hash, message_sid)   |
               | - UNIQUE violation -> 200 OK dup|
               +----------------+----------------+
                                |
                                v
               +---------------------------------+
               | ConversationOrchestrator        |
               | - Asynchronous Execution        |
               | - State Machine Dispatch        |
               +----------------+----------------+
                                |
                                v
               +---------------------------------+
               | WhatsAppMessageProvider         |
               |  (Twilio / Demo Mock Channel)   |
               +---------------------------------+
```

---

## 2. Inbound Webhook Lifecycle & Security

### 2.1 Webhook Verification (HMAC-SHA1)
Twilio signs every webhook request using your Twilio Auth Token. The signature is sent in the `X-Twilio-Signature` header.
- In V2, `TwilioWhatsAppProvider.validateWebhookSignature(requestUrl, formParams, signature)` computes the HMAC-SHA1 hash over the full sorted parameter string and compares it against the header.
- Unsigned or invalid requests are immediately rejected with `401 Unauthorized`.
- In `local` / `test` profiles where `app.twilio.validate-signature=false`, signature validation can be bypassed for synthetic testing.

### 2.2 Rate Limiting
- Built using **Bucket4j**: 20 requests per minute per IP address / phone number.
- Exceeding the burst threshold returns HTTP `429 Too Many Requests` without touching the conversation database or calling the Groq AI API.

### 2.3 Strict Message Idempotency
Twilio retries webhook delivery if your server doesn't respond within 5 seconds or if a temporary network blip occurs. Without idempotency, users receive duplicate responses and profile data can be corrupted.
- **In-Memory Cache**: `ConcurrentHashMap` with TTL caching prevents rapid re-entrant requests within milliseconds.
- **Durable Persistence (`webhook_events`)**:
  - `message_sid` (Twilio `MessageSid`) and `payload_hash` (SHA-256) are stored with a unique database constraint.
  - If a retry arrives, `DataIntegrityViolationException` is caught, and an HTTP `200 OK` empty TwiML is returned immediately without re-executing business logic.

---

## 3. Media & Audio Handling (Voice Notes)

Twilio voice messages are delivered with `MediaContentType0=audio/ogg` or `audio/amr` and a media URL `MediaUrl0`.

### 3.1 SSRF Mitigation
Before fetching media files from external URLs:
1. **Domain Whitelist**: Only hostnames matching `*.twilio.com` or configured trusted S3 buckets are accepted.
2. **Private IP Rejection**: URLs resolving to `127.0.0.1`, `10.0.0.0/8`, `192.168.0.0/16`, `169.254.169.254` (cloud metadata services) are rejected immediately.
3. **Size Limit**: Restricts downloads to 10 MB maximum to prevent memory exhaustion attacks.

### 3.2 Whisper Transcription Pipeline
1. Audio bytes are safely retrieved via Twilio HTTP basic auth.
2. Audio stream is routed to `GroqAiGateway.transcribeAudio(...)` using `whisper-large-v3`.
3. The transcribed text is injected into the standard text pipeline as an `InboundMessage` with `isAudio=true`.

---

## 4. Dual Channel Abstraction

| Provider Implementation | Configuration | Use Case |
| :--- | :--- | :--- |
| `TwilioWhatsAppProvider` | Active when `app.twilio.account-sid` is configured | Production WhatsApp messaging via Twilio REST API. |
| `DemoChannelProvider` | Fallback / Default in dev & test | In-memory message store allowing the web browser demo to inspect outbound messages and interactive chat without Twilio credentials. |

---

## 5. Webhook Endpoints Reference

### `POST /api/v1/webhook/twilio`
- **Consumes**: `application/x-www-form-urlencoded`
- **Headers**:
  - `X-Twilio-Signature`: Twilio HMAC-SHA1 signature
- **Form Parameters**:
  - `From`: E.g. `whatsapp:+919876543210`
  - `Body`: User message text
  - `MessageSid`: Twilio unique message ID
  - `NumMedia`: Number of attached media items (optional)
  - `MediaUrl0`: Attached media URL (if voice note)
  - `MediaContentType0`: E.g. `audio/ogg`
- **Responses**:
  - `200 OK`: TwiML XML `<Response></Response>`
  - `401 Unauthorized`: Missing or invalid Twilio signature
  - `429 Too Many Requests`: Rate limit exceeded
