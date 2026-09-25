# YOJNA SETU V2 — PHASE 0: FORENSIC REPOSITORY ANALYSIS
**Document:** `docs/v2/LEGACY_ANALYSIS.md`  
**Date:** 2026-09-25  
**Auditor / Role:** Principal Software Architect, Application Security Engineer & Database Architect  
**Status:** COMPLETE (PHASE 0 STOPPING POINT)  
**Classification:** STRICT AUDIT & MIGRATION SOURCE ASSESSMENT  

---

## 1. Current Architecture

The legacy Yojna Setu application is an early-stage prototype built as a monolithic Spring Boot web service running embedded Apache Tomcat on Java 21.

### 1.1 Architectural Pattern
- **Pattern:** Layered Controller-Service-Repository monolith.
- **State Handling:** State is hybrid and bifurcated:
  - Demographic fields are persisted to MySQL via Spring Data JPA across two tables (`users`, `user_profiles`).
  - Active session pagination counters (`shownCountMap`, `shownDocsCountMap`) are maintained in volatile, in-memory `ConcurrentHashMap` instances inside `ConversationService`.
- **Integration Topology:**
  - Inbound WhatsApp messages arrive via Twilio Webhooks hitting `POST /webhook/whatsapp`.
  - Outbound WhatsApp messages are sent synchronously via the official Twilio Java SDK (`com.twilio.sdk:twilio:9.3.0`).
  - Natural language extraction and voice transcription are invoked synchronously against the Groq Cloud API (`https://api.groq.com/openai/v1`) using Spring WebFlux `WebClient`.
- **Database Coupling:** MySQL 8.x with Hibernate auto-schema creation (`ddl-auto=update`) and raw SQL startup execution (`spring.sql.init.mode=always` pointing to `data.sql`).

```
                    [ Citizen on WhatsApp ]
                               |
                               v
                       [ Twilio Gateway ]
                               | (HTTP POST Webhook)
                               v
               [ WhatsAppWebhookController ]
                               |
                               v
                   [ ConversationService ] <----+ (In-Memory Maps: shownCountMap)
                  /          |           \
                 v           v            v
        [ GroqService ]  [ EligibilitySvc ]  [ TwilioService ]
        (LLM / Whisper)   (Iterates DB)       (Sends Message)
                 \           |            /
                  v          v           v
                       [ MySQL 8.x ]
                 (users, user_profiles, schemes)
```

---

## 2. Current Dependencies

Inspected from `pom.xml`:
- **Parent:** `org.springframework.boot:spring-boot-starter-parent:3.2.12`
- **Java Version:** 21

### 2.1 Dependency Inventory
| Dependency Coordinates | Scope | Actual Role in Legacy App | Assessment |
|---|---|---|---|
| `org.springframework.boot:spring-boot-starter-data-jpa` | Compile | Hibernate 6.4 ORM, HikariCP pool | Used for 3 entities; utilizes risky `ddl-auto=update` |
| `org.springframework.boot:spring-boot-starter-web` | Compile | Embedded Tomcat, Spring MVC REST | Core HTTP server; missing validation annotations |
| `org.springframework.boot:spring-boot-starter-webflux` | Compile | Reactive WebClient | Heavy artifact included *only* for WebClient calls in `GroqService` |
| `com.mysql:mysql-connector-j` | Runtime | MySQL JDBC Driver | Target for legacy MySQL database |
| `com.twilio.sdk:twilio:9.3.0` | Compile | Twilio Java SDK | Legacy version (current is 10.x); lacks webhook validation integration |
| `org.springframework.boot:spring-boot-starter-test` | Test | JUnit 5, Mockito, AssertJ | Only runs a single empty `contextLoads()` test |

### 2.2 Critical Dependency Deficiencies
1. **Missing Spring Security (`spring-boot-starter-security`):** No authentication, authorization, CSRF, or CORS infrastructure.
2. **Missing Validation (`spring-boot-starter-validation`):** No Jakarta Bean Validation annotations (`@NotNull`, `@Size`, `@Pattern`) in DTOs.
3. **Missing Flyway / Liquibase:** Schema lifecycle is unversioned.
4. **Missing Production Observability (`spring-boot-starter-actuator`):** No health checks, metrics, or liveness probes.
5. **Misconfigured Lombok Plugin:** `pom.xml` excludes `org.projectlombok:lombok` from the `spring-boot-maven-plugin`, but Lombok is not in `<dependencies>`, leaving manual getter/setter boilerplate across entities.

---

## 3. Current API Endpoints

The legacy application exposes 9 REST endpoints across 7 controllers. **None are authenticated.**

| HTTP Verb | Path | Controller | Parameters | Security Status | Vulnerability / Issue |
|---|---|---|---|---|---|
| `POST` | `/webhook/whatsapp` | `WhatsAppWebhookController` | Form parameters: `From`, `Body`, `MediaUrl0`, `MediaContentType0` | **UNAUTHENTICATED** | No HMAC signature verification. Anyone can forge incoming messages. |
| `POST` | `/api/conversation/message` | `ConversationController` | JSON: `phone`, `message` | **UNAUTHENTICATED** | Allows direct message injection, bypassing Twilio. |
| `POST` | `/api/eligibility/check` | `EligibilityController` | JSON: `SaveProfileRequest` | **UNAUTHENTICATED** | Publicly accessible calculation engine with no rate limit. |
| `POST` | `/api/groq/extract` | `GroqController` | JSON: `message` | **UNAUTHENTICATED** | Public open proxy to Groq LLM API. Allows quota theft. |
| `GET` | `/api/health` | `HealthController` | None | Public | Returns static JSON `{"status": "UP"}`. |
| `GET` | `/api/schemes` | `SchemeController` | None | **UNAUTHENTICATED** | Returns entire database table in single array with no pagination. |
| `GET` | `/api/schemes/{id}` | `SchemeController` | Path variable: `id` | **UNAUTHENTICATED** | Direct lookup without rate limiting. |
| `GET` | `/api/users/{id}` | `UserController` | Path variable: `id` | **UNAUTHENTICATED** | IDOR vulnerability. Leaks citizen phone number and creation date. |
| `GET` | `/api/user-profiles/{userId}` | `UserProfileController` | Path variable: `userId` | **UNAUTHENTICATED** | IDOR vulnerability. Leaks full demographic data (caste, income, age, gender). |

---

## 4. Current Database Model

The database relies on 3 JPA entities mapped to MySQL:

### 4.1 Entities and Schema Definition
1. **`users` (`com.yojnasetu.model.User`)**
   - `id`: `BIGINT AUTO_INCREMENT` (Primary Key).
   - `phone_number`: `VARCHAR(255)` (Unique constraint declared, unindexed).
   - `name`: `VARCHAR(255)`.
   - `created_at`: `DATETIME` (Set via `@PrePersist`).
2. **`user_profiles` (`com.yojnasetu.model.UserProfile`)**
   - `id`: `BIGINT AUTO_INCREMENT` (Primary Key).
   - `user_id`: `BIGINT` (Foreign Key referencing `users(id)`, Unique).
   - Demographics: `age` (`Integer`), `gender` (`String`), `state` (`String`), `caste` (`String`), `income` (`Double`), `occupation` (`String`), `marital_status` (`String`), `disability` (`String`), `education` (`String`).
   - `is_profile_complete`: `Boolean`.
   - `created_at`, `updated_at`: `DATETIME`.
3. **`schemes` (`com.yojnasetu.model.Scheme`)**
   - `id`: `BIGINT AUTO_INCREMENT` (Primary Key).
   - `scheme_name`: `VARCHAR(255)`.
   - `description`, `benefits`, `required_documents`: `TEXT`.
   - `official_url`: `VARCHAR(255)`.
   - Eligibility Rules (Multi-valued comma-separated strings):
     - `applicable_caste`: e.g. `"SC,ST,OBC,General"`
     - `applicable_gender`: e.g. `"All"` or `"Female"`
     - `applicable_occupation`: e.g. `"Farmer,Student,Unemployed"`
     - `applicable_states`: e.g. `"All"` or `"Maharashtra,Uttar Pradesh"`
   - Numeric constraints: `min_age` (`Integer`), `max_age` (`Integer`), `max_income` (`Double`).

### 4.2 Key Relational Deficiencies
- **First Normal Form (1NF) Violation:** Storing comma-separated lists in `applicable_caste`, `applicable_gender`, `applicable_occupation`, and `applicable_states` prevents relational indexing and forces fragile string-matching in application memory.
- **Unbounded Strings:** Demographic fields (`caste`, `gender`, `occupation`) are arbitrary freeform strings without enum validation.
- **Float Precision Issues:** `Double` used for monetary `income` and `max_income`, leading to floating-point rounding errors.

---

## 5. Current WhatsApp Flow

```
Twilio WhatsApp Inbound
         |
         v
[ WhatsAppWebhookController: handleIncomingMessage() ]
         |
         +--> 1. Extracts "From" and "Body". Strips "whatsapp:" prefix.
         |
         +--> 2. Checks "MediaContentType0" / "MediaUrl0".
         |         If audio:
         |           - Logs media URL to console.
         |           - Downloads audio bytes via WebClient.
         |           - Sends bytes to Groq Whisper (`whisper-large-v3-turbo`).
         |           - Sets message text to transcribed string.
         |
         +--> 3. Invokes ConversationService.processMessage(phone, text).
         |
         +--> 4. Invokes TwilioService.sendWhatsAppMessage(to, replyText).
                   (Synchronous API call with Twilio credentials)
```

### 5.1 Flaws in WhatsApp Flow
- **No Signature Verification:** The controller ignores `X-Twilio-Signature`.
- **No Idempotency:** Twilio retries will trigger duplicate message processing and duplicate replies.
- **SSRF Risk:** Media downloads fetch URLs from `MediaUrl0` directly into memory without IP or host validation.
- **Synchronous Blocking:** The entire flow (Whisper transcription -> LLM extraction -> DB lookup -> Twilio send) executes synchronously on the Tomcat request thread.

---

## 6. Current AI Flow

Orchestrated by `GroqService.java`:
- **Provider:** Groq Cloud API (`https://api.groq.com/openai/v1`).
- **Models Used:**
  - NLP Entity Extraction: `llama-3.1-8b-instant`
  - Voice Transcription: `whisper-large-v3-turbo`
- **Execution Mechanism:**
  - Assembles prompt with system instructions: `"You are an Indian government scheme assistant. Extract user information..."`
  - Appends raw `userMessage` without sanitization or boundary delimiters.
  - Requests JSON output.
  - Strips markdown code blocks via naive substring searching:
    ```java
    if (content.contains("```json")) {
        content = content.substring(content.indexOf("```json") + 7);
        content = content.substring(0, content.indexOf("```"));
    }
    ```
  - Parses JSON into a `Map<String, Object>` via Jackson `ObjectMapper`.

### 6.1 Flaws in AI Flow
- **Prompt Injection:** An attacker can inject instructions into the conversation to spoof demographic fields.
- **Brittle JSON Parsing:** If the model outputs ` ``` ` without `json` or intro text with backticks, substring operations crash with `StringIndexOutOfBoundsException`.
- **No Circuit Breaker:** No timeout or fallback mechanism exists if Groq is degraded.

---

## 7. Current Conversation Flow

Managed inside the monolithic `ConversationService.java` (489 SLOC):

```
User Message Received
         |
         v
Find or Create User & UserProfile
         |
         v
Is User Profile Complete?
  |                 |
  | YES             | NO
  v                 v
Check Keyword:     Groq Extracts Data from Message -> Saves to Profile
"more" -> Next 3   Is Profile NOW complete?
"hi"   -> Re-show    |              |
"docs" -> Req Docs   | YES          | NO
Other  -> General    v              v
          Query    Run Eligibility  Ask for next missing field:
                   Show Top 3       (Age -> Gender -> State -> Caste -> Income -> Occupation)
```

### 7.1 Critical Bugs & Failures
1. **Profile Overwrite Bug:** When an existing user with a complete profile sends *any* query, `GroqService.extractUserData()` is invoked against the text. Any extracted values immediately overwrite established database fields.
2. **Volatile Pagination:** The user's pagination offset is held in memory:
   ```java
   private final Map<String, Integer> shownCountMap = new ConcurrentHashMap<>();
   ```
   A service restart or deployment immediately breaks pagination.
3. **Rigid Turn-Taking:** The prompt logic asks for one demographic question at a time in a hardcoded sequence. Compound answers (e.g. `"I am a 25 year old male from Bihar"`) are partially extracted, but the sequence may redundantly ask for items already provided.

---

## 8. Current Deployment Model

Inspected from `setup-server.sh`, `start-app.sh`, and `yojna-setu.service`:
- **Target OS:** Ubuntu Linux on AWS EC2 (claims `t2.micro`).
- **Process Management:** Systemd service `yojna-setu.service` invoking `/home/ubuntu/start-app.sh`.
- **Startup Command (`start-app.sh`):**
  ```bash
  nohup java -jar target/yojna-setu-0.0.1-SNAPSHOT.jar \
    --spring.datasource.url=jdbc:mysql://localhost:3306/yojna_setu \
    --spring.datasource.username=root \
    --spring.datasource.password=[REDACTED_PASSWORD] \
    --twilio.account.sid=... \
    --twilio.auth.token=... \
    --twilio.whatsapp.from=... \
    --groq.api.key=... > app.log 2>&1 &
  ```
- **Flaws:**
  - Production database password `[REDACTED_PASSWORD]` hardcoded and committed.
  - Relies on local MySQL `root` user.
  - No heap memory bounds (`-Xmx` / `-Xms`) specified; JVM will easily exceed EC2 `t2.micro` 1GB RAM and get OOM-killed.
  - Log file `app.log` has no rotation policy.

---

## 9. Security Findings

| Finding ID | Severity | CWE / OWASP | Detailed Vulnerability | Evidence / Location |
|---|---|---|---|---|
| **SEC-01** | **CRITICAL** | CWE-798 / A07 | Plaintext database password committed to git | `start-app.sh` line 3 (`[REDACTED_PASSWORD]`) |
| **SEC-02** | **CRITICAL** | CWE-306 / A01 | Zero authentication/authorization on all 9 endpoints | All controllers lack `@PreAuthorize` or SecurityConfig |
| **SEC-03** | **CRITICAL** | CWE-352 / A01 | Missing Twilio webhook signature verification | `WhatsAppWebhookController.java` line 32 |
| **SEC-04** | **CRITICAL** | CWE-639 / A01 | Insecure Direct Object References (IDOR) leaking citizen PII | `UserController.java`, `UserProfileController.java` |
| **SEC-05** | **HIGH** | CWE-532 / A09 | Full unmasked phone numbers and message contents in logs | `WhatsAppWebhookController.java:35`, `TwilioService.java:38` |
| **SEC-06** | **HIGH** | CWE-400 / A05 | Uncontrolled memory consumption via unbounded maps | `ConversationService.java:35-36` |
| **SEC-07** | **HIGH** | CWE-918 / A10 | Server-Side Request Forgery (SSRF) via arbitrary media URL | `WhatsAppWebhookController.java:46` |
| **SEC-08** | **HIGH** | CWE-200 / A01 | Unauthenticated Groq proxy exposing LLM quota | `GroqController.java:27` |
| **SEC-09** | **MEDIUM** | CWE-776 / A08 | Unrestricted file download size for incoming audio | `WhatsAppWebhookController.java:49` |

---

## 10. Data-Quality Findings

1. **Destructive Initialization:** `src/main/resources/data.sql` begins with `DELETE FROM schemes;`. With `spring.sql.init.mode=always`, all scheme records are wiped on every application launch.
2. **README Scheme Count Discrepancy:**
   - README claims: **"82+ Central & State Schemes"**.
   - Actual count in `data.sql`: **Exactly 62 schemes** (55 Central + 7 State-specific). The claim in README is **FALSE / UNVERIFIED**.
3. **Gender Substring Collision Bug:** In `Scheme.java`:
   ```java
   if (!applicableGender.toUpperCase().contains(userGender.toUpperCase())) return false;
   ```
   Because `"FEMALE".contains("MALE") == true`, male applicants falsely pass eligibility for female-only welfare schemes (e.g. Sukanya Samriddhi Yojana, Ladli Behna Yojana).
4. **State Substring Matching:** Case-sensitive string contains checks cause state matching failures (e.g. `"All"` vs `"all"`, `"Goa"` matching substrings in other words).
5. **Lack of Referential Integrity:** Schemes have no related tables; foreign keys are nonexistent; requirements, documents, and benefits are packed into text columns.

---

## 11. Technical Debt

1. **God Service Anti-Pattern:** `ConversationService` (489 lines) handles session routing, state storage, NLP delegation, prompt formatting, database operations, and eligibility matching.
2. **Domain-Model Logic Leakage:** `Scheme.java` entity directly contains procedural rule evaluation (`isEligible(UserProfile)`).
3. **In-Memory State Coupling:** Multi-pod horizontal scaling is impossible due to local `ConcurrentHashMap` pagination state.
4. **O(N) In-Memory Scheme Matching:** `EligibilityService` loads all schemes from the database on every check (`schemeRepository.findAll()`) and iterates through them in the JVM.
5. **Zero Test Coverage:** `YojnaSetuApplicationTests.java` contains an empty `contextLoads()` test. Real business logic coverage is **0.0%**.

---

## 12. Migration Considerations

1. **Database Platform Shift:** Migrating from local MySQL 8.x to **Supabase PostgreSQL Project #2** using the isolated `yojna_setu` schema.
2. **Schema Normalization (1NF):**
   - Comma-separated strings from `data.sql` must be tokenized into relational junction tables (`scheme_castes`, `scheme_genders`, `scheme_occupations`, `scheme_documents`).
   - Phone numbers must be normalized to E.164 and stored with a cryptographic hash (SHA-256) for privacy-safe lookups.
3. **Flyway Migration Strategy:** Replace Hibernate `ddl-auto=update` and raw `data.sql` with structured, repeatable Flyway scripts (`V1__schema.sql`, `V2__seed_schemes.sql`).
4. **State Machine Migration:** Replace in-memory maps with a persistent `conversation_sessions` table in PostgreSQL.

---

## 13. Valid Business Functionality to Preserve

The following core business capabilities are valuable and MUST be preserved in V2:
1. **WhatsApp-First Discovery:** Conversational discovery of government welfare schemes via natural messaging.
2. **Demographic Profile Collection:** Structured collection of citizen age, gender, state, caste, annual income, occupation, and disability status.
3. **Deterministic Eligibility Matching:** Rule-based matching against government scheme requirements (age limits, income ceilings, category eligibility, geographic restrictions).
4. **Explainability:** Providing the user with clear reasons why a scheme matched or what benefits it provides.
5. **Documentation Requirements & Application Guidance:** Presenting official required documents and direct government portal URLs.
6. **Hindi / Hinglish Comprehension:** Processing queries and replies in Hindi, English, and Hinglish.
7. **Voice Message Transcription:** Accepting voice notes and converting them to text via Whisper for accessibility.
8. **Curated Scheme Data:** The 62 schemes in `data.sql` represent authentic Indian welfare schemes (PM-KISAN, Ayushman Bharat, PMAY, etc.) and should be preserved in normalized form.

---

## 14. Functionality Intentionally Removed or Redesigned

| Legacy Component | Action in V2 | Justification |
|---|---|---|
| Plaintext password in `start-app.sh` | **REMOVED** | Severe security vulnerability; replaced with environment variables |
| `DELETE FROM schemes;` in `data.sql` | **REMOVED** | Destroys data on startup; replaced with idempotent Flyway migrations |
| In-memory `shownCountMap` | **REMOVED** | Volatile, state-leaking; replaced with persistent `conversation_sessions` |
| Comma-separated columns in `schemes` | **REMOVED** | 1NF violation; replaced with normalized junction tables |
| Unauthenticated public REST APIs | **REMOVED** | Public IDOR & proxy risks; secured via API key / auth guards |
| Substring `"FEMALE".contains("MALE")` | **REMOVED** | Critical eligibility bug; replaced with exact ENUM matching |
| Direct profile overwrite on user message | **REMOVED** | Corrupts citizen profiles; replaced with intent classification |
| In-memory `findAll()` scheme iteration | **REMOVED** | O(N) JVM memory bloat; replaced with indexed PostgreSQL SQL query |
| Unvalidated SSRF media download | **REMOVED** | SSRF risk; replaced with host-whitelisted, size-bounded stream validation |

---

## 15. Unknowns Requiring Verification

1. **Twilio Account Status:** Are production Twilio credentials active with an approved WhatsApp Business Profile and template approval, or is this running under Twilio Sandbox?
2. **Supabase Project #2 Credentials:** Exact PostgreSQL connection parameters (`host`, `port`, `database`, `user`, `password`, `sslmode`) for Supabase Project #2.
3. **Live Voice Codecs:** What specific audio codecs does Twilio WhatsApp deliver (OGG OPUS, AMR, AAC), and does the Whisper endpoint require transcoding?
4. **Target Scheme Volume:** Expected production volume of government schemes (62 initial seed schemes vs target of hundreds/thousands).

---

## 16. Conclusion & Phase 0 Deliverable Sign-Off

The legacy codebase has been forensically analyzed. The critical vulnerabilities, architectural anti-patterns, relational flaws, and valid business value have been cataloged.

**Current Phase:** PHASE 0 COMPLETE.  
**Next Required Phase:** PHASE 1 — V2 Architecture + ADRs + Threat Model.  
**Execution Hold:** Stopping here as instructed by the Phase Execution Model.
