# Yojna Setu V2 — Privacy, Data Protection & DPDPA 2023 Compliance

## 1. Regulatory Context (DPDPA 2023)

The **Digital Personal Data Protection Act (DPDPA) 2023** governs the processing of digital personal data in India. Government welfare assistance applications handle sensitive demographic information:
- Phone numbers
- Age & Gender
- Caste / Social Category
- Annual Income & Economic Status
- Disability Status

In legacy V1, raw phone numbers and user data were logged in plain text, stored without hashing, and exposed via unauthenticated endpoints. Yojna Setu V2 enforces strict compliance with Indian privacy principles.

---

## 2. Core Privacy Engineering Implementations

### 2.1 Blind Indexing of Phone Numbers
To maintain user lookup capabilities without storing plain text phone numbers as database keys:
- The system computes an irreversible HMAC / SHA-256 hash using an application-level cryptographic salt (pepper):
  $$\text{phone\_hash} = \text{SHA-256}(\text{E164\_phone} + \text{hash\_pepper})$$
- The raw phone number is stored only during an active conversational session and is never logged in audit trails.
- Lookups in `users` and `conversation_sessions` are performed against `phone_number_hash`.

### 2.2 Strict Log Sanitization (PiiMaskingConverter)
The logging framework integrates a custom Logback composite converter (`PiiMaskingConverter`):
- Automatically masks 10-digit, 11-digit, and 12-digit Indian phone numbers (e.g., `+919876543210` becomes `+9198****3210`).
- Masks potential Aadhaar numbers (12-digit patterns).
- Strips any raw API keys (`gsk_...` or Twilio auth tokens) from logging streams.

### 2.3 User Right to Erasure ("Reset" Command)
Under DPDPA 2023, data principals have the right to withdraw consent and request data deletion.
- Sending `reset`, `restart`, or `शुरू` immediately clears all stored demographic attributes in `user_profiles` (age, caste, income, disability status).
- Clears conversational session variables and cached scheme recommendations.

### 2.4 Data Minimization in AI Boundary
- Demographics extracted by Groq LLM are strictly bounded to the structured schema:
  `ExtractedDemographicsRecord(age, gender, caste, state, annualIncome, occupation, differentlyAbled)`
- The system prompt forbids retention of conversation transcripts on external inference endpoints.
- User queries are stripped of personal identifiers before passing to the model.

---

## 3. Threat Matrix & Privacy Controls

| Privacy Risk | Legacy V1 Vulnerability | V2 Defense Control |
| :--- | :--- | :--- |
| **Data Leak via Logs** | Raw phone numbers in console logs | Logback `PiiMaskingConverter` regex redaction |
| **Phone Scraping** | Plaintext phone numbers in DB tables | SHA-256 blind indexing with pepper |
| **IDOR / Data Exfiltration** | Unauthenticated `/api/users/{id}` endpoint | Strict API Key filter; IDOR endpoints deleted |
| **State Tampering** | Global concurrent in-memory session maps | JPA-backed isolated transaction boundaries |
| **Prompt Leak** | Unchecked user strings passed to LLM | Prompt injection sanitization with XML tags |
