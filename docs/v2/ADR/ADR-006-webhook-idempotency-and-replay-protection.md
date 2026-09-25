# ADR-006: Webhook Idempotency, Cryptographic Verification, and Replay Protection

## Status
ACCEPTED

## Context
In the legacy project:
- Webhooks hitting `/webhook/whatsapp` performed zero signature verification; anyone could forge incoming messages.
- No idempotency mechanism existed. Twilio retry policies (triggered on network hiccups or timeouts) would re-execute the business logic multiple times, sending duplicate messages and confusing the user.
- No replay window was enforced.

## Decision
1. **Cryptographic Signature Verification:**
   - Intercept all incoming Twilio webhooks with a dedicated Spring `OncePerRequestFilter`.
   - Validate `X-Twilio-Signature` using official `com.twilio.security.RequestValidator` against the full HTTPS URL and POST form parameters.
   - Reject unverified requests with HTTP `403 Forbidden`.
2. **Durable Idempotency Store:**
   - Create a dedicated PostgreSQL table: `yojna_setu.webhook_events`.
   - Columns: `id` (UUID), `provider` (VARCHAR), `provider_message_id` (VARCHAR UNIQUE), `payload_hash` (VARCHAR), `status` (VARCHAR), `created_at` (TIMESTAMPTZ).
   - Before processing an inbound message, insert a row with `provider_message_id` (e.g. Twilio `MessageSid`).
   - If an insert encounters a unique key collision (duplicate delivery), immediately abort processing and respond with HTTP `200 OK` to acknowledge receipt to the provider without re-triggering business logic.
3. **Replay Window Enforcement:**
   - Reject webhook payloads where the timestamp header exceeds a 300-second window.

## Consequences
### Positive
- Completely stops message spoofing and webhook forgery.
- Eliminates duplicate message processing and duplicate billing on outbound Twilio messages.
- Robust under network retries and transient downstream timeouts.

### Negative / Trade-offs
- Slight latency overhead for the database insert into `webhook_events` prior to message processing.
