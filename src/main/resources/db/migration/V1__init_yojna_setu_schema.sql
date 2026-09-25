-- ==============================================================================
-- YOJNA SETU V2 — V1 SCHEMA INITIALIZATION
-- Target Database: PostgreSQL (Supabase Project #2)
-- Schema: yojna_setu
-- ==============================================================================

CREATE SCHEMA IF NOT EXISTS yojna_setu;

-- ------------------------------------------------------------------------------
-- 1. Custom Enum Types
-- ------------------------------------------------------------------------------
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'gender_type' AND typnamespace = 'yojna_setu'::regnamespace) THEN
        CREATE TYPE yojna_setu.gender_type AS ENUM ('MALE', 'FEMALE', 'TRANSGENDER', 'ALL');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'caste_type' AND typnamespace = 'yojna_setu'::regnamespace) THEN
        CREATE TYPE yojna_setu.caste_type AS ENUM ('GENERAL', 'OBC', 'SC', 'ST', 'EWS', 'ALL');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'marital_status_type' AND typnamespace = 'yojna_setu'::regnamespace) THEN
        CREATE TYPE yojna_setu.marital_status_type AS ENUM ('SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED', 'ALL');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'scheme_category_type' AND typnamespace = 'yojna_setu'::regnamespace) THEN
        CREATE TYPE yojna_setu.scheme_category_type AS ENUM ('CENTRAL_GOVERNMENT', 'STATE_GOVERNMENT', 'PRIVATE');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'application_mode_type' AND typnamespace = 'yojna_setu'::regnamespace) THEN
        CREATE TYPE yojna_setu.application_mode_type AS ENUM ('ONLINE', 'OFFLINE', 'BOTH');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'session_state_type' AND typnamespace = 'yojna_setu'::regnamespace) THEN
        CREATE TYPE yojna_setu.session_state_type AS ENUM (
            'INIT', 'LANGUAGE_SELECTION', 'PROFILE_COLLECTION', 'PROFILE_REVIEW',
            'SCHEMES_LIST', 'SCHEME_DETAILS', 'DOCUMENT_CHECKLIST', 'APPLICATION_GUIDE',
            'HELP', 'HUMAN_HANDOFF'
        );
    END IF;
END $$;

-- ------------------------------------------------------------------------------
-- 2. Users Table (Core Identity)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number_e164 VARCHAR(20) NOT NULL,
    phone_number_hash VARCHAR(64) NOT NULL, -- SHA-256 blind index
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'en',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_phone_hash UNIQUE (phone_number_hash)
);

CREATE INDEX IF NOT EXISTS idx_users_phone_hash ON yojna_setu.users(phone_number_hash);

-- ------------------------------------------------------------------------------
-- 3. User Profiles Table (1:1 Normalized Demographics)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES yojna_setu.users(id) ON DELETE CASCADE,
    age SMALLINT CHECK (age >= 0 AND age <= 130),
    gender yojna_setu.gender_type,
    state VARCHAR(100),
    district VARCHAR(100),
    caste yojna_setu.caste_type,
    annual_income NUMERIC(15, 2) CHECK (annual_income >= 0),
    occupation VARCHAR(50),
    religion VARCHAR(50) DEFAULT 'ALL',
    marital_status yojna_setu.marital_status_type DEFAULT 'ALL',
    is_differently_abled BOOLEAN NOT NULL DEFAULT FALSE,
    education_level VARCHAR(50),
    is_profile_complete BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_profiles_user_id UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_profiles_demographics 
ON yojna_setu.user_profiles (state, caste, gender, annual_income);

-- ------------------------------------------------------------------------------
-- 4. Schemes Master Table
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.schemes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    ministry VARCHAR(255) NOT NULL,
    category yojna_setu.scheme_category_type NOT NULL DEFAULT 'CENTRAL_GOVERNMENT',
    short_description TEXT NOT NULL,
    benefits TEXT NOT NULL,
    application_mode yojna_setu.application_mode_type NOT NULL DEFAULT 'BOTH',
    application_process TEXT,
    official_url VARCHAR(500),
    min_age SMALLINT NOT NULL DEFAULT 0,
    max_age SMALLINT NOT NULL DEFAULT 130,
    max_income NUMERIC(15, 2), -- NULL = No upper income ceiling
    requires_disability BOOLEAN NOT NULL DEFAULT FALSE,
    target_state VARCHAR(100) NOT NULL DEFAULT 'ALL',
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_schemes_code UNIQUE (code)
);

CREATE INDEX IF NOT EXISTS idx_schemes_matching 
ON yojna_setu.schemes (is_active, target_state, min_age, max_age, max_income);

-- ------------------------------------------------------------------------------
-- 5. Scheme Junction Tables (1NF Relational Criteria)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.scheme_castes (
    scheme_id UUID NOT NULL REFERENCES yojna_setu.schemes(id) ON DELETE CASCADE,
    caste yojna_setu.caste_type NOT NULL,
    PRIMARY KEY (scheme_id, caste)
);

CREATE INDEX IF NOT EXISTS idx_scheme_castes_lookup ON yojna_setu.scheme_castes(caste);

CREATE TABLE IF NOT EXISTS yojna_setu.scheme_genders (
    scheme_id UUID NOT NULL REFERENCES yojna_setu.schemes(id) ON DELETE CASCADE,
    gender yojna_setu.gender_type NOT NULL,
    PRIMARY KEY (scheme_id, gender)
);

CREATE INDEX IF NOT EXISTS idx_scheme_genders_lookup ON yojna_setu.scheme_genders(gender);

CREATE TABLE IF NOT EXISTS yojna_setu.scheme_occupations (
    scheme_id UUID NOT NULL REFERENCES yojna_setu.schemes(id) ON DELETE CASCADE,
    occupation VARCHAR(50) NOT NULL,
    PRIMARY KEY (scheme_id, occupation)
);

CREATE INDEX IF NOT EXISTS idx_scheme_occupations_lookup ON yojna_setu.scheme_occupations(occupation);

CREATE TABLE IF NOT EXISTS yojna_setu.scheme_religions (
    scheme_id UUID NOT NULL REFERENCES yojna_setu.schemes(id) ON DELETE CASCADE,
    religion VARCHAR(50) NOT NULL,
    PRIMARY KEY (scheme_id, religion)
);

CREATE INDEX IF NOT EXISTS idx_scheme_religions_lookup ON yojna_setu.scheme_religions(religion);

-- ------------------------------------------------------------------------------
-- 6. Scheme Required Documents Table
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.scheme_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scheme_id UUID NOT NULL REFERENCES yojna_setu.schemes(id) ON DELETE CASCADE,
    document_name VARCHAR(150) NOT NULL,
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_scheme_documents_scheme_id ON yojna_setu.scheme_documents(scheme_id);

-- ------------------------------------------------------------------------------
-- 7. Persistent Conversation Sessions Table (Replaces In-Memory Maps)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.conversation_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES yojna_setu.users(id) ON DELETE CASCADE,
    current_state yojna_setu.session_state_type NOT NULL DEFAULT 'INIT',
    last_prompt_sent VARCHAR(100),
    pagination_offset INT NOT NULL DEFAULT 0,
    cached_eligible_schemes JSONB,
    session_data JSONB,
    last_interaction_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_conversation_sessions_user_id UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_conversation_sessions_user_id ON yojna_setu.conversation_sessions(user_id);

-- ------------------------------------------------------------------------------
-- 8. Webhook Events Table (Durable Idempotency & Replay Protection)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.webhook_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider VARCHAR(50) NOT NULL,
    provider_message_id VARCHAR(100) NOT NULL,
    payload_hash VARCHAR(64),
    status VARCHAR(50) NOT NULL DEFAULT 'RECEIVED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_webhook_events_provider_msg UNIQUE (provider_message_id)
);

CREATE INDEX IF NOT EXISTS idx_webhook_events_msgid ON yojna_setu.webhook_events(provider_message_id);

-- ------------------------------------------------------------------------------
-- 9. Security Audit Events Table
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS yojna_setu.audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_hash VARCHAR(64) NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id VARCHAR(100),
    details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_events_created_at ON yojna_setu.audit_events(created_at);
