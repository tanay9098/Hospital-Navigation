-- Domain 5: Multilingual & Voice

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
-- VOICE_PROMPT
-- =========================
CREATE TABLE IF NOT EXISTS VOICE_PROMPT (
    id TEXT PRIMARY KEY,
    language_id TEXT,
    prompt_key TEXT,
    prompt_text TEXT,
    audio_url TEXT,

    context TEXT CHECK(context IN (
        'WELCOME',
        'MENU',
        'NAVIGATION',
        'ERROR',
        'CONFIRMATION',
        'FAREWELL'
    )),

    last_updated TEXT DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (language_id) REFERENCES LANGUAGE(id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_voice_prompt_language
ON VOICE_PROMPT(language_id);

CREATE INDEX IF NOT EXISTS idx_voice_prompt_context
ON VOICE_PROMPT(context);