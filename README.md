# Yojna Setu

A Spring Boot-powered automated eligibility verification and conversational WhatsApp bot for Indian government schemes.

## Features
- **Conversational Form Flow**: Interactive chatbot prompting for user demographic details (age, income, caste, religion, etc.).
- **Smart Parsing**: Groq Llama 3.1 LLM-based parsing and normalization of conversational text responses.
- **State-Specific Schemes**: Recommends targeted state-level programs for Bihar, Uttar Pradesh, Maharashtra, Rajasthan, and more.
- **Upcoming Deadline Reminders**: Active countdowns and notices for schemes with endpoints inside 60 days.
- **WhatsApp Voice Note Transcription**: Dynamic Hindi voice transcribing via the Groq Whisper API.

## Configuration Setup
1. Copy the example configuration:
   ```bash
   cp src/main/resources/application-secrets.properties.example src/main/resources/application-secrets.properties
   ```
2. Populate `application-secrets.properties` with your respective Twilio and Groq API keys.
