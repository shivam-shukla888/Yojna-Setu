# YOJNA SETU V2 — DATABASE SPECIFICATION
**Document:** `docs/v2/DATABASE.md`  
**Version:** 2.0.0  
**Target Persistence:** Supabase PostgreSQL (Project #2)  
**Schema:** `yojna_setu`  
**Migration Engine:** Flyway  
**Status:** APPROVED (PHASE 3 SPECIFICATION)  

---

## 1. Architectural Strategy & Multi-Tenant Isolation

Yojna Setu V2 is hosted within **Supabase PostgreSQL (Project #2)**, a shared enterprise cluster that also hosts sibling projects:
- `yojna_setu` (This project)
- `whatsapp_agent` (Sibling application)
- `myca` (Sibling application)

### 1.1 Non-Negotiable Isolation Rules
1. **Zero Contamination of `public` Schema:** Yojna Setu V2 operates strictly within the `yojna_setu` namespace. No tables, views, sequences, or functions may be created in the `public` schema.
2. **Search Path Pinned:** Application connection pools (HikariCP) enforce connection initialization:
   ```sql
   SET search_path TO yojna_setu, public;
   ```
3. **Dedicated User Role & Grants:** Application database credentials are granted permissions exclusively on `yojna_setu.*`.
4. **Isolated Flyway Tracking:** Schema version history is tracked inside `yojna_setu.flyway_schema_history`.

---

## 2. Relational Entity-Relationship Diagram

```
+-----------------------------------+            +-----------------------------------------+
|        yojna_setu.users           |            |       yojna_setu.user_profiles          |
+-----------------------------------+            +-----------------------------------------+
| id (PK, UUID)                     | 1        1 | id (PK, UUID)                           |
| phone_number_e164 (VARCHAR)       |<---------->| user_id (FK -> users.id, UNIQUE)        |
| phone_number_hash (VARCHAR, UK)   |            | age (SMALLINT)                          |
| preferred_language (VARCHAR)      |            | gender (gender_type ENUM)               |
| is_active (BOOLEAN)               |            | state (VARCHAR)                         |
| created_at, updated_at            |            | district (VARCHAR)                      |
+-----------------------------------+            | caste (caste_type ENUM)                 |
                  | 1                            | annual_income (NUMERIC(15,2))           |
                  |                              | occupation (VARCHAR)                    |
                  v 1                            | religion (VARCHAR)                      |
+-----------------------------------+            | marital_status (marital_status_type)    |
|   yojna_setu.conversation_sessions|            | is_differently_abled (BOOLEAN)          |
+-----------------------------------+            | education_level (VARCHAR)               |
| id (PK, UUID)                     |            | is_profile_complete (BOOLEAN)           |
| user_id (FK -> users.id, UNIQUE)  |            | created_at, updated_at                  |
| current_state (session_state_type)|            +-----------------------------------------+
| last_prompt_sent (VARCHAR)        |
| pagination_offset (INT)           |
| cached_eligible_schemes (JSONB)   |
| session_data (JSONB)              |
| last_interaction_at (TIMESTAMPTZ) |
+-----------------------------------+

+-----------------------------------+
|        yojna_setu.schemes         |
+-----------------------------------+
| id (PK, UUID)                     |
| code (VARCHAR, UK)                |
| name (VARCHAR)                    |
| ministry (VARCHAR)                |
| category (scheme_category_type)   |
| short_description (TEXT)          |
| benefits (TEXT)                   |
| application_mode (app_mode_type)  |
| application_process (TEXT)        |
| official_url (VARCHAR)            |
| min_age, max_age (SMALLINT)       |
| max_income (NUMERIC(15,2))        |
| requires_disability (BOOLEAN)     |
| target_state (VARCHAR)            |
| start_date, end_date (DATE)       |
| is_active (BOOLEAN)               |
| created_at, updated_at            |
+-----------------------------------+
          | 1             | 1            | 1            | 1            | 1
          v N             v N            v N            v N            v N
   +--------------+ +--------------+ +-------------+ +-------------+ +--------------------+
   |scheme_castes | |scheme_genders| |scheme_occup | |scheme_relig | |scheme_documents    |
   +--------------+ +--------------+ +-------------+ +-------------+ +--------------------+
   |scheme_id (FK)| |scheme_id (FK)| |scheme_id(FK)| |scheme_id(FK)| |id (PK, UUID)       |
   |caste (ENUM)  | |gender (ENUM) | |occupation   | |religion     | |scheme_id (FK)      |
   +--------------+ +--------------+ +-------------+ +-------------+ |document_name (TEXT)|
                                                                     |is_mandatory (BOOL) |
                                                                     +--------------------+
```

---

## 3. Data Dictionary

### 3.1 Custom Types (`pg_type` in `yojna_setu`)
- `gender_type`: `'MALE'`, `'FEMALE'`, `'TRANSGENDER'`, `'ALL'`
- `caste_type`: `'GENERAL'`, `'OBC'`, `'SC'`, `'ST'`, `'EWS'`, `'ALL'`
- `marital_status_type`: `'SINGLE'`, `'MARRIED'`, `'DIVORCED'`, `'WIDOWED'`, `'ALL'`
- `scheme_category_type`: `'CENTRAL_GOVERNMENT'`, `'STATE_GOVERNMENT'`, `'PRIVATE'`
- `application_mode_type`: `'ONLINE'`, `'OFFLINE'`, `'BOTH'`
- `session_state_type`: `'INIT'`, `'LANGUAGE_SELECTION'`, `'PROFILE_COLLECTION'`, `'PROFILE_REVIEW'`, `'SCHEMES_LIST'`, `'SCHEME_DETAILS'`, `'DOCUMENT_CHECKLIST'`, `'APPLICATION_GUIDE'`, `'HELP'`, `'HUMAN_HANDOFF'`

### 3.2 Core Identity & Demographics
- **`users`**:
  - `id` (UUID): Primary key, generated via `gen_random_uuid()`.
  - `phone_number_e164` (VARCHAR(20)): Formatted phone number (`+919876543210`).
  - `phone_number_hash` (VARCHAR(64)): HMAC-SHA256 blind index hash for `O(1)` encrypted search without exposing raw phone numbers.
  - `preferred_language` (VARCHAR(10)): `hi`, `en`, or `hinglish`.
- **`user_profiles`**:
  - `user_id` (UUID): One-to-one foreign key with cascade delete.
  - `age` (SMALLINT): Checked between 0 and 130.
  - `annual_income` (NUMERIC(15,2)): Precise monetary representation replacing legacy IEEE floating-point `Double`.
  - `is_differently_abled` (BOOLEAN): Flag for disability-specific scheme eligibility.

### 3.3 Schemes & 1NF Normalization
- **`schemes`**:
  - `code` (VARCHAR(100)): Stable natural key for idempotent migration (e.g. `PM-KISAN`, `AYUSHMAN-BHARAT`).
  - `category` (`scheme_category_type`): Distinguishes Central Government, State Government, and Private Initiatives.
  - `target_state` (VARCHAR(100)): Specific state name (e.g. `Uttar Pradesh`) or `ALL` for pan-India schemes.
- **Relational Junction Tables:**
  - `scheme_castes`: Eliminates comma-delimited strings (`applicable_caste`).
  - `scheme_genders`: Eliminates substring matching (`"FEMALE".contains("MALE")`).
  - `scheme_occupations`: Maps supported professions (`FARMER`, `STUDENT`, `BUSINESS`, `OTHER`).
  - `scheme_religions`: Maps minority designations (`MUSLIM`, `CHRISTIAN`, `SIKH`, `BUDDHIST`, `JAIN`, `ALL`).
  - `scheme_documents`: Itemized required verification artifacts (`Aadhaar Card`, `Bank Passbook`, `Khasra/Khatauni Land Record`).

### 3.4 Conversation State & Infrastructure
- **`conversation_sessions`**:
  - `current_state` (`session_state_type`): Active position in conversational finite state machine.
  - `cached_eligible_schemes` (JSONB): Array of matched Scheme UUIDs, enabling restart-safe, stateless horizontal pagination without repeated database recalculation.
  - `last_interaction_at` (TIMESTAMPTZ): Allows automatic expiration of stale sessions.
- **`webhook_events`**:
  - Durable idempotency store preventing duplicate webhook execution.
  - `provider_message_id` (VARCHAR UNIQUE): Twilio `MessageSid` or Meta `wamid`.
- **`audit_events`**:
  - Immutable record of demographic updates, administrative modifications, and security events.

---

## 4. Indexing & Query Optimization Strategy

| Index Name | Table | Columns | Purpose |
|---|---|---|---|
| `idx_users_phone_hash` | `users` | `phone_number_hash` | O(1) citizen lookup on inbound webhook |
| `idx_user_profiles_demographics` | `user_profiles` | `state, caste, gender, annual_income` | Composite filter index |
| `idx_schemes_matching` | `schemes` | `is_active, target_state, min_age, max_age, max_income` | High-speed eligibility pre-filter query |
| `idx_scheme_castes_lookup` | `scheme_castes` | `caste` | Join optimization |
| `idx_scheme_genders_lookup` | `scheme_genders` | `gender` | Join optimization |
| `idx_webhook_events_msgid` | `webhook_events` | `provider_message_id` | Unique index for atomic idempotency insertion |
| `idx_conversation_sessions_user` | `conversation_sessions` | `user_id` | Fast session retrieval on message receipt |

---

## 5. Migration Execution Pipeline (Flyway)

Migrations are tracked and applied chronologically via Spring Boot Flyway integration:
- `V1__init_yojna_setu_schema.sql`: Instantiates schema, custom enums, 10 normalized tables, check constraints, and B-tree indexes.
- `V2__seed_normalized_schemes.sql`: Idempotently populates all 82 schemes along with their normalized junction records.
