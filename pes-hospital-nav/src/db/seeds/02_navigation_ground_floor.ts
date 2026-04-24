import db from "../db";

const ZONE = "Z_F0_C";
const FLOOR = 0;

/* ============================
   NAVIGATION NODES — Floor 0 (Ground Floor)
   Columns:
   id, zone_id, dept_id, label, node_type,
   x_coord, y_coord, floor_number,
   is_accessible, has_elevator, is_vertical, vertical_id
============================ */

const nodes: [string, string, null, string, string, number, number, number, 1, number, number, string | null][] = [

  // ── Entrance / reception rooms ───────────────────────────────────────────
  ["F0_N4",  ZONE, null, "MAIN ENTRANCE", "EXIT",              440,  940, FLOOR, 1, 0, 0, null],
  ["F0_N5",  ZONE, null, "PHARMACY",      "DEPARTMENT_ENTRY",  283,  940, FLOOR, 1, 0, 0, null],
  ["F0_N6",  ZONE, null, "CANTEEN",       "DEPARTMENT_ENTRY",  648,  940, FLOOR, 1, 0, 0, null],
  ["F0_N7",  ZONE, null, "RECEPTION A",   "RECEPTION",         360,  849, FLOOR, 1, 0, 0, null],
  ["F0_N8",  ZONE, null, "RECEPTION B",   "RECEPTION",         506,  851, FLOOR, 1, 0, 0, null],

  // ── Corridor junctions ───────────────────────────────────────────────────
  ["F0_N9",  ZONE, null, "N9",  "CORRIDOR_JUNCTION", 358, 940, FLOOR, 1, 0, 0, null],
  ["F0_N10", ZONE, null, "N10", "CORRIDOR_JUNCTION", 360, 891, FLOOR, 1, 0, 0, null],
  ["F0_N11", ZONE, null, "N11", "CORRIDOR_JUNCTION", 506, 892, FLOOR, 1, 0, 0, null],
  ["F0_N12", ZONE, null, "N12", "CORRIDOR_JUNCTION", 506, 939, FLOOR, 1, 0, 0, null],
  ["F0_N13", ZONE, null, "N13", "CORRIDOR_JUNCTION", 440, 892, FLOOR, 1, 0, 0, null],
  ["F0_N14", ZONE, null, "N14", "CORRIDOR_JUNCTION", 440, 826, FLOOR, 1, 0, 0, null],
  ["F0_N15", ZONE, null, "N15", "CORRIDOR_JUNCTION", 440, 759, FLOOR, 1, 0, 0, null],
  ["F0_N16", ZONE, null, "N16", "CORRIDOR_JUNCTION", 440, 714, FLOOR, 1, 0, 0, null],
  ["F0_N17", ZONE, null, "N17", "CORRIDOR_JUNCTION", 440, 594, FLOOR, 1, 0, 0, null],
  ["F0_N18", ZONE, null, "N18", "CORRIDOR_JUNCTION", 440, 545, FLOOR, 1, 0, 0, null],
  ["F0_N19", ZONE, null, "N19", "CORRIDOR_JUNCTION", 526, 545, FLOOR, 1, 0, 0, null],
  ["F0_N20", ZONE, null, "N20", "CORRIDOR_JUNCTION", 358, 545, FLOOR, 1, 0, 0, null],
  ["F0_N21", ZONE, null, "N21", "CORRIDOR_JUNCTION", 358, 505, FLOOR, 1, 0, 0, null],
  ["F0_N23", ZONE, null, "N23", "CORRIDOR_JUNCTION", 438, 465, FLOOR, 1, 0, 0, null],
  ["F0_N25", ZONE, null, "N25", "CORRIDOR_JUNCTION", 526, 503, FLOOR, 1, 0, 0, null],
  ["F0_N30", ZONE, null, "N30", "CORRIDOR_JUNCTION", 438, 423, FLOOR, 1, 0, 0, null],
  ["F0_N32", ZONE, null, "N32", "CORRIDOR_JUNCTION", 438, 312, FLOOR, 1, 0, 0, null],
  ["F0_N33", ZONE, null, "N33", "CORRIDOR_JUNCTION", 438, 246, FLOOR, 1, 0, 0, null],
  ["F0_N34", ZONE, null, "N34", "CORRIDOR_JUNCTION", 497, 246, FLOOR, 1, 0, 0, null],
  ["F0_N35", ZONE, null, "N35", "CORRIDOR_JUNCTION", 549, 246, FLOOR, 1, 0, 0, null],
  ["F0_N36", ZONE, null, "N36", "CORRIDOR_JUNCTION", 607, 246, FLOOR, 1, 0, 0, null],
  ["F0_N38", ZONE, null, "N38", "CORRIDOR_JUNCTION", 712, 246, FLOOR, 1, 0, 0, null],
  ["F0_N39", ZONE, null, "N39", "CORRIDOR_JUNCTION", 645, 246, FLOOR, 1, 0, 0, null],
  ["F0_N40", ZONE, null, "N40", "CORRIDOR_JUNCTION", 645, 353, FLOOR, 1, 0, 0, null],
  ["F0_N41", ZONE, null, "N41", "CORRIDOR_JUNCTION", 645, 441, FLOOR, 1, 0, 0, null],
  ["F0_N42", ZONE, null, "N42", "CORRIDOR_JUNCTION", 645, 520, FLOOR, 1, 0, 0, null],
  ["F0_N43", ZONE, null, "N43", "CORRIDOR_JUNCTION", 645, 603, FLOOR, 1, 0, 0, null],
  ["F0_N44", ZONE, null, "N44", "CORRIDOR_JUNCTION", 645, 678, FLOOR, 1, 0, 0, null],
  ["F0_N45", ZONE, null, "N45", "CORRIDOR_JUNCTION", 645, 761, FLOOR, 1, 0, 0, null],
  ["F0_N46", ZONE, null, "N46", "CORRIDOR_JUNCTION", 742, 246, FLOOR, 1, 0, 0, null],
  ["F0_N47", ZONE, null, "N47", "CORRIDOR_JUNCTION", 799, 174, FLOOR, 1, 0, 0, null],
  ["F0_N50", ZONE, null, "N50", "CORRIDOR_JUNCTION", 742, 306, FLOOR, 1, 0, 0, null],
  ["F0_N51", ZONE, null, "N51", "CORRIDOR_JUNCTION", 742, 394, FLOOR, 1, 0, 0, null],
  ["F0_N52", ZONE, null, "N52", "CORRIDOR_JUNCTION", 742, 441, FLOOR, 1, 0, 0, null],
  ["F0_N53", ZONE, null, "N53", "CORRIDOR_JUNCTION", 742, 499, FLOOR, 1, 0, 0, null],
  ["F0_N54", ZONE, null, "N54", "CORRIDOR_JUNCTION", 742, 552, FLOOR, 1, 0, 0, null],
  ["F0_N55", ZONE, null, "N55", "CORRIDOR_JUNCTION", 742, 614, FLOOR, 1, 0, 0, null],
  ["F0_N58", ZONE, null, "N58", "CORRIDOR_JUNCTION", 702, 761, FLOOR, 1, 0, 0, null],
  ["F0_N59", ZONE, null, "N59", "CORRIDOR_JUNCTION", 759, 761, FLOOR, 1, 0, 0, null],
  ["F0_N60", ZONE, null, "N60", "CORRIDOR_JUNCTION", 795, 761, FLOOR, 1, 0, 0, null],
  ["F0_N61", ZONE, null, "N61", "CORRIDOR_JUNCTION", 793, 614, FLOOR, 1, 0, 0, null],
  ["F0_N62", ZONE, null, "N62", "CORRIDOR_JUNCTION", 579, 761, FLOOR, 1, 0, 0, null],
  ["F0_N63", ZONE, null, "N63", "CORRIDOR_JUNCTION", 492, 759, FLOOR, 1, 0, 0, null],
  ["F0_N64", ZONE, null, "N64", "CORRIDOR_JUNCTION", 796, 501, FLOOR, 1, 0, 0, null],
  ["F0_N65", ZONE, null, "N65", "CORRIDOR_JUNCTION", 850, 501, FLOOR, 1, 0, 0, null],
  ["F0_N67", ZONE, null, "N67", "CORRIDOR_JUNCTION", 853, 389, FLOOR, 1, 0, 0, null],
  ["F0_N69", ZONE, null, "N69", "CORRIDOR_JUNCTION", 437, 385, FLOOR, 1, 0, 0, null],

  // ── Diagnostic rooms ─────────────────────────────────────────────────────
  ["F0_N48", ZONE, null, "ULTRASONIC",   "DEPARTMENT_ENTRY", 798,  79, FLOOR, 1, 0, 0, null],
  ["F0_N57", ZONE, null, "X-RAY",        "DEPARTMENT_ENTRY", 798, 902, FLOOR, 1, 0, 0, null],
  ["F0_N66", ZONE, null, "MRI",          "DEPARTMENT_ENTRY", 828, 389, FLOOR, 1, 0, 0, null],

  // ── Waiting areas ────────────────────────────────────────────────────────
  ["F0_N49", ZONE, null, "WAITING AREA", "WAITING_AREA",     798, 227, FLOOR, 1, 0, 0, null],
  ["F0_N56", ZONE, null, "WAITING AREA", "WAITING_AREA",     813, 680, FLOOR, 1, 0, 0, null],

  // ── Restrooms ────────────────────────────────────────────────────────────
  ["F0_N70", ZONE, null, "TOILET FEMALE", "RESTROOM", 365, 389, FLOOR, 1, 0, 0, null],
  ["F0_N71", ZONE, null, "TOILET MALE",   "RESTROOM", 515, 386, FLOOR, 1, 0, 0, null],

  // ── Lifts (vertical connectors) ──────────────────────────────────────────
  ["F0_N22", ZONE, null, "LIFT 2", "ELEVATOR", 358, 465, FLOOR, 1, 1, 1, "F0_V_LIFT_2"],
  ["F0_N24", ZONE, null, "LIFT 3", "ELEVATOR", 526, 462, FLOOR, 1, 1, 1, "F0_V_LIFT_3"],
  ["F0_N29", ZONE, null, "LIFT 1", "ELEVATOR", 526, 714, FLOOR, 1, 1, 1, "F0_V_LIFT_1"],

  // ── Stairs (vertical connectors) ─────────────────────────────────────────
  ["F0_N27", ZONE, null, "STAIRS 2", "STAIRCASE", 493, 594, FLOOR, 1, 0, 1, "F0_V_STAIRS_2"],
  ["F0_N28", ZONE, null, "STAIRS 1", "STAIRCASE", 393, 714, FLOOR, 1, 0, 1, "F0_V_STAIRS_1"],

  // ── Ramp (vertical connector) ────────────────────────────────────────────
  ["F0_N26", ZONE, null, "RAMP", "RAMP", 387, 594, FLOOR, 1, 1, 1, "F0_V_RAMP_1"],
];

const insertNode = db.prepare(`
INSERT OR IGNORE INTO NAV_NODE
  (id, zone_id, department_id, label, node_type,
   x_coord, y_coord, floor_number,
   is_accessible, has_elevator, is_vertical, vertical_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`);

const insertNodes = db.transaction(() => nodes.forEach(n => insertNode.run(...n)));
insertNodes();
console.log(`Inserted ${nodes.length} Floor 0 (Ground) nodes.`);


/* ============================
   NAVIGATION EDGES — Floor 0 (Ground Floor)
   Columns:
   id, from_node_id, to_node_id, landmark_id,
   distance_m, est_seconds, edge_type,
   is_accessible, is_bidirectional

   est_seconds ≈ distance_m / 1.0  (≈1 m/s hospital walking pace)
============================ */

const edges: [string, string, string, null, number, number, string, 1, 1][] = [
  // id            from          to            lm   dist  sec   type         acc  bi
  ["F0_E1",  "F0_N5",  "F0_N9",  null,  9.7, 10, "CORRIDOR", 1, 1],
  ["F0_E2",  "F0_N4",  "F0_N9",  null, 10.6, 11, "CORRIDOR", 1, 1],
  ["F0_E3",  "F0_N4",  "F0_N12", null,  8.5,  9, "CORRIDOR", 1, 1],
  ["F0_E4",  "F0_N12", "F0_N6",  null, 18.3, 18, "CORRIDOR", 1, 1],
  ["F0_E5",  "F0_N12", "F0_N11", null,  6.1,  6, "CORRIDOR", 1, 1],
  ["F0_E6",  "F0_N11", "F0_N8",  null,  5.3,  5, "CORRIDOR", 1, 1],
  ["F0_E7",  "F0_N9",  "F0_N10", null,  6.3,  6, "CORRIDOR", 1, 1],
  ["F0_E8",  "F0_N10", "F0_N7",  null,  5.4,  5, "CORRIDOR", 1, 1],
  ["F0_E9",  "F0_N9",  "F0_N13", null, 12.3, 12, "CORRIDOR", 1, 1],
  ["F0_E10", "F0_N13", "F0_N14", null,  8.5,  9, "CORRIDOR", 1, 1],
  ["F0_E11", "F0_N12", "F0_N13", null, 10.4, 10, "CORRIDOR", 1, 1],
  ["F0_E12", "F0_N14", "F0_N15", null,  8.6,  9, "CORRIDOR", 1, 1],
  ["F0_E13", "F0_N15", "F0_N16", null,  5.8,  6, "CORRIDOR", 1, 1],
  ["F0_E14", "F0_N16", "F0_N17", null, 15.5, 16, "CORRIDOR", 1, 1],
  ["F0_E15", "F0_N17", "F0_N18", null,  6.3,  6, "CORRIDOR", 1, 1],
  ["F0_E16", "F0_N18", "F0_N20", null, 10.6, 11, "CORRIDOR", 1, 1],
  ["F0_E17", "F0_N20", "F0_N21", null,  5.2,  5, "CORRIDOR", 1, 1],
  ["F0_E18", "F0_N21", "F0_N22", null,  5.2,  5, "CORRIDOR", 1, 1],
  ["F0_E19", "F0_N18", "F0_N19", null, 11.1, 11, "CORRIDOR", 1, 1],
  ["F0_E20", "F0_N19", "F0_N25", null,  5.4,  5, "CORRIDOR", 1, 1],
  ["F0_E21", "F0_N25", "F0_N24", null,  5.3,  5, "CORRIDOR", 1, 1],
  ["F0_E22", "F0_N17", "F0_N27", null,  6.8,  7, "CORRIDOR", 1, 1],
  ["F0_E23", "F0_N17", "F0_N26", null,  6.8,  7, "CORRIDOR", 1, 1],
  ["F0_E24", "F0_N22", "F0_N23", null, 10.3, 10, "CORRIDOR", 1, 1],
  ["F0_E25", "F0_N23", "F0_N24", null, 11.4, 11, "CORRIDOR", 1, 1],
  ["F0_E26", "F0_N23", "F0_N30", null,  5.4,  5, "CORRIDOR", 1, 1],
  ["F0_E29", "F0_N32", "F0_N33", null,  8.5,  9, "CORRIDOR", 1, 1],
  ["F0_E30", "F0_N33", "F0_N34", null,  7.6,  8, "CORRIDOR", 1, 1],
  ["F0_E31", "F0_N34", "F0_N35", null,  6.7,  7, "CORRIDOR", 1, 1],
  ["F0_E32", "F0_N35", "F0_N36", null,  7.5,  8, "CORRIDOR", 1, 1],
  ["F0_E33", "F0_N36", "F0_N39", null,  4.9,  5, "CORRIDOR", 1, 1],
  ["F0_E34", "F0_N39", "F0_N38", null,  8.6,  9, "CORRIDOR", 1, 1],
  ["F0_E35", "F0_N38", "F0_N46", null,  3.9,  4, "CORRIDOR", 1, 1],
  ["F0_E36", "F0_N46", "F0_N49", null,  7.6,  8, "CORRIDOR", 1, 1],
  ["F0_E37", "F0_N46", "F0_N50", null,  7.7,  8, "CORRIDOR", 1, 1],
  ["F0_E38", "F0_N50", "F0_N51", null, 11.3, 11, "CORRIDOR", 1, 1],
  ["F0_E39", "F0_N51", "F0_N52", null,  6.1,  6, "CORRIDOR", 1, 1],
  ["F0_E40", "F0_N52", "F0_N53", null,  7.5,  8, "CORRIDOR", 1, 1],
  ["F0_E41", "F0_N53", "F0_N54", null,  6.8,  7, "CORRIDOR", 1, 1],
  ["F0_E42", "F0_N54", "F0_N55", null,  8.0,  8, "CORRIDOR", 1, 1],
  ["F0_E43", "F0_N55", "F0_N61", null,  6.6,  7, "CORRIDOR", 1, 1],
  ["F0_E44", "F0_N49", "F0_N47", null,  6.8,  7, "CORRIDOR", 1, 1],
  ["F0_E45", "F0_N47", "F0_N48", null, 12.3, 12, "CORRIDOR", 1, 1],
  ["F0_E46", "F0_N61", "F0_N56", null,  8.9,  9, "CORRIDOR", 1, 1],
  ["F0_E47", "F0_N56", "F0_N60", null, 10.7, 11, "CORRIDOR", 1, 1],
  ["F0_E48", "F0_N60", "F0_N59", null,  4.6,  5, "CORRIDOR", 1, 1],
  ["F0_E49", "F0_N59", "F0_N58", null,  7.4,  7, "CORRIDOR", 1, 1],
  ["F0_E50", "F0_N58", "F0_N45", null,  7.4,  7, "CORRIDOR", 1, 1],
  ["F0_E51", "F0_N45", "F0_N62", null,  8.5,  9, "CORRIDOR", 1, 1],
  ["F0_E52", "F0_N62", "F0_N63", null, 11.2, 11, "CORRIDOR", 1, 1],
  ["F0_E53", "F0_N63", "F0_N15", null,  6.7,  7, "CORRIDOR", 1, 1],
  ["F0_E54", "F0_N39", "F0_N40", null, 13.8, 14, "CORRIDOR", 1, 1],
  ["F0_E55", "F0_N40", "F0_N41", null, 11.3, 11, "CORRIDOR", 1, 1],
  ["F0_E56", "F0_N41", "F0_N42", null, 10.2, 10, "CORRIDOR", 1, 1],
  ["F0_E57", "F0_N42", "F0_N43", null, 10.7, 11, "CORRIDOR", 1, 1],
  ["F0_E58", "F0_N43", "F0_N44", null,  9.7, 10, "CORRIDOR", 1, 1],
  ["F0_E59", "F0_N44", "F0_N45", null, 10.7, 11, "CORRIDOR", 1, 1],
  ["F0_E60", "F0_N60", "F0_N57", null, 18.2, 18, "CORRIDOR", 1, 1],
  ["F0_E61", "F0_N53", "F0_N64", null,  7.0,  7, "CORRIDOR", 1, 1],
  ["F0_E62", "F0_N64", "F0_N65", null,  7.0,  7, "CORRIDOR", 1, 1],
  ["F0_E63", "F0_N65", "F0_N67", null, 14.4, 14, "CORRIDOR", 1, 1],
  ["F0_E64", "F0_N67", "F0_N66", null,  3.2,  3, "CORRIDOR", 1, 1],
  ["F0_E65", "F0_N28", "F0_N16", null,  6.1,  6, "CORRIDOR", 1, 1],
  ["F0_E66", "F0_N16", "F0_N29", null, 11.1, 11, "CORRIDOR", 1, 1],
  ["F0_E67", "F0_N30", "F0_N69", null,  4.9,  5, "CORRIDOR", 1, 1],
  ["F0_E68", "F0_N69", "F0_N32", null,  9.4,  9, "CORRIDOR", 1, 1],
  ["F0_E69", "F0_N69", "F0_N71", null, 10.1, 10, "CORRIDOR", 1, 1],
  ["F0_E70", "F0_N69", "F0_N70", null,  9.3,  9, "CORRIDOR", 1, 1],
];

const insertEdge = db.prepare(`
INSERT OR IGNORE INTO NAV_EDGE
  (id, from_node_id, to_node_id, landmark_id,
   distance_m, est_seconds, edge_type,
   is_accessible, is_bidirectional)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
`);

const insertEdges = db.transaction(() => edges.forEach(e => insertEdge.run(...e)));
insertEdges();
console.log(`Inserted ${edges.length} Floor 0 (Ground) edges.`);
console.log("Ground floor navigation graph seeded.");
