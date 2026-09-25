# Yojna Setu V2 — Final Independent Security & Production Readiness Audit

**Audit Date**: September 25, 2026  
**Auditor**: Independent Principal Systems & Security Architect  
**Repository State**: Branch `main`, HEAD commit `414349c`  
**Execution Context**: Read-Only Forensic Verification  

---

## 1. Executive Verdict

### **VERDICT: B. PRODUCTION READY WITH CONDITIONS**

While Yojna Setu V2 represents a monumental architectural improvement over legacy V1 (eliminating destructive startup table drops, fixing the severe `"FEMALE".contains("MALE")` eligibility bug, introducing a 1NF normalized PostgreSQL schema for all 82 schemes, and implementing SHA-256 blind phone indexing), **it cannot be deployed directly to public production without satisfying five mandatory blocking conditions**. 

Specifically, remnant legacy controllers (`WhatsAppWebhookController`, `EligibilityController`), incomplete SSRF host boundary matching (`.endsWith("twilio.com")`), process-local memory rate limiting, and unpurged credentials in Git history present actionable security vulnerabilities that must be remediated prior to public traffic ingestion.

---

## 2. Repository Verification

The repository was verified via read-only inspection of source code, configurations, migration scripts, and test execution.

```
Total Tracked/Modified Files Inspected: 12
Total Untracked/V2 Artifacts Inspected: 33
Total Source Lines of Java: ~4,200 lines
Build Tooling: Apache Maven Wrapper (Java 21 LTS / Java 24 runtime compatible)
Database Target: PostgreSQL 16 (Dedicated schema: yojna_setu)
Test Harness: JUnit 5, Spring Boot Test 3.2.12, MockMvc, H2 (PostgreSQL Mode)
```

---

## 3. Critical Findings (Severity: CRITICAL)

### CRIT-01: Remnant Legacy Webhook Controller Exposes Twilio Credentials via SSRF
- **Location**: `src/main/java/com/yojnasetu/controller/WhatsAppWebhookController.java` & `src/main/java/com/yojnasetu/service/GroqService.java`
- **Execution Path**: `POST /webhook/whatsapp`
- **Vulnerability**: While V2 introduced `TwilioWebhookController` under `com.yojnasetu.provider`, the legacy `WhatsAppWebhookController` remains mapped to `/webhook/whatsapp`. When invoked with a `MediaUrl0` parameter, it calls `GroqService.transcribeAudio(mediaUrl)`:
  ```java
  byte[] audioBytes = WebClient.builder().build().get().uri(mediaUrl)
      .headers(headers -> headers.setBasicAuth(twilioSid, twilioToken))
      .retrieve().bodyToMono(byte[].class).block();
  ```
- **Impact**: Any unauthenticated attacker can send a spoofed webhook containing an arbitrary URL (e.g., `https://attacker-controlled-server.com`). The server will immediately make an outbound HTTP GET request and send the production `twilio.account.sid` and `twilio.auth.token` in the HTTP `Authorization` header, resulting in **complete account takeover of the Twilio telephony infrastructure**.
- **Remediation**: Delete or disable `WhatsAppWebhookController.java`, `GroqService.java`, and legacy `/webhook/whatsapp` mapping.

### CRIT-02: Public Unauthenticated IDOR Endpoint Leaks Scheme Recommendations by Phone Number
- **Location**: `src/main/java/com/yojnasetu/controller/EligibilityController.java` & `src/main/java/com/yojnasetu/config/SecurityConfig.java`
- **Execution Path**: `GET /api/eligibility/{phoneNumber}`
- **Vulnerability**: `SecurityConfig.java` explicitly permits public access:
  ```java
  .requestMatchers("/api/schemes/**", "/api/conversation/**", "/api/eligibility/**").permitAll()
  ```
  `EligibilityController.getEligibleSchemes(phoneNumber)` looks up the user profile directly from the raw phone string without authentication or authorization.
- **Impact**: An external actor can enumerate phone numbers to determine which users have profiles and infer sensitive demographic attributes (income, caste, disability, marital status) from matched schemes.
- **Remediation**: Remove `EligibilityController` and remove `/api/eligibility/**` from `permitAll()`.

---

## 4. High Findings (Severity: HIGH)

### HIGH-01: Flawed Subdomain Validation Enables SSRF Whitelist Bypass
- **Location**: `src/main/java/com/yojnasetu/provider/TwilioWebhookController.java` (Line 156)
- **Vulnerability**: The host validation for incoming voice notes checks:
  ```java
  if (host == null || !host.endsWith("twilio.com")) { ... }
  ```
- **Impact**: A host such as `https://attacker-twilio.com` or `https://malicioustwilio.com` evaluates to `true` under `.endsWith("twilio.com")`. An attacker can register an arbitrary domain ending in `twilio.com` to bypass host filtering and force the application to download arbitrary payload bytes.
- **Remediation**: Change condition to:
  ```java
  if (host == null || (!host.equals("api.twilio.com") && !host.endsWith(".twilio.com")))
  ```

### HIGH-02: Compromised Legacy Password Persists in Git History
- **Location**: Git commit history (`108c13f` and `35b9771`)
- **Evidence**: `git log -p` confirms that `--spring.datasource.password=[REDACTED_ANKJUS]` was committed in `start-app.sh`.
- **Impact**: Anyone cloning the repository can extract the historical database password via `git log` or `git checkout`.
- **Remediation**: Execute `git filter-repo` or BFG Repo-Cleaner to permanently scrub the string from commit history.

---

## 5. Medium Findings (Severity: MEDIUM)

### MED-01: Disconnected AI Demographic Extraction in V2 Conversation Pipeline
- **Location**: `src/main/java/com/yojnasetu/conversation/handler/ProfileCollectionHandler.java`
- **Finding**: While `GroqAiGateway.extractDemographics` was implemented and tested, `ProfileCollectionHandler` never calls it. Instead, profile collection relies on sequential regex helpers (`extractNumber`, `parseGender`, `cleanState`).
- **Impact**: Free-form natural language inputs (e.g. "I am a 28 year old female farmer from UP earning 1.5 lakh") are only partially parsed (setting only age), requiring the user to answer each demographic prompt one-by-one.
- **Documentation Mismatch**: Documentation claims V2 uses Groq for conversational multi-lingual demographic extraction; in reality, the state machine uses regex heuristics.

### MED-02: Bucket4j Rate Limiting Is Process-Local and Lacks Eviction
- **Location**: `src/main/java/com/yojnasetu/provider/TwilioWebhookController.java` (Line 48)
- **Finding**: `ConcurrentHashMap<String, Bucket> rateLimitBuckets` is stored purely in JVM heap memory.
- **Impact**:
  1. Under a distributed multi-instance deployment (e.g., 2+ containers), rate limits are not synchronized without a distributed cache (Redis/Hazelcast).
  2. The map lacks a TTL eviction policy, creating a gradual memory leak over millions of unique phone numbers.

### MED-03: Stack Traces and Exception Logging Bypass PII Redaction
- **Location**: `src/main/resources/logback-spring.xml`
- **Finding**: The pattern `%maskPii(%msg)%n` applies only to the log message string. If an exception with a nested stack trace or cause containing sensitive connection strings or phone numbers is logged via `logger.error("Error", ex)`, the exception message and stack trace bypass `PiiMaskingConverter`.

---

## 6. Low & Informational Findings

- **LOW-01: `MDC` Trace ID Unpopulated**: `logback-spring.xml` includes `[traceId=%X{traceId:-N/A}]`, but no servlet filter or interceptor populates `MDC.put("traceId", ...)`. Logs consistently display `traceId=N/A`.
- **LOW-02: Outdated systemd Service Reference**: `setup-server.sh` declares `After=network.target mysql.service`, reflecting legacy MySQL instead of PostgreSQL.
- **INFO-01: Outdated Twilio SDK**: `pom.xml` references Twilio SDK `9.3.0` (2023 release), while `10.x` is current.

---

## 7. Scheme Count Reconciliation

### Mandatory Forensic Finding: 62 vs. 82 Schemes
A contradiction was documented between the Phase 0 forensic report (claiming 62 schemes) and subsequent V2 reports (claiming 82 schemes). 

A byte-by-byte programmatic audit of `src/main/resources/data.sql` and `src/main/resources/db/migration/V2__seed_normalized_schemes.sql` produced the following ground truth:

1. **Source `data.sql` Scheme Count**: Exactly **82 distinct scheme tuples**.
   - Row 6 to 186 in `data.sql` contains exactly 82 tuple lines beginning with `('`.
   - The legacy `data.sql` schema had no `code` column; the first column was `name`.
2. **Phase 0 Audit Discrepancy Explained**:
   - The Phase 0 report erroneously counted only up to line 150 (missing the `NEWLY LAUNCHED 2024-2025` and `DISABILITY SCHEMES` sections). The claim in Phase 0 that the README's "82+ schemes" was false was **factually mistaken**.
3. **V2 Migration (`V2__seed_normalized_schemes.sql`)**:
   - Contains exactly **82 scheme blocks** (`-- Scheme #1:` through `-- Scheme #82:`).
   - Generates 82 unique normalized uppercase slug codes (e.g. `PM-KISAN`, `AYUSHMAN-BHARAT-SENIOR-CITIZENS`).
4. **Category Breakdown**:
   - `CENTRAL_GOVERNMENT`: **63**
   - `STATE_GOVERNMENT`: **11**
   - `PRIVATE`: **8**
   - **Total**: **82 Schemes**.
5. **Duplicate / Missing Codes**:
   - Duplicates in `data.sql`: **0**
   - Duplicates in V2 migration: **0**
   - Missing between source and target: **0**
   - **Verdict**: The claim of **82 schemes** is **100% VERIFIED AND ACCURATE**.

---

## 8. Security Control Matrix

| Control | Implementation | Repository Evidence | Test Verification | Status |
| :--- | :--- | :--- | :--- | :--- |
| **API Key Admin Protection** | `ApiKeyAuthenticationFilter` | [ApiKeyAuthenticationFilter.java](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/main/java/com/yojnasetu/security/ApiKeyAuthenticationFilter.java) | [AdminSchemeSecurityTest.java](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/test/java/com/yojnasetu/security/AdminSchemeSecurityTest.java) (4 tests) | **VERIFIED** |
| **Durable Idempotency** | Unique `provider_message_id` | [V1__init_yojna_setu_schema.sql](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/main/resources/db/migration/V1__init_yojna_setu_schema.sql#L155) | [TwilioWebhookControllerTest.java](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/test/java/com/yojnasetu/provider/TwilioWebhookControllerTest.java) | **VERIFIED** |
| **Blind Phone Hashing** | SHA-256 + Salt/Pepper | [ConversationOrchestrator.java](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/main/java/com/yojnasetu/conversation/ConversationOrchestrator.java#L62) | Verified in Orchestrator execution | **VERIFIED** |
| **Deterministic Rules** | Exact Enum match, no substring | [EligibilityEngine.java](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/main/java/com/yojnasetu/eligibility/EligibilityEngine.java) | [EligibilityEngineTest.java](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/test/java/com/yojnasetu/eligibility/EligibilityEngineTest.java) (6 tests) | **VERIFIED** |
| **Twilio HMAC-SHA1** | `RequestValidator` in controller | [TwilioWebhookController.java](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/main/java/com/yojnasetu/provider/TwilioWebhookController.java#L88) | Bypassed in test profile (`app.env=local`) | **PARTIALLY VERIFIED** |
| **Log PII Redaction** | `PiiMaskingConverter` | [logback-spring.xml](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/main/resources/logback-spring.xml) | Unit string verified; exception bypass noted | **PARTIALLY VERIFIED** |
| **Database Isolation** | PostgreSQL schema `yojna_setu` | [V1__init_yojna_setu_schema.sql](file:///c:/Users/thesh/Desktop/Yojna-Setu/src/main/resources/db/migration/V1__init_yojna_setu_schema.sql#L7) | H2 test mode configured | **VERIFIED** |
| **Database RLS** | Row Level Security policies | None | None | **RLS NOT IMPLEMENTED** |

---

## 9. Authentication & Endpoint Matrix

| Endpoint | Method | Authentication | Authorization | Exposure | Audit Finding |
| :--- | :---: | :--- | :--- | :--- | :--- |
| `/api/v1/admin/schemes` | GET, POST | `X-API-KEY` Header | `ROLE_ADMIN` | Internal / Admin | **SECURE** |
| `/api/v1/admin/schemes/{id}` | GET, PUT | `X-API-KEY` Header | `ROLE_ADMIN` | Internal / Admin | **SECURE** |
| `/api/v1/admin/schemes/{id}/status` | PATCH | `X-API-KEY` Header | `ROLE_ADMIN` | Internal / Admin | **SECURE** |
| `/api/v1/admin/audit-logs` | GET | `X-API-KEY` Header | `ROLE_ADMIN` | Internal / Admin | **SECURE** |
| `/api/v1/webhooks/twilio/whatsapp` | POST | Twilio HMAC-SHA1 | Twilio Auth Token | Public (Twilio) | **SECURE** (Rate limited, signature validated) |
| `/api/v1/demo/chat` | POST | None | None | Public Demo | **PUBLIC DEMO** (Intended for portfolio) |
| `/api/v1/demo/reset` | POST | None | None | Public Demo | **PUBLIC DEMO** |
| `/api/v1/demo/stats` | GET | None | None | Public Demo | **PUBLIC DEMO** |
| `/demo.html` | GET | None | None | Public UI | **PUBLIC ASSET** |
| `/actuator/health` | GET | None | None | Public Health | **PUBLIC MONITORING** |
| `/webhook/whatsapp` (Legacy) | POST | None | None | **PUBLIC EXPOSED** | **CRITICAL: SSRF & Credential Leak** |
| `/api/eligibility/{phoneNumber}` | GET | None | None | **PUBLIC EXPOSED** | **CRITICAL: IDOR Data Leak** |
| `/api/conversation` (Legacy) | POST | None | None | Public Exposed | **LEGACY: Unauthenticated Chat** |
| `/api/schemes/all` (Legacy) | GET | None | None | Public Exposed | Read-only public schemes |
| `/api/users/register` (Legacy) | POST | Spring Security | Denied (403) | Protected by default | Blocked by `.anyRequest().authenticated()` |
| `/api/profile/save` (Legacy) | POST | Spring Security | Denied (403) | Protected by default | Blocked by `.anyRequest().authenticated()` |

---

## 10. Database Security Assessment

- **Schema Isolation**: Flyway migrations strictly specify `yojna_setu.<table_name>`. The `CREATE SCHEMA IF NOT EXISTS yojna_setu;` statement ensures non-interference with Supabase's `public`, `auth`, or other microservices.
- **Row Level Security**:
  ```
  RLS NOT IMPLEMENTED
  ```
  PostgreSQL RLS (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`) is **NOT** present in `V1__init_yojna_setu_schema.sql` or `V2__seed_normalized_schemes.sql`. All authorization is currently enforced exclusively at the Spring Boot application tier.
- **Destructive Startup Initialization**: Completely neutralized. `DELETE FROM schemes;` was purged from startup flows. Flyway handles all transactional migrations.
- **Data Types & Normalization**:
  - Financial values use `NUMERIC(15,2)`.
  - Age values use `SMALLINT` with check constraints `[0, 130]`.
  - Multi-valued attributes (castes, genders, occupations) are decomposed into 1NF child junction tables (`scheme_castes`, `scheme_genders`, `scheme_occupations`).
- **SQL Injection Resistance**: All repository queries use Spring Data JPA derived queries or parameterized JPQL (`@Param`). Zero dynamic string concatenation was detected.

---

## 11. AI Security Assessment

- **Authority over Eligibility**:
  ```
  AI IS NEVER THE AUTHORITY FOR ELIGIBILITY.
  ```
  Final scheme qualifications are evaluated 100% deterministically by `EligibilityEngine.java` using exact Enum matches and mathematical thresholds.
- **Prompt Injection Defense**:
  - `GroqAiGateway.java` encapsulates user input within `<user_input>` XML tags with explicit instructions forbidding delimiter escape.
- **Schema Strictness**: Jackson record parsing validates Groq responses into `ExtractedDemographicsRecord`.
- **Operational Reality**: As noted in finding `MED-01`, `GroqAiGateway.extractDemographics` is currently bypassed by the conversation orchestrator in favor of regex heuristics.

---

## 12. WhatsApp Security Assessment

- **Signature Verification**: `TwilioWebhookController.java` integrates `com.twilio.security.RequestValidator` checking `X-Twilio-Signature` against the complete URL and form payload.
- **Live Verification Status**:
  ```
  Live Twilio verification NOT VERIFIED.
  ```
  Twilio signature tests in the automated suite execute under `app.env=local`, which bypasses the validator. No live webhook transaction with Twilio's cloud infrastructure was executed during this audit.
- **Idempotency**: Webhooks are deduplicated via `webhook_events.provider_message_id`. Replays return an immediate `200 OK` empty `<Response></Response>`.

---

## 13. Privacy Assessment (DPDPA 2023)

| DPDPA Principle | Implementation Status | Evidence / Observation |
| :--- | :---: | :--- |
| **Blind Indexing** | **IMPLEMENTED** | `users.phone_number_hash` stores `SHA-256(phone + pepper)`. Queries execute against hashes. |
| **Right to Erasure** | **IMPLEMENTED** | Sending `reset` in state machine wipes demographic attributes in `user_profiles` and resets session state. |
| **Log Masking** | **PARTIALLY IMPLEMENTED** | `PiiMaskingConverter` masks phone numbers in log messages, but does not intercept exception stack traces. |
| **Consent Logging** | **DOCUMENTED ONLY** | Documented in `PRIVACY.md`, but no discrete database table tracks timestamps of user consent acceptance. |
| **Data Minimization** | **IMPLEMENTED** | Session stores only minimal necessary state. Raw audio files are processed in ephemeral memory. |

---

## 14. Test Quality Assessment

All 17 tests were individually audited:

| Test Class | Method Name | Type | Assertion Quality | Vulnerability / Gap |
| :--- | :--- | :---: | :--- | :--- |
| `AdminSchemeSecurityTest` | `shouldRejectRequestWithoutApiKey` | Integration | High (checks 401 & body) | None |
| `AdminSchemeSecurityTest` | `shouldRejectRequestWithInvalidApiKey` | Integration | High (checks 401) | None |
| `AdminSchemeSecurityTest` | `shouldAllowRequestWithValidApiKey` | Integration | High (checks 200 & data) | None |
| `AdminSchemeSecurityTest` | `shouldAllowAuditLogsWithValidApiKey` | Integration | High (checks 200) | None |
| `TwilioWebhookControllerTest` | `shouldRejectMissingFrom` | Integration | High (checks 400) | None |
| `TwilioWebhookControllerTest` | `shouldHandleDuplicateMessageSidIdempotently` | Integration | High (verifies DB idempotency) | `app.env=local` bypasses signature check |
| `ConversationOrchestratorTest` | `testInitStatePromptsLanguage` | Integration | Medium (checks response text) | Uses H2 in-memory DB |
| `ConversationOrchestratorTest` | `testLanguageSelectionTransitionsToCollectingProfile` | Integration | High (verifies state change) | Uses H2 in-memory DB |
| `ConversationOrchestratorTest` | `testResetCommandClearsSessionAndProfile` | Integration | High (verifies data wiping) | Uses H2 in-memory DB |
| `ConversationOrchestratorTest` | `testHelpCommandReturnsInstructions` | Integration | Medium (checks reply text) | Uses H2 in-memory DB |
| `EligibilityEngineTest` | `testAgeEligibility_WithinRange` | Unit | High (boundary assertion) | Unit mock scheme |
| `EligibilityEngineTest` | `testAgeEligibility_OutOfRange` | Unit | High (boundary assertion) | Unit mock scheme |
| `EligibilityEngineTest` | `testGenderEligibility_StrictMatch_FemaleDoesNotMatchMale` | Unit | High (proves substring bug fixed) | Unit mock scheme |
| `EligibilityEngineTest` | `testGenderEligibility_AllMatchesAny` | Unit | High (asserts enum ALL) | Unit mock scheme |
| `EligibilityEngineTest` | `testIncomeEligibility_BelowMaxIncome` | Unit | High (numeric comparison) | Unit mock scheme |
| `EligibilityEngineTest` | `testIncomeEligibility_AboveMaxIncome` | Unit | High (numeric comparison) | Unit mock scheme |
| `YojnaSetuApplicationTests` | `contextLoads` | Integration | Smoke test (Spring context) | None |

### Missing Automated Tests:
1. **Invalid Twilio Signature Rejection** under `app.env=production`.
2. **Bucket4j Rate Limit Exhaustion** (asserting HTTP 429 after 20 rapid requests).
3. **SSRF Rejection** of `https://attacker-twilio.com` or private IP ranges.
4. **End-to-End Demographics Extraction** via Groq JSON response parsing.
5. **Scheme Creation and Status Toggle** (`POST /api/v1/admin/schemes`).

---

## 15. Deployment Assessment

- **Dockerfile**:
  - Multi-stage build with Eclipse Temurin 21 Jammy.
  - Drops privileges to system user `yojnasetu:yojnasetu` (UID 10001).
  - Uses `dumb-init` for PID 1 process management and signal forwarding.
  - G1GC memory flags configured (`-XX:MaxRAMPercentage=75.0`).
- **docker-compose.yml**:
  - Correctly defines service dependency on PostgreSQL healthcheck.
  - Development password `postgres_dev_password` is provided as default fallback.
- **setup-server.sh**:
  - Legacy shell script contains outdated reference to `mysql.service`.

---

## 16. Documentation Consistency Matrix

| Claim | Source Document | Actual Repository Evidence | Status |
| :--- | :--- | :--- | :---: |
| "82 Schemes Normalized" | `README.md`, `PORTFOLIO.md` | Exactly 82 schemes in `data.sql` and `V2__seed_normalized_schemes.sql`. | **VERIFIED** |
| "FEMALE.contains(MALE) bug fixed" | `ADR-004`, `PORTFOLIO.md` | Exact Enum matching in `EligibilityEngine.java` line 67. | **VERIFIED** |
| "Zero Secrets in Repo" | `ADR-001`, `SECURITY.md` | Zero active secrets in working tree; legacy password remains in Git log. | **PARTIALLY VERIFIED** |
| "DPDPA 2023 Compliant" | `PRIVACY.md`, `README.md` | Blind phone hashing implemented; consent logging & stack trace masking incomplete. | **PARTIALLY VERIFIED** |
| "Twilio Webhook Security" | `WHATSAPP.md` | `RequestValidator` implemented in V2; legacy unauthenticated webhook controller still present. | **PARTIALLY VERIFIED** |
| "AI Demographics Extraction" | `ARCHITECTURE.md` | Code exists in `GroqAiGateway`, but orchestrator uses regex heuristics. | **CONTRADICTED** |
| "Supabase Production Deployment" | `DEPLOYMENT.md` | Code targets Supabase schema, but tests run exclusively on H2. | **NOT VERIFIED** |

---

## 17. Portfolio Claim Matrix (Guidance for SHIVSASTRA)

### ✅ SAFE TO CLAIM:
1. **"Engineered a Deterministic Government Welfare Eligibility Engine in Java 21 & Spring Boot 3.2"**.
2. **"Tokenized and normalized 82 Central and State welfare schemes from legacy CSV text into a 1NF relational PostgreSQL model"**.
3. **"Fixed critical algorithmic flaws (e.g. 'FEMALE'.contains('MALE') substring match) using type-safe Domain Enums"**.
4. **"Engineered SHA-256 blind indexing with cryptographic salt for Indian citizen mobile number privacy"**.
5. **"Architected a Dual-Channel Provider Pattern allowing seamless switching between Twilio WhatsApp and an interactive in-browser emulator"**.
6. **"17/17 automated unit and integration tests passing across deterministic rules, security filters, and state machine lifecycles"**.

### ⚠️ CLAIM ONLY WITH QUALIFIER:
1. **"DPDPA 2023 Compliant"** → *Qualify as*: "Designed in alignment with DPDPA 2023 data minimization and blind phone indexing principles".
2. **"Twilio Webhook Integration"** → *Qualify as*: "Implemented Twilio HMAC-SHA1 signature verification and durable idempotency (verified in local integration tests)".
3. **"AI-Powered Voice & Text Assistant"** → *Qualify as*: "Engineered Groq Llama 3.1 and Whisper Large V3 abstraction layer with XML prompt injection defense".

### ❌ DO NOT CLAIM (UNTIL FIXED):
1. **"Fully Production-Ready and Audited"** (Until legacy controllers are removed and Git history is scrubbed).
2. **"Live Supabase Production Deployment"** (Until deployed and verified on live Supabase instance).
3. **"PostgreSQL Row Level Security Enabled"** (RLS is NOT implemented).

---

## 18. Remaining Risks

1. **Accidental Exposure of Legacy Controllers**: If deployed without deleting `WhatsAppWebhookController.java` and `EligibilityController.java`, an attacker can extract Twilio credentials and scrape citizen profiles.
2. **SSRF Host Bypass**: Attackers can spoof media URLs using unregistered domains ending in `twilio.com`.
3. **Cluster Inconsistency**: Running multiple container instances without Redis will bypass process-local Bucket4j rate limits.
4. **Public Exposure of Git History**: Pushing the current `.git` directory to a public repository will leak historical credentials.

---

## 19. Exact Required Fixes (Pre-Production Checklist)

1. **Delete Legacy Controllers & Services**:
   - Delete `src/main/java/com/yojnasetu/controller/WhatsAppWebhookController.java`.
   - Delete `src/main/java/com/yojnasetu/controller/EligibilityController.java`.
   - Delete `src/main/java/com/yojnasetu/controller/UserController.java`.
   - Delete `src/main/java/com/yojnasetu/controller/UserProfileController.java`.
   - Delete `src/main/java/com/yojnasetu/controller/GroqController.java`.
   - Delete `src/main/java/com/yojnasetu/service/GroqService.java`.
   - Delete `src/main/java/com/yojnasetu/service/ConversationService.java`.
2. **Harden SSRF Domain Matcher**:
   - In `TwilioWebhookController.java`, change `!host.endsWith("twilio.com")` to:
     ```java
     if (host == null || (!host.equals("api.twilio.com") && !host.endsWith(".twilio.com")))
     ```
3. **Clean Git History**:
   - Run `git filter-repo --invert-paths --path start-app.sh` or scrub the password string from all commits before publishing to GitHub.
4. **Wire Groq AI into Orchestrator**:
   - In `ProfileCollectionHandler.java`, call `aiGateway.extractDemographics(message.text())` when multi-attribute text is received to enable true 1-shot natural language profile population.
5. **Add Production Security Tests**:
   - Add integration tests asserting 403 on invalid Twilio signatures with `app.env=production`.
   - Add tests asserting 429 on rate limit exhaustion.

---

## 20. What Was NOT Verified

1. **Live Supabase PostgreSQL Database**: NOT VERIFIED (Tests executed exclusively on H2).
2. **Live Twilio Cloud Telephony & Webhooks**: NOT VERIFIED (Bypassed via `DemoChannelProvider` and `app.env=local`).
3. **Live Groq Cloud API**: NOT VERIFIED (No real network calls to `api.groq.com` during testing).
4. **PostgreSQL RLS Policies**: NOT IMPLEMENTED / NOT VERIFIED.
5. **Distributed Multi-Node Rate Limiting**: NOT IMPLEMENTED / NOT VERIFIED.

---

## 21. Final Evidence Summary

```
================================================================================
FINAL AUDIT VERIFICATION SUMMARY
================================================================================
AUDIT STATUS:                     PASS WITH FINDINGS
EXECUTIVE VERDICT:                PRODUCTION READY WITH CONDITIONS
ACTUAL SCHEME COUNT:              82 (63 Central, 11 State, 8 Private)
ACTUAL TEST COUNT:                17 Tests Run, 17 Passed, 0 Failures
PRODUCTION VERIFICATION LEVEL:    LOCAL UNIT & INTEGRATION TESTED ONLY
SUPABASE TESTED:                  NO (H2 In-Memory PostgreSQL Compatibility Mode)
LIVE TWILIO TESTED:               NO (Synthetically mocked / local bypass)
LIVE GROQ TESTED:                 NO (Offline unit fixtures)
ROW LEVEL SECURITY (RLS):         RLS NOT IMPLEMENTED (Application tier security only)
SECRETS IN ACTIVE CODE:           0 (All active code sanitized)
SECRETS IN GIT HISTORY:           YES (Historical password in early commit blobs)
CRITICAL/HIGH VULNERABILITIES:    4 (Remnant legacy controllers, IDOR, SSRF host match, Git log)
================================================================================
```
