# ADR-005: AI / Groq as Unprivileged Extraction Layer, Not Eligibility Authority

## Status
ACCEPTED

## Context
In the prototype, the LLM boundary was poorly defined:
- Raw user text was passed directly to the Groq API without sanitization or structural boundaries, exposing the system to prompt injection.
- LLM JSON responses were extracted using brittle substring searching (`indexOf("```json")`), causing crashes on unformatted responses.
- The public REST endpoint `/api/groq/extract` allowed external users to abuse the system's Groq quota.

## Decision
1. **Unprivileged AI Boundary:** The AI subsystem (Groq LLM and Whisper) is strictly an auxiliary language processing service:
   - Permitted: Speech-to-text transcription, language identification, multi-attribute entity extraction from free-form text, and friendly conversational rephrasing.
   - Forbidden: Deciding eligibility, inventing scheme rules, or directly mutating persistent database records.
2. **Strict Prompt Isolation:** Untrusted user input is enclosed inside explicit structural XML tags (`<user_message>...</user_message>`). System prompts strictly instruct the model to ignore instructions contained within user tags.
3. **Structured Schema Validation:** Model outputs are parsed and strictly validated against Java records using Jackson with strict type checks and value range assertions. If parsing fails, the system falls back gracefully to deterministic keyword parsing.
4. **Resilience & Circuit Breaking:** Groq API calls are wrapped with Resilience4j circuit breakers and bounded timeouts (3.0s). If the provider is degraded, the conversational engine falls back to standard numbered menus without disruption.
5. **No Public AI Proxy:** Remove the unauthenticated `/api/groq/extract` endpoint entirely.

## Consequences
### Positive
- Defends against prompt injection and quota theft.
- Ensures the application remains functional even during third-party LLM outages.
- Guarantees that public welfare advice is backed strictly by verified government rules rather than LLM hallucinations.

### Negative / Trade-offs
- Requires maintaining fallback conversational menus for all conversational paths.
