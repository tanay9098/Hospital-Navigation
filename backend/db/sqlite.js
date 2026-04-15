/**
 * SQLite database initialiser.
 *
 * Opens (or creates) hospital.db in backend/data/ and ensures all tables
 * and indexes exist before the server starts accepting requests.
 *
 * JSON columns store arrays / nested objects that can't be flattened
 * into a flat table cleanly (connections, specialties, workingHours,
 * cachedRoute).
 */

const Database = require('better-sqlite3');
const path     = require('path');
const fs       = require('fs');

const DB_DIR  = path.join(__dirname, '../data');
const DB_FILE = path.join(DB_DIR, 'hospital.db');

let _db = null;

/**
 * Open the database and run migrations.
 * Called once from configs/database.js at startup.
 */
function init() {
  fs.mkdirSync(DB_DIR, { recursive: true });

  _db = new Database(DB_FILE);

  // WAL mode: better concurrent read performance
  _db.pragma('journal_mode = WAL');
  _db.pragma('foreign_keys = ON');

  _db.exec(`
    CREATE TABLE IF NOT EXISTS locations (
      id             TEXT PRIMARY KEY,        -- same as "code"
      code           TEXT NOT NULL UNIQUE,
      name           TEXT NOT NULL,
      floor          INTEGER NOT NULL,
      type           TEXT NOT NULL,
      category       TEXT NOT NULL,
      description    TEXT NOT NULL DEFAULT '',
      coordinates    TEXT NOT NULL DEFAULT '{"x":0,"y":0}',  -- JSON {x,y}
      connections    TEXT NOT NULL DEFAULT '[]',              -- JSON
      is_accessible  INTEGER NOT NULL DEFAULT 1,  -- boolean 0/1
      ivr_menu_num   INTEGER,
      is_active      INTEGER NOT NULL DEFAULT 1,
      created_at     TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at     TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS departments (
      id              TEXT PRIMARY KEY,
      name            TEXT NOT NULL,
      short_name      TEXT,
      location_code   TEXT NOT NULL,
      floor           INTEGER NOT NULL,
      description     TEXT NOT NULL DEFAULT '',
      specialties     TEXT NOT NULL DEFAULT '[]',   -- JSON array
      contact_number  TEXT NOT NULL DEFAULT '',
      working_hours   TEXT NOT NULL DEFAULT '{"weekdays":"8:00 AM – 6:00 PM","weekends":"9:00 AM – 1:00 PM","is24x7":false}',  -- JSON
      ivr_menu_num    INTEGER,
      is_active       INTEGER NOT NULL DEFAULT 1,
      created_at      TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at      TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS ivr_sessions (
      call_sid                TEXT PRIMARY KEY,
      caller_phone            TEXT NOT NULL DEFAULT 'unknown',
      state                   TEXT NOT NULL DEFAULT 'WELCOME',
      from_floor              INTEGER,
      from_location_code      TEXT,
      to_floor                INTEGER,
      to_location_code        TEXT,
      current_direction_step  INTEGER NOT NULL DEFAULT 0,
      cached_route            TEXT,               -- JSON
      expires_at              TEXT,
      created_at              TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at              TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE INDEX IF NOT EXISTS idx_locations_floor_type  ON locations  (floor, type);
    CREATE INDEX IF NOT EXISTS idx_locations_is_active   ON locations  (is_active);
    CREATE INDEX IF NOT EXISTS idx_departments_floor     ON departments (floor);
    CREATE INDEX IF NOT EXISTS idx_departments_is_active ON departments (is_active);
    CREATE INDEX IF NOT EXISTS idx_departments_loc_code  ON departments (location_code);
    CREATE INDEX IF NOT EXISTS idx_ivr_call_sid          ON ivr_sessions (call_sid);
  `);

  return _db;
}

/** Return the open DB connection (call init() first). */
function getDB() {
  if (!_db) throw new Error('Database not initialised – call init() first.');
  return _db;
}

module.exports = { init, getDB, DB_FILE };
