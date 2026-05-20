-- Domain 1: Department Translations

CREATE TABLE IF NOT EXISTS DEPT_TRANSLATION (
    id TEXT PRIMARY KEY,
    department_id TEXT NOT NULL,
    language_id TEXT NOT NULL,
    name TEXT,
    short_name TEXT,
    description TEXT,
    tts_phonetic TEXT,

    UNIQUE(department_id, language_id),

    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(id)
);

-- Indexes for faster lookup
CREATE INDEX IF NOT EXISTS idx_dept_translation_department
ON DEPT_TRANSLATION(department_id);

CREATE INDEX IF NOT EXISTS idx_dept_translation_language
ON DEPT_TRANSLATION(language_id);