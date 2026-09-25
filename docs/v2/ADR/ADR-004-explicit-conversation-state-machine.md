# ADR-004: Explicit Conversation State Machine & Persistent Session Store

## Status
ACCEPTED

## Context
The legacy application's conversational logic was concentrated in a single 489-line God class (`ConversationService.java`). 

Key architectural failures in the legacy implementation:
1. **Profile Overwrite Corruption:** Any message sent by a user with an existing complete profile was passed to Groq LLM entity extraction. If Groq extracted an attribute (e.g. user asking on behalf of a brother: `"Schemes for 18yo student"`), the citizen's own database profile was immediately overwritten.
2. **Volatile Memory Storage:** User pagination state (`shownCountMap`) was stored in static `ConcurrentHashMap` instances. Any server reboot, deployment, or horizontal scale-out broke pagination and created memory leaks.
3. **Rigid Turn-Taking:** The flow did not handle out-of-order responses, multi-entity answers, or navigation commands gracefully.

## Decision
1. **Explicit State Pattern / State Machine:** Define a finite state machine governed by typed state enums (`session_state_type`):
   - `INIT`, `LANGUAGE_SELECTION`, `PROFILE_COLLECTION`, `PROFILE_REVIEW`, `SCHEMES_LIST`, `SCHEME_DETAILS`, `DOCUMENT_CHECKLIST`, `APPLICATION_GUIDE`.
2. **Database Persistence:** Persist all active session metadata in `yojna_setu.conversation_sessions`:
   - `user_id` (UUID foreign key)
   - `current_state` (Enum)
   - `pagination_offset` (Integer)
   - `cached_eligible_schemes` (JSONB array of Scheme UUIDs)
   - `session_data` (JSONB scratchpad for temporary inferences)
   - `last_interaction_at` (Timestamp for TTL tracking)
3. **Intent-Gated Profile Modification:**
   - Implement an upfront Intent Classifier before invoking LLM extraction.
   - Profile updates are *only* permitted when the user is explicitly in the `PROFILE_COLLECTION` state or explicitly sends an `/update-profile` command.
   - Conversational inquiries about third parties are treated as ephemeral session queries and never mutate the citizen's persistent demographic record.

## Consequences
### Positive
- Prevents accidental profile corruption.
- Complete fault tolerance across server restarts and container redeployments.
- Horizontal scalability: multiple Spring Boot pods can serve the same citizen session without sticky sessions or in-memory state synchronization.

### Negative / Trade-offs
- Every inbound message requires an asynchronous or transactional read/write to `yojna_setu.conversation_sessions`.
