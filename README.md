# 🇮🇳 Yojna Setu V2 — Government Scheme Discovery Assistant

[![Java](https://img.shields.io/badge/Java-21%20LTS-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.12-6DB33F?style=for-the-badge&logo=springboot)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supabase-336791?style=for-the-badge&logo=postgresql)](https://supabase.com/)
[![Groq](https://img.shields.io/badge/LLM-Groq-F55036?style=for-the-badge)](https://groq.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker)](https://www.docker.com/)

Yojna Setu is a conversational government-scheme discovery assistant. Its intended architecture separates natural-language profile extraction from deterministic Java eligibility rules, so an LLM does not make the final eligibility decision.

> **Project status:** Check the setup steps, tests, configuration, and deployment evidence in this repository before treating any feature or security claim as production-verified.

## Quick Links

- **Local browser demo:** after starting the application, open [http://localhost:8080/demo.html](http://localhost:8080/demo.html).
- [Portfolio case study](docs/v2/PORTFOLIO.md)
- [System architecture](docs/v2/ARCHITECTURE.md)
- [Threat model](docs/v2/THREAT_MODEL.md)
- [Legacy audit](docs/YOJNA_SETU_FORENSIC_AUDIT.md)
- [Testing notes](docs/v2/TESTING.md)
- [Infrastructure verification](docs/v2/PHASE_F3_INFRASTRUCTURE_VERIFICATION.md)

## Key Design Ideas

| Area | Approach |
|---|---|
| Eligibility | Deterministic Java rules evaluate the extracted profile |
| AI boundary | LLM output should be validated before it enters application logic |
| Persistence | PostgreSQL with versioned database migrations |
| Messaging | WhatsApp integration with a browser-demo path |
| Security | Authentication, request validation, rate limits, and privacy-aware logging |

## Technology Stack

- **Backend:** Java 21, Spring Boot
- **Database & migrations:** PostgreSQL, Flyway, Hibernate
- **AI:** Groq API for language-model integration
- **Messaging:** Twilio WhatsApp API and browser demo
- **Security & operations:** Spring Security, rate limiting, Actuator, structured logging

## Local Setup

### Prerequisites

- Java 21
- Git
- A Groq API key for AI-backed flows
- Docker (optional)

### 1. Clone the repository

```bash
git clone https://github.com/shivam-shukla888/Yojna-Setu.git
cd Yojna-Setu
```

### 2. Configure environment variables

Review `.env.example` and configure the required values locally. **Never commit real API keys, database passwords, or production secrets.**

### 3. Run tests and start the application

```bash
./mvnw clean test
./mvnw spring-boot:run
```

Then open `http://localhost:8080/demo.html` if the demo is enabled by the current configuration.

### Docker

If the repository's Docker Compose configuration is present and configured, run:

```bash
docker compose up --build
```

## Documentation

- [Database schema](docs/v2/DATABASE.md)
- [Conversation engine](docs/v2/CONVERSATION_ENGINE.md)
- [Eligibility engine](docs/v2/ELIGIBILITY_ENGINE.md)
- [AI boundary and prompt-injection protection](docs/v2/AI_BOUNDARY.md)
- [WhatsApp and media pipeline](docs/v2/WHATSAPP.md)
- [Privacy engineering](docs/v2/PRIVACY.md)
- [Deployment guide](docs/v2/DEPLOYMENT.md)
- [Test documentation](docs/v2/TESTING.md)
- [Final verification report](docs/v2/FINAL_VERIFICATION_REPORT.md)

## Important Notes

- Eligibility recommendations should be verified against authoritative scheme rules; the assistant is not an official government service.
- Security and compliance claims should be supported by reproducible tests and evidence. Do not interpret documentation alone as proof of certification or legal compliance.
