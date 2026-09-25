# YOJNA SETU V2 — CONVERSATION ENGINE SPECIFICATION
**Document:** `docs/v2/CONVERSATION_ENGINE.md`  
**Version:** 2.0.0  
**Pattern:** Finite State Machine (FSM) + Domain Orchestrator  
**Status:** APPROVED (PHASE 6 SPECIFICATION)  

---

## 1. Conversational Lifecycle & State Diagram

The conversation engine replaces the legacy 489-line God service (`ConversationService`) with an explicit, modular State Pattern.

```mermaid
stateDiagram-v2
    [*] --> INIT
    INIT --> LANGUAGE_SELECTION : User sends greeting ("hi", "namaste")
    LANGUAGE_SELECTION --> PROFILE_COLLECTION : User selects 1 (Hindi), 2 (Hinglish), 3 (English)
    
    state PROFILE_COLLECTION {
        [*] --> AskAge
        AskAge --> AskGender : Valid age provided
        AskGender --> AskState : Valid gender provided
        AskState --> AskCaste : Valid state provided
        AskCaste --> AskIncome : Valid category provided
        AskIncome --> AskOccupation : Valid income provided
        AskOccupation --> [*] : Valid occupation provided
    }
    
    PROFILE_COLLECTION --> PROFILE_REVIEW : All 6 demographic fields collected
    
    PROFILE_REVIEW --> PROFILE_COLLECTION : User replies "2" (Edit profile)
    PROFILE_REVIEW --> SCHEMES_LIST : User replies "1" (Confirm & discover)
    
    state SCHEMES_LIST {
        [*] --> ShowTop3
        ShowTop3 --> ShowNext3 : User replies "more" / "aur"
        ShowNext3 --> ShowTop3 : Pagination wrap-around
    }
    
    SCHEMES_LIST --> SCHEME_DETAILS : User sends number (e.g. "1") or Scheme Code
    
    state SCHEME_DETAILS {
        [*] --> ViewSummary
        ViewSummary --> ViewDocs : User sends "docs"
        ViewSummary --> ViewApply : User sends "apply"
    }
    
    SCHEME_DETAILS --> SCHEMES_LIST : User sends "back" / "वापस"
    
    INIT --> [*] : /reset
    PROFILE_COLLECTION --> INIT : User sends "reset"
    SCHEMES_LIST --> INIT : User sends "reset"
```

---

## 2. Preventing the Profile Overwrite Corruption Bug

### 2.1 The Legacy Failure Mode
In legacy V1, any message from a returning user was sent to the Groq LLM. If the user asked `"Tell me about schemes for an 18 year old student"`, the legacy code blindly updated `profile.setAge(18)` and `profile.setOccupation("STUDENT")`, silently corrupting the citizen's profile.

### 2.2 The V2 Architectural Solution
1. **State Isolation:** Demographic updates are *only* executed when `session.currentState == PROFILE_COLLECTION`.
2. **Explicit User Review:** Once collected, the user reviews a summary in `PROFILE_REVIEW` and must explicitly confirm before `is_profile_complete = true` is set.
3. **Immutability in Browsing States:** While in `SCHEMES_LIST` or `SCHEME_DETAILS`, incoming messages are interpreted as navigation commands, scheme selectors, or document inquiries. Profile records remain untouched.

---

## 3. Persistent, Restart-Safe Session Storage

### 3.1 Elimination of In-Memory Maps
- The legacy `ConcurrentHashMap` instances (`shownCountMap`) are completely deleted.
- All session context is persisted in PostgreSQL table `yojna_setu.conversation_sessions`:
  - `current_state` (Enum)
  - `pagination_offset` (Integer offset, increments by 3)
  - `cached_eligible_schemes` (JSONB array of pre-matched Scheme UUIDs)
  - `last_interaction_at` (Timestamp)

### 3.2 Horizontal Scale-Out
Multiple Spring Boot pods behind an AWS ALB or Kubernetes ingress can process requests from the same user interchangeably. State is loaded and committed atomically within transactional database boundaries.
