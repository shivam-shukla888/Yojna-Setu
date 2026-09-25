# ADR-007: PII-Safe Logging, Data Protection, and Compliance (DPDPA 2023)

## Status
ACCEPTED

## Context
The legacy application handled sensitive citizen data (unmasked phone numbers, income, caste, disability, marital status) recklessly:
- `WhatsAppWebhookController` and `TwilioService` logged raw E.164 phone numbers and complete incoming message text at `INFO` level.
- `GroqService` logged raw HTTP request bodies and JSON responses containing citizen details.
- Public endpoints (`/api/users/{id}`, `/api/user-profiles/{userId}`) allowed unauthenticated enumeration and scraping of citizen demographic profiles.
- This violated basic security principles and India's Digital Personal Data Protection Act (DPDPA 2023).

## Decision
1. **Blind Indexing for Phone Numbers:**
   - In `yojna_setu.users`, compute a deterministic SHA-256 hash (`phone_number_hash`) of the normalized E.164 phone number.
   - Use `phone_number_hash` for fast indexed lookups (`O(1)`), preventing raw phone numbers from acting as primary foreign keys or exposure vectors.
   - Encrypt `phone_number_e164` at rest in the database using AES-256-GCM or application-layer encryption.
2. **Log Redaction & Sanitization:**
   - Configure a custom Logback masking converter across all log appenders.
   - Automatically redact:
     - Phone numbers: Replace with masked string `+91XXXXXX[last4]`.
     - Auth tokens, passwords, and API keys: Replace with `[REDACTED]`.
     - Raw chat bodies: Logged only at `DEBUG` or `TRACE` level in local development, never in production `INFO` logs.
3. **Elimination of Public IDOR Endpoints:**
   - Completely remove `/api/users/**` and `/api/user-profiles/**`.
   - Access to profile data is restricted strictly to the authenticated citizen's session on WhatsApp or verified demo session.
4. **Data Minimization & Right to Erasure:**
   - Implement `/reset` and `/delete-my-data` commands enabling citizens to wipe their demographic profiles and session histories.

## Consequences
### Positive
- Fully compliant with Indian DPDPA 2023 standards for citizen data protection.
- Log aggregation pipelines (CloudWatch, ELK, Datadog) remain clean of sensitive personal information.
- Eliminates the primary vector for mass scraping of citizen welfare data.

### Negative / Trade-offs
- Debugging production issues requires searching logs via correlation IDs (`trace_id`) rather than raw phone numbers.
