# ADR-002: Provider-Neutral WhatsApp Architecture & Channel Abstraction

## Status
ACCEPTED

## Context
The legacy application coupled its conversation routing and message dispatching directly to the Twilio SDK inside `WhatsAppWebhookController` and `TwilioService`. 

This tight coupling introduced severe architectural liabilities:
- Inability to switch to Meta Cloud API (WhatsApp Cloud API) or local SMS aggregators without rewriting core services.
- Inability to run interactive demos, portfolio evaluations, or automated integration tests without an active, funded Twilio WhatsApp sender.
- Business logic was directly dependent on Twilio-specific HTTP form parameter names (`From`, `Body`, `MessageSid`).

## Decision
1. **Define Core Channel Abstraction:** Introduce a provider-neutral domain contract:
   - `WhatsAppMessageProvider` interface defining:
     - `sendTextMessage(String recipientId, String textMessage)`
     - `sendInteractiveMessage(String recipientId, InteractiveMessage message)`
   - Domain records: `InboundMessage` and `OutboundMessage` decoupling core logic from transport headers.
2. **Provider Implementations:**
   - `TwilioWhatsAppProvider`: Translates Twilio webhook form data, verifies `X-Twilio-Signature`, and dispatches via Twilio REST client.
   - `MetaWhatsAppProvider` (Extensible): Handles Meta Webhook JSON schemas and graph API calls.
   - `BrowserDemoProvider`: In-memory channel adapter enabling portfolio visitors and recruiters to interact with the full conversational state machine via a browser REST API without any WhatsApp credentials.
3. **Provider Factory / Strategy:** Inbound webhooks route to dedicated provider controllers (`/api/v1/webhooks/twilio`, `/api/v1/webhooks/meta`), which normalize the event into an `InboundMessage` before handing it off to the unified `ConversationOrchestrator`.

## Consequences
### Positive
- Zero business logic changes required if changing underlying WhatsApp gateway vendors.
- Allows full local testing and browser-based demonstrations for the SHIVSASTRA portfolio without external API dependencies.
- Clear separation of transport-level concerns (signature validation, HTTP parameters) from conversation management.

### Negative / Trade-offs
- Requires maintaining adapter classes and data transfer objects for each supported provider.
