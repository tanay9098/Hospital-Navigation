-- Domain 3: Sessions & Users

-- =========================
-- USER
-- =========================
CREATE TABLE IF NOT EXISTS USER (
    id TEXT PRIMARY KEY,
    phone_number TEXT UNIQUE,
    preferred_language TEXT,
    wheelchair_user INTEGER DEFAULT 0,
    last_seen_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- NAV_SESSION
-- =========================
CREATE TABLE IF NOT EXISTS NAV_SESSION (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    start_node_id TEXT,
    dest_dept_id TEXT,

    channel TEXT CHECK(channel IN (
        'APP',
        'IVRS',
        'WEB',
        'KIOSK'
    )),

    language_code TEXT,
    wheelchair_mode INTEGER DEFAULT 0,
    started_at TEXT DEFAULT CURRENT_TIMESTAMP,
    completed_at TEXT,

    status TEXT CHECK(status IN (
        'ACTIVE',
        'COMPLETED',
        'ABANDONED'
    )),

    total_steps INTEGER DEFAULT 0,
    total_distance_m REAL DEFAULT 0,

    FOREIGN KEY (user_id) REFERENCES USER(id),
    FOREIGN KEY (start_node_id) REFERENCES NAV_NODE(id),
    FOREIGN KEY (dest_dept_id) REFERENCES DEPARTMENT(id)
);

-- =========================
-- SESSION_STEP
-- =========================
CREATE TABLE IF NOT EXISTS SESSION_STEP (
    id TEXT PRIMARY KEY,
    session_id TEXT,
    node_id TEXT,
    step_order INTEGER,
    instruction_text TEXT,
    voice_instruction TEXT,

    action_type TEXT CHECK(action_type IN (
        'STRAIGHT',
        'TURN_LEFT',
        'TURN_RIGHT',
        'TAKE_ELEVATOR',
        'TAKE_STAIRS',
        'ARRIVED'
    )),

    was_confirmed INTEGER DEFAULT 0,

    FOREIGN KEY (session_id) REFERENCES NAV_SESSION(id),
    FOREIGN KEY (node_id) REFERENCES NAV_NODE(id)
);

-- =========================
-- INDEXES
-- =========================

CREATE INDEX IF NOT EXISTS idx_nav_session_user
ON NAV_SESSION(user_id);

CREATE INDEX IF NOT EXISTS idx_nav_session_start_node
ON NAV_SESSION(start_node_id);

CREATE INDEX IF NOT EXISTS idx_nav_session_dest_dept
ON NAV_SESSION(dest_dept_id);

CREATE INDEX IF NOT EXISTS idx_session_step_session
ON SESSION_STEP(session_id);

CREATE INDEX IF NOT EXISTS idx_session_step_node
ON SESSION_STEP(node_id);