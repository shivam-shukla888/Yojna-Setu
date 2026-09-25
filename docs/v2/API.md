# YOJNA SETU V2 — REST API SPECIFICATION
**Document:** `docs/v2/API.md`  
**Version:** 2.0.0  
**Base URL:** `/api/v1`  
**Status:** APPROVED (PHASE 5 SPECIFICATION)  

---

## 1. API Architecture & Standard Envelopes

All Yojna Setu V2 APIs adhere to strict versioning, input validation, and unified JSON response envelopes.

### 1.1 Unified Response Envelope (`ApiResponse<T>`)
Every API response returns a consistent structure:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "error": null,
  "timestamp": "2026-09-25T16:40:00Z"
}
```

### 1.2 Error Envelope (`ApiError`)
When a request fails, HTTP 4xx/5xx status codes are accompanied by:
```json
{
  "success": false,
  "message": "Validation failure",
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request payload",
    "details": [
      "phoneNumber must be valid E.164 format"
    ]
  },
  "timestamp": "2026-09-25T16:40:00Z"
}
```

---

## 2. API Security Boundaries

| Route Pattern | Boundary | Authentication | Description |
|---|---|---|---|
| `/actuator/**` | `PUBLIC` | None | Service liveness and readiness health probes |
| `/api/v1/webhooks/**` | `INTERNAL_WEBHOOK` | Provider Signature (`X-Twilio-Signature`) | WhatsApp gateway webhook ingestion |
| `/api/v1/demo/**` | `DEMO` | Rate Limited (Bucket4j) | Browser technical demo for recruiters / portfolio |
| `/api/v1/schemes/**` | `PUBLIC_READ` | None (Rate Limited) | Scheme discovery and criteria listing |
| `/api/v1/admin/**` | `ADMIN` | `X-API-KEY` | Administrative scheme updates and audit logs |

---

## 3. Core API Endpoints

### 3.1 Webhooks
- **`POST /api/v1/webhooks/twilio/whatsapp`**
  - **Content-Type:** `application/x-www-form-urlencoded`
  - **Headers Required:** `X-Twilio-Signature`
  - **Parameters:** `From`, `Body`, `MessageSid`, `MediaUrl0`, `MediaContentType0`
  - **Response:** `200 OK` (Empty or TwiML)

### 3.2 Browser Technical Demo
- **`POST /api/v1/demo/chat`**
  - **Request Body:**
    ```json
    {
      "sessionId": "b47c9451-f761-4603-912b-b8c2d1b6cf8e",
      "message": "नमस्ते, मुझे किसान योजना के बारे में बताएं"
    }
    ```
  - **Response:**
    ```json
    {
      "success": true,
      "message": "Message processed",
      "data": {
        "replyText": "नमस्ते! Yojna Setu में आपका स्वागत है...",
        "currentState": "PROFILE_COLLECTION",
        "eligibleSchemesCount": 0
      }
    }
    ```

- **`POST /api/v1/demo/reset`**
  - **Request Body:** `{"sessionId": "b47c9451-f761-4603-912b-b8c2d1b6cf8e"}`
  - **Response:** Wipes ephemeral demo state.

### 3.3 Scheme Catalog
- **`GET /api/v1/schemes`**
  - **Query Parameters:** `page=0`, `size=10`, `category=CENTRAL_GOVERNMENT`, `state=ALL`
  - **Response:** Paginated array of schemes with benefits and document requirements.

- **`GET /api/v1/schemes/{code}`**
  - **Path Parameter:** `code` (e.g. `PM-KISAN`)
  - **Response:** Complete scheme detail including official URLs and application instructions.

### 3.4 Administrative Management
- **`POST /api/v1/admin/schemes`**
  - **Headers Required:** `X-API-KEY: <INTERNAL_API_SECRET>`
  - **Request Body:** Structured scheme definition with 1NF eligibility lists.
  - **Response:** `201 Created` with UUID.

---

## 4. Removed Legacy Endpoints
The following endpoints from legacy V1 have been **intentionally removed** to eliminate critical security vulnerabilities:
1. `GET /api/profile/{phoneNumber}` — **Removed** (Public IDOR vulnerability leaking citizen PII).
2. `POST /api/groq/extract` — **Removed** (Unauthenticated open proxy exposing LLM quotas).
