-- Multilingual voice domain

-- =========================
-- LANGUAGE
-- =========================
CREATE TABLE IF NOT EXISTS LANGUAGE (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE,
    name TEXT,
    native_name TEXT,
    tts_engine TEXT,
    tts_voice_id TEXT,
    is_active INTEGER DEFAULT 1,
    ivrs_menu_option INTEGER UNIQUE
);

-- =========================
-- VOICE_PROMPT  (static prompts: welcome, menu, error, farewell, etc.)
-- =========================
CREATE TABLE IF NOT EXISTS VOICE_PROMPT (
    id TEXT PRIMARY KEY,
    language_id TEXT,
    prompt_key TEXT,
    prompt_text TEXT,
    audio_url TEXT,

    context TEXT CHECK(context IN (
        'WELCOME',
        'LANGUAGE_MENU',
        'DEPT_MENU',
        'NOT_FOUND',
        'ERROR',
        'CONFIRMATION',
        'FAREWELL'
    )),

    last_updated TEXT DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(language_id, prompt_key),
    FOREIGN KEY (language_id) REFERENCES LANGUAGE(id)
);

-- =========================
-- DEPT_DIRECTION  (per-department, per-language landmark directions for IVRS)
-- =========================
CREATE TABLE IF NOT EXISTS DEPT_DIRECTION (
    id TEXT PRIMARY KEY,
    department_id TEXT NOT NULL,
    language_id TEXT NOT NULL,
    direction_text TEXT,
    audio_url TEXT,
    last_updated TEXT DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(department_id, language_id),
    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(id),
    FOREIGN KEY (language_id) REFERENCES LANGUAGE(id)
);

CREATE INDEX IF NOT EXISTS idx_voice_prompt_language
ON VOICE_PROMPT(language_id);

CREATE INDEX IF NOT EXISTS idx_voice_prompt_context
ON VOICE_PROMPT(context);

CREATE INDEX IF NOT EXISTS idx_dept_direction_dept
ON DEPT_DIRECTION(department_id);

CREATE INDEX IF NOT EXISTS idx_dept_direction_lang
ON DEPT_DIRECTION(language_id);
