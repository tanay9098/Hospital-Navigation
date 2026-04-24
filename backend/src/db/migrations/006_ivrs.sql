-- Domain 4: IVRS

-- =========================
-- IVRS_CALL
-- =========================
CREATE TABLE IF NOT EXISTS IVRS_CALL (
    id TEXT PRIMARY KEY,
    session_id TEXT,
    caller_number TEXT,
    language_code TEXT,
    call_start TEXT DEFAULT CURRENT_TIMESTAMP,
    call_end TEXT,

    call_status TEXT CHECK(call_status IN (
        'ACTIVE',
        'COMPLETED',
        'DROPPED'
    )),

    menu_version INTEGER,

    FOREIGN KEY (session_id) REFERENCES NAV_SESSION(id)
);

-- =========================
-- IVRS_INTERACTION
-- =========================
CREATE TABLE IF NOT EXISTS IVRS_INTERACTION (
    id TEXT PRIMARY KEY,
    call_id TEXT,
    sequence INTEGER,
    prompt_played TEXT,
    dtmf_input TEXT,
    speech_input TEXT,

    intent_matched TEXT CHECK(intent_matched IN (
        'DEPARTMENT_SELECT',
        'REPEAT_INSTRUCTION',
        'GO_BACK',
        'MAIN_MENU',
        'UNKNOWN'
    )),

    confidence_score REAL,
    recorded_at TEXT DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (call_id) REFERENCES IVRS_CALL(id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ivrs_call_session
ON IVRS_CALL(session_id);

CREATE INDEX IF NOT EXISTS idx_ivrs_interaction_call
ON IVRS_INTERACTION(call_id);