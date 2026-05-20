-- Domain 1: Hospital Structure

-- =========================
-- BUILDING
-- =========================
CREATE TABLE IF NOT EXISTS BUILDING (
    id TEXT PRIMARY KEY,
    name TEXT,
    address TEXT,
    total_floors INTEGER,
    lat REAL,
    lng REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- FLOOR
-- =========================
CREATE TABLE IF NOT EXISTS FLOOR (
    id TEXT PRIMARY KEY,
    building_id TEXT,
    floor_number INTEGER,
    label TEXT,
    blueprint_svg_url TEXT,
    is_active INTEGER DEFAULT 1,
    FOREIGN KEY (building_id) REFERENCES BUILDING(id)
);

-- =========================
-- ZONE
-- =========================
CREATE TABLE IF NOT EXISTS ZONE (
    id TEXT PRIMARY KEY,
    floor_id TEXT,
    name TEXT,
    type TEXT CHECK(type IN (
        'CLINICAL',
        'ADMIN',
        'EMERGENCY',
        'SUPPORT',
        'TRANSIT'
    )),
    area_sqm REAL,
    color_code TEXT,
    FOREIGN KEY (floor_id) REFERENCES FLOOR(id)
);

-- =========================
-- DEPARTMENT
-- =========================
CREATE TABLE IF NOT EXISTS DEPARTMENT (
    id TEXT PRIMARY KEY,
    zone_id TEXT,
    code TEXT,
    name TEXT,
    short_name TEXT,
    category TEXT CHECK(category IN (
        'OPD',
        'IPD',
        'EMERGENCY',
        'DIAGNOSTICS',
        'SURGICAL',
        'ADMIN',
        'SUPPORT',
        'PHARMACY'
    )),
    room_number TEXT,
    floor_number INTEGER,
    contact_ext TEXT,
    operating_hours TEXT,
    is_emergency INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    ivrs_shortcode INTEGER,
    FOREIGN KEY (zone_id) REFERENCES ZONE(id)
);

-- =========================
-- INDEXES
-- =========================

CREATE INDEX IF NOT EXISTS idx_floor_building
ON FLOOR(building_id);

CREATE INDEX IF NOT EXISTS idx_zone_floor
ON ZONE(floor_id);

CREATE INDEX IF NOT EXISTS idx_department_zone
ON DEPARTMENT(zone_id);

CREATE INDEX IF NOT EXISTS idx_department_ivrs
ON DEPARTMENT(ivrs_shortcode);