# Yojna Setu V2 — Engineering Portfolio Case Study (SHIVSASTRA)

## Executive Summary

**Project**: Yojna Setu V2 (Government Scheme Discovery & Eligibility Assistant)  
**Role**: Principal Software Architect & Full-Stack Security Engineer  
**Core Stack**: Java 21, Spring Boot 3.2, Supabase (PostgreSQL 17), Groq (GPT-OSS-20B & Whisper Large V3 Turbo), Twilio WhatsApp API, Flyway, Bucket4j, Docker  

Millions of Indian citizens fail to access entitled government welfare schemes due to complex bureaucratic documentation, language barriers, and fragmented portals. **Yojna Setu** was conceived as an accessible WhatsApp-first conversational assistant to bridge this gap.

However, an initial forensic audit of the legacy repository revealed severe architectural flaws, security risks, and broken business logic. This project represents a complete, ground-up **Production Engineering Rebuild (V2)**, transforming a fragile prototype into a resilient, secure, and compliant public-sector platform.

---

## 1. Forensic Audit: Legacy V1 vs. Rebuilt V2

| Dimension | Legacy V1 (Prototype) | Yojna Setu V2 (Enterprise Production) |
| :--- | :--- | :--- |
| **Credential Security** | Plaintext database password (`[REDACTED_PASSWORD]`) committed in `start-app.sh` and shell scripts. | Zero secrets in repo. Full environment-driven configuration with strict validation and `.env.example`. |
| **Data Integrity** | Destructive startup script (`DELETE FROM schemes;`) wiping production data on every restart. | Controlled, zero-downtime Flyway migrations on Supabase schema `yojna_setu`. |
| **Database Normalization** | Denormalized, comma-separated string columns (`castes`, `genders`, `occupations`). | **1NF Relational Model** with dedicated junction tables and indexed foreign keys on PostgreSQL 17. |
| **Eligibility Logic** | Severe string bug: `scheme.getGender().contains("MALE")` returned true for `"FEMALE"`. | **Strict Enum-based Deterministic Engine** (`EligibilityEngine`) with 100% test coverage. |
| **AI Boundary** | LLM hallucinated eligibility; raw user strings concatenated into prompts. | **Hybrid Boundary**: LLM strictly extracts demographics with XML delimiter prompt defense; Java engine computes eligibility deterministically. |
| **API Security** | Unauthenticated public endpoints with IDOR vulnerabilities (`/api/users/{id}`). | Stateless Spring Security with `X-API-KEY` admin filters, HMAC-SHA1 Twilio validation, SSRF-safe media pipeline, and rate limiting. |
| **Privacy Compliance** | Plaintext phone numbers stored and printed in system logs. | **DPDPA 2023 Compliant**: SHA-256 blind phone indexing with salt/pepper; Logback PII masking converter. |
| **Concurrency & State** | In-memory `ConcurrentHashMap` causing state leaks and memory leaks across server restarts. | Transactional, database-backed finite state machine (`ConversationSession`) with session timeout recovery. |
| **Deduplication** | Webhook retries caused duplicate responses and corrupt state. | **Two-Tier Idempotency**: Fast memory cache + durable `webhook_events` DB constraint. |
| **Channels** | Hard-locked to Twilio; impossible to demo without live phone line and paid credits. | **Provider Abstraction Pattern**: Seamless toggle between Twilio WhatsApp and an interactive Browser Web Demo. |

---

## 2. Key Architectural Highlights

### 2.1 Deterministic Hybrid AI Architecture
LLMs should never make authoritative decisions regarding government benefits. In Yojna Setu V2:
- **Groq Cloud AI (GPT-OSS-20B)** handles natural language understanding, multilingual comprehension (Hindi, Hinglish, English), and fuzzy demographic extraction.
- **Groq Whisper Large V3 Turbo** transcribes multi-lingual citizen voice notes with safe SSRF-guarded media retrieval.
- **Java Deterministic Engine** enforces scheme rules (age brackets, income ceilings, state residency, social categories) using exact mathematical logic.
- **Fail-Safe Fallbacks**: If Groq is unavailable or times out (>5s), the state machine degrades gracefully to structured numeric menus.

### 2.2 Relational 1NF Migration of 82 Schemes
All 82 central and state schemes from the legacy dataset were analyzed, normalized, and seeded via Flyway:
- Eliminated denormalized comma-separated fields.
- Tokenized into relational child tables: `scheme_genders`, `scheme_castes`, `scheme_occupations`, `scheme_religions`, `scheme_documents`.
- Indexed for high-speed sub-millisecond query execution on Supabase PostgreSQL 17.

### 2.3 Comprehensive DPDPA 2023 Privacy Architecture
- **Blind Indexing**: Phone numbers are hashed using SHA-256 and a secret salt before storage or indexing.
- **Log Masking**: Custom Logback converter (`PiiMaskingConverter`) scrubs mobile numbers and sensitive identifiers from all application logs.
- **Right to Erasure**: Sending `reset` immediately purges user profile data.

---

## 3. Verified System Metrics & Performance

- **Automated Test Suite**: 42 unit, integration, and security tests passing (`100% success rate`).
- **Live Infrastructure Verified**:
  - Live Supabase PostgreSQL 17.6 database verified with `yojna_setu` schema, custom enums, 11 normalized tables, and 82 seeded schemes.
  - Live Groq AI integration verified: multilingual Hindi/Hinglish demographic extraction with `openai/gpt-oss-20b` and audio transcription with `whisper-large-v3-turbo`.
- **Memory Footprint**: Bounded to 512 MB G1GC running in unprivileged Docker container.
- **Webhook Security**: HMAC-SHA1 signature verification, replay protection, and rate-limited to 20 RPM per caller via Bucket4j token bucket.
- **Interactive Browser Demo**: Fully functional single-page test environment (`/demo.html`) enabling portfolio evaluation in any browser.

---

## 4. Production Artifacts Directory Reference

- **Architecture Specification**: `docs/v2/ARCHITECTURE.md`
- **Threat Model (STRIDE/PASTA)**: `docs/v2/THREAT_MODEL.md`
- **Architectural Decision Records**: `docs/v2/ADR/` (ADR-001 through ADR-008)
- **Database Schema & 1NF Migration**: `docs/v2/DATABASE.md`, `docs/v2/DATA_MIGRATION.md`
- **WhatsApp Webhook & SSRF Defense**: `docs/v2/WHATSAPP.md`
- **AI Gateway & Prompt Injection Defense**: `docs/v2/AI_BOUNDARY.md`
- **Privacy & DPDPA Compliance**: `docs/v2/PRIVACY.md`
- **Deployment & Containerization**: `docs/v2/DEPLOYMENT.md`, `Dockerfile`, `docker-compose.yml`
- **Verification & Testing Suite**: `docs/v2/TESTING.md`
