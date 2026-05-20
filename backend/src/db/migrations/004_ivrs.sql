-- IVRS domain
-- Tracks inbound calls coming from Exotel and the interactions inside each call.

-- =========================
-- IVRS_CALL
-- =========================
CREATE TABLE IF NOT EXISTS IVRS_CALL (
    id TEXT PRIMARY KEY,
    exotel_call_sid TEXT UNIQUE,
    caller_number TEXT,
    called_number TEXT,
    language_code TEXT,
    selected_dept_id TEXT,
    call_start TEXT DEFAULT CURRENT_TIMESTAMP,
    call_end TEXT,
    call_status TEXT CHECK(call_status IN (
        'ACTIVE',
        'COMPLETED',
        'DROPPED',
        'NO_INPUT',
        'ERROR'
    )),
    menu_version INTEGER DEFAULT 1,

    FOREIGN KEY (selected_dept_id) REFERENCES DEPARTMENT(id)
);

-- =========================
-- IVRS_INTERACTION
-- =========================
CREATE TABLE IF NOT EXISTS IVRS_INTERACTION (
    id TEXT PRIMARY KEY,
    call_id TEXT NOT NULL,
    sequence INTEGER NOT NULL,
    step TEXT CHECK(step IN (
        'START',
        'LANGUAGE',
        'DEPARTMENT',
        'DIRECTIONS',
        'REPEAT',
        'END'
    )),
    prompt_played TEXT,
    dtmf_input TEXT,
    intent_matched TEXT CHECK(intent_matched IN (
        'DEPARTMENT_SELECT',
        'LANGUAGE_SELECT',
        'REPEAT_INSTRUCTION',
        'MAIN_MENU',
        'HANGUP',
        'UNKNOWN'
    )),
    recorded_at TEXT DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (call_id) REFERENCES IVRS_CALL(id)
);

CREATE INDEX IF NOT EXISTS idx_ivrs_call_exotel_sid
ON IVRS_CALL(exotel_call_sid);

CREATE INDEX IF NOT EXISTS idx_ivrs_interaction_call
ON IVRS_INTERACTION(call_id);
