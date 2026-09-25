# 🇮🇳 Yojna Setu V2 — Hardened WhatsApp Government Welfare Assistant

[![Java](https://img.shields.io/badge/Java-21%20LTS-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.12-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17%20(Supabase)-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://supabase.com/)
[![Groq AI](https://img.shields.io/badge/Groq-GPT--OSS--20B%20%2B%20Whisper-F55036?style=for-the-badge&logo=meta&logoColor=white)](https://groq.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

> **Yojna Setu V2** is an enterprise-grade, conversational government scheme discovery and eligibility assistant. Designed for multi-lingual Indian citizens on WhatsApp, powered by a **Deterministic Hybrid Architecture** (Groq AI for extraction, exact Java rule engine for eligibility), with zero-trust security and full **DPDPA 2023** compliance.

---

## ⚡ Quick Links & Live Interactive Demo

- 🌐 **Interactive Browser Demo UI**: Navigate to `http://localhost:8080/demo.html` to test conversational flows, voice note simulations, and live eligibility inspection without Twilio credentials.
- 📖 [Executive Portfolio Case Study (SHIVSASTRA)](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/PORTFOLIO.md)
- 🏗️ [V2 System Architecture & Design](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/ARCHITECTURE.md)
- 🔒 [Threat Model & Security Mitigation (STRIDE/PASTA)](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/THREAT_MODEL.md)
- 🔍 [Forensic Legacy Audit Report](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/YOJNA_SETU_FORENSIC_AUDIT.md)
- 🧪 [Automated Test Suite Verification (42/42 Passed)](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/TESTING.md)
- ☁️ [Live Infrastructure & Supabase Verification Report](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/PHASE_F3_INFRASTRUCTURE_VERIFICATION.md)

---

## 🚀 Key Architecture Innovations (V1 vs V2)

| Feature | Legacy V1 (Prototype) | Yojna Setu V2 (Enterprise Production) |
| :--- | :--- | :--- |
| **Eligibility Engine** | Flawed string matching (`"FEMALE".contains("MALE")` bug) | **Deterministic Rule Engine** with exact Enum matching & multi-criteria evaluation |
| **AI Boundary** | LLM hallucinated eligibility; unvalidated user inputs | **Hybrid Boundary**: LLM strictly parses demographics; Java engine evaluates rules |
| **Database** | MySQL with denormalized CSV strings & startup wipes | **Supabase PostgreSQL 17 (1NF)** with Flyway migrations & isolated `yojna_setu` schema |
| **Data Privacy** | Plaintext phone numbers stored & logged | **DPDPA 2023 Compliant**: SHA-256 blind phone indexing & Logback PII masking |
| **API Security** | Unauthenticated endpoints with IDOR vulnerabilities | Stateless Spring Security with `X-API-KEY` admin filters & HMAC-SHA1 Twilio validation |
| **Messaging Channel**| Hard-coded Twilio dependency | **Provider Abstraction Pattern**: Seamless switch between Twilio and Web Browser Demo |

---

## 🛠️ Technology Stack

- **Backend Framework**: Java 21, Spring Boot 3.2.12
- **Database & Migration**: Supabase PostgreSQL 17.6, Flyway 10, Hibernate 6
- **AI / NLP**: Groq API (`openai/gpt-oss-20b` for demographic parsing, `whisper-large-v3-turbo` for voice)
- **Messaging**: Twilio WhatsApp API & In-Memory Web Demo Channel
- **Rate Limiting**: Bucket4j Token Bucket (20 RPM per user)
- **Security**: Spring Security 6, HMAC-SHA1 signature verification, SHA-256 blind indexing
- **Observability**: Spring Boot Actuator, Logback with custom PII masking converter

---

## 📦 Getting Started & Local Setup

### Prerequisites
- Java 21 LTS installed (`java -version`)
- Docker & Docker Compose (optional, for containerized run)
- Groq API Key (free at [console.groq.com](https://console.groq.com))

### 1. Clone Repository & Setup Environment
```bash
git clone https://github.com/shivam-shukla888/Yojna-Setu.git
cd Yojna-Setu

# Copy environment template
cp .env.example .env
```

Configure your `.env` file with your credentials:
```properties
GROQ_API_KEY=gsk_your_groq_api_key_here
DB_URL=jdbc:postgresql://your-supabase-host:5432/postgres?currentSchema=yojna_setu
DB_USER=postgres
DB_PASSWORD=your_secure_password
SECURITY_INTERNAL_API_SECRET=your-random-32-char-admin-secret-key
SECURITY_PHONE_HASH_PEPPER=your-random-32-char-salt-pepper
```

### 2. Run Database Migrations & Launch Application
```bash
# Compile and run test suite (42/42 tests passing)
./mvnw clean test

# Run application locally
./mvnw spring-boot:run
```

### 3. Open Interactive Web Demo
Open your browser to:
```
http://localhost:8080/demo.html
```
- Experience multi-lingual conversational flows (Hindi, English, Hinglish).
- Inspect the real-time finite state machine (`INIT` -> `LANGUAGE_SELECTION` -> `COLLECTING_PROFILE` -> `RECOMMENDING_SCHEMES`).
- Observe the live demographic card updating via Groq NLP and deterministic scheme eligibility matching.

---

## 🐳 Docker Deployment

Run the complete multi-stage hardened container setup:
```bash
docker-compose up -d --build
```
The container runs as an unprivileged user (`yojnasetu:yojnasetu`, UID 10001) with bounded G1GC memory parameters.

---

## 🛡️ Security & Privacy Compliance

- **No Plaintext Phone Numbers**: Phone numbers are converted to blind cryptographic hashes using `SHA-256(phone + pepper)` before storage or querying.
- **Log Masking**: Custom Logback converter redacts Indian phone numbers, Aadhaar patterns, and API keys.
- **Strict SSRF Mitigation**: Audio media URLs received from webhooks are validated against a strict Twilio host whitelist and restricted to 10 MB.
- **Admin Endpoint Protection**: Administrative CRUD endpoints under `/api/v1/admin/**` require the `X-API-KEY` header and are logged to immutable `audit_events`.

---

## 📜 Complete Documentation Sitemap

- [Forensic Legacy Audit](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/YOJNA_SETU_FORENSIC_AUDIT.md)
- [System Architecture](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/ARCHITECTURE.md)
- [Threat Modeling (STRIDE/PASTA)](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/THREAT_MODEL.md)
- [Architectural Decision Records (ADRs)](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/ADR/)
- [Database Schema & Migration](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/DATABASE.md)
- [Conversation State Engine](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/CONVERSATION_ENGINE.md)
- [Deterministic Eligibility Rules](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/ELIGIBILITY_ENGINE.md)
- [AI Gateway & Prompt Injection Protection](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/AI_BOUNDARY.md)
- [WhatsApp Webhook & Media Pipeline](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/WHATSAPP.md)
- [DPDPA 2023 Privacy Engineering](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/PRIVACY.md)
- [Production Deployment Guide](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/DEPLOYMENT.md)
- [Verification & Automated Test Suite](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/TESTING.md)
- [Final Verification Report](file:///c:/Users/thesh/Desktop/Yojna-Setu/docs/v2/FINAL_VERIFICATION_REPORT.md)
