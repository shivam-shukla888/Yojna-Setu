# Yojna Setu V2 — Automated Testing Strategy & Verification Report

## 1. Testing Philosophy

In Yojna Setu V2, testing is treated as an engineering gate rather than an afterthought. The system eliminates non-deterministic external dependencies during testing while validating the core domain logic, security boundaries, and conversational state transitions.

```
       +---------------------------------------------+
       |             End-to-End Tests                |
       |  - Twilio Webhook Controller & Idempotency  |
       |  - Admin Scheme Security Filter             |
       +----------------------+----------------------+
                              |
       +----------------------v----------------------+
       |           Integration Tests                 |
       |  - Conversation State Machine Transitions   |
       |  - User Profile Reset & Lifecycle           |
       +----------------------+----------------------+
                              |
       +----------------------v----------------------+
       |               Unit Tests                    |
       |  - Deterministic Eligibility Rule Matching  |
       |  - PII Masking Converter                    |
       +---------------------------------------------+
```

---

## 2. Test Suite Architecture

### 2.1 Test Profiles & In-Memory Isolation
- **Profile**: Activated via `@ActiveProfiles("test")`.
- **Database**: In-memory H2 running in PostgreSQL compatibility mode (`MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;INIT=CREATE SCHEMA IF NOT EXISTS yojna_setu`).
- **External Mocking**: Groq API and Twilio SDK are mocked or bypassed using the `DemoChannelProvider` and synthetic API keys, ensuring tests are 100% offline and deterministic.

---

## 3. Test Matrix & Results

| Test Class | Focus Area | Scenarios Covered | Status |
| :--- | :--- | :--- | :--- |
| `EligibilityEngineTest` | Deterministic Rules | - Exact Age boundary checks<br>- Gender matching (proves `"FEMALE".contains("MALE")` bug fixed)<br>- Caste eligibility<br>- Income threshold checks<br>- State and disability filters | **PASSED** (6/6) |
| `AdminSchemeSecurityTest` | Security Boundary | - Missing `X-API-KEY` header returns 401<br>- Invalid `X-API-KEY` returns 401<br>- Valid `X-API-KEY` grants access<br>- Audit log endpoint authorization | **PASSED** (4/4) |
| `TwilioWebhookControllerTest` | Webhook Hardening | - Missing `From` returns 400 Bad Request<br>- Durable duplicate `MessageSid` returns 200 OK empty TwiML | **PASSED** (2/2) |
| `TwilioWebhookHardeningTest` | Production Webhooks | - Reject forged webhook signature with 403 Forbidden<br>- Accept valid HMAC-SHA1 signature<br>- Replay attack prevention with message idempotency<br>- Rate limiting threshold enforcement (Bucket4j)<br>- Reject malformed payload with 400 Bad Request | **PASSED** (5/5) |
| `ConversationOrchestratorTest` | State Machine | - `INIT` state prompts language selection<br>- Option 1 selects Hindi and transitions state<br>- `reset` command clears profile & session<br>- `help` returns guidance | **PASSED** (4/4) |
| `LegacyRouteEliminationTest` | Attack Surface Reduction | - Assert legacy `/whatsapp` route removed (returns 404)<br>- Assert legacy `/api/groq/extract` route removed (returns 404)<br>- Assert IDOR `/api/schemes/check-eligibility` removed (returns 404)<br>- Assert unauthenticated user enumeration routes removed | **PASSED** (4/4) |
| `MediaUrlSecurityValidatorTest` | SSRF & Media Defense | - Allowlist validation for official `api.twilio.com`<br>- Block non-whitelisted hostnames and lookalikes<br>- Block loopback IPv4 (`127.0.0.1`) and IPv6 (`::1`)<br>- Block AWS metadata link-local address (`169.254.169.254`)<br>- Block RFC 1918 private IPv4 subnets (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)<br>- Block IPv6 unique local addresses (fc00::/7)<br>- Content-Type filtering (permit audio/ogg, audio/mpeg, audio/wav, block text/html, application/json, scripts) | **PASSED** (12/12) |
| `SafeMediaDownloadServiceTest` | Safe Media Retrieval | - Rejection of internal network media URLs<br>- Rejection of untrusted domains<br>- Rejection of dangerous file MIME types<br>- Protection against DNS rebinding via post-resolution IP checking | **PASSED** (4/4) |
| `YojnaSetuApplicationTests` | Context Integrity | - Spring Boot context loads without bean wiring conflicts | **PASSED** (1/1) |
| **Total** | **Full System Suite** | **42 Unit, Integration & Security Scenarios** | **100% PASS** |

---

## 4. Running the Test Suite Locally

```bash
# Run all 42 tests
./mvnw clean test

# Run a specific test class
./mvnw test -Dtest=EligibilityEngineTest

# Run security and SSRF tests
./mvnw test -Dtest=AdminSchemeSecurityTest,MediaUrlSecurityValidatorTest,SafeMediaDownloadServiceTest
```
