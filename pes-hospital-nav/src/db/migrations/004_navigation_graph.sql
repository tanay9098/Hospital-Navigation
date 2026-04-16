-- Domain 2: Navigation Graph

-- =========================
-- LANDMARK
-- =========================
CREATE TABLE IF NOT EXISTS LANDMARK (
    id TEXT PRIMARY KEY,
    floor_id TEXT,
    name TEXT,
    type TEXT CHECK(type IN (
        'SIGNAGE',
        'KIOSK',
        'COUNTER',
        'WINDOW',
        'STAIRCASE_VISUAL',
        'EXIT_DOOR'
    )),
    x_coord REAL,
    y_coord REAL,
    description TEXT,

    FOREIGN KEY (floor_id) REFERENCES FLOOR(id)
);

-- =========================
-- NAV_NODE
-- =========================
CREATE TABLE IF NOT EXISTS NAV_NODE (
    id TEXT PRIMARY KEY,
    zone_id TEXT,
    department_id TEXT,
    label TEXT,
    node_type TEXT CHECK(node_type IN (
        'CORRIDOR_JUNCTION',
        'ELEVATOR',
        'STAIRCASE',
        'ESCALATOR',
        'DEPARTMENT_ENTRY',
        'RECEPTION',
        'EXIT',
        'RESTROOM',
        'WAITING_AREA'
    )),
    x_coord REAL,
    y_coord REAL,
    floor_number INTEGER,
    is_accessible INTEGER DEFAULT 1,
    has_elevator INTEGER DEFAULT 0,

    FOREIGN KEY (zone_id) REFERENCES ZONE(id),
    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(id)
);

-- =========================
-- NAV_EDGE
-- =========================
CREATE TABLE IF NOT EXISTS NAV_EDGE (
    id TEXT PRIMARY KEY,
    from_node_id TEXT,
    to_node_id TEXT,
    landmark_id TEXT,
    distance_m REAL,
    est_seconds INTEGER,
    edge_type TEXT CHECK(edge_type IN (
        'CORRIDOR',
        'STAIRCASE_UP',
        'STAIRCASE_DOWN',
        'ELEVATOR_UP',
        'ELEVATOR_DOWN',
        'RAMP'
    )),
    is_accessible INTEGER DEFAULT 1,
    is_bidirectional INTEGER DEFAULT 1,

    FOREIGN KEY (from_node_id) REFERENCES NAV_NODE(id),
    FOREIGN KEY (to_node_id) REFERENCES NAV_NODE(id),
    FOREIGN KEY (landmark_id) REFERENCES LANDMARK(id)
);

-- =========================
-- INDEXES
-- =========================

CREATE INDEX IF NOT EXISTS idx_landmark_floor
ON LANDMARK(floor_id);

CREATE INDEX IF NOT EXISTS idx_navnode_zone
ON NAV_NODE(zone_id);

CREATE INDEX IF NOT EXISTS idx_navnode_department
ON NAV_NODE(department_id);

CREATE INDEX IF NOT EXISTS idx_navedge_from
ON NAV_EDGE(from_node_id);

CREATE INDEX IF NOT EXISTS idx_navedge_to
ON NAV_EDGE(to_node_id);

CREATE INDEX IF NOT EXISTS idx_navedge_accessible
ON NAV_EDGE(is_accessible);