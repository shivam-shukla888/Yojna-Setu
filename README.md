# 🇮🇳 Yojna Setu - WhatsApp AI Agent for Government Schemes

> Helping Indian citizens discover government schemes they are eligible for — in Hindi, on WhatsApp.

##  Live Demo
Send "namaste" to **+1 415 523 8886** on WhatsApp to try it!
(Join sandbox first: send "join length-future" to the same number)

##  Problem Statement
Over 90 crore Indians are eligible for government schemes but never apply — due to lack of awareness, language barriers, and complex processes. Yojna Setu solves this through a simple WhatsApp conversation in Hindi.

##  Features
-  **Hindi/Hinglish NLP** — Powered by Groq API (Llama 3)
-  **Voice Message Support** — Groq Whisper transcription
-  **82+ Schemes** — Central + State + Private scholarships
-  **Smart Eligibility Matching** — Age, income, caste, state, religion, occupation
-  **Document Checklist** — Exact documents needed per scheme
-  **Deadline Reminders** — Never miss application deadlines
-  **Scheme Search** — Search any scheme by name
-  **Pagination** — Browse all matched schemes
-  **Reset & Help** — Full conversation control

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Backend | Java 21, Spring Boot 3.2 |
| Database | MySQL 8 |
| AI/NLP | Groq API (Llama 3 + Whisper) |
| Messaging | Twilio WhatsApp API |
| Deployment | AWS EC2 t2.micro, systemd |

## Architecture
User (WhatsApp) → Twilio Webhook → Spring Boot REST API
↓
Groq AI (NLP)
↓
MySQL (Schemes DB)
↓
Twilio Reply → User

## 📱 WhatsApp Commands
| Command | Action |
|---------|--------|
| `namaste` | Start new profile |
| `reset` | Reset and start over |
| `aur` | See next 5 schemes |
| `documents` | Required documents list |
| `deadline` | Upcoming deadlines |
| `help` | Show all commands |
| `[scheme name]` | Search scheme details |

##  Local Setup
1. Clone the repo
```bash
git clone https://github.com/shivam-shukla888/Yojna-Setu.git
```
2. Configure credentials in `application.properties`:
```properties
groq.api.key=YOUR_GROQ_API_KEY
twilio.account.sid=YOUR_TWILIO_SID
twilio.auth.token=YOUR_TWILIO_AUTH_TOKEN
spring.datasource.url=jdbc:mysql://localhost:3306/yojna_setu
spring.datasource.username=root
spring.datasource.password=YOUR_PASSWORD
```
3. Run:
```bash
./mvnw spring-boot:run
```
4. Set Twilio webhook: `http://YOUR_IP:8080/webhook/whatsapp`

## Scheme Categories
- Central Government (PM-KISAN, Ayushman Bharat, PM Awas, etc.)
- State Specific (UP, Bihar, Maharashtra, Rajasthan, MP, WB, Delhi)
- Education & Scholarships (Govt + Private: Tata, Reliance, HDFC, Infosys)
- Women Empowerment, Disability, Minorities, Skill Development

## Author
**Shivam Shukla** — [GitHub](https://github.com/shivam-shukla888)
