import db from "../db";

const ZONE = "Z_F2_C";
const FLOOR = 2;

/* ============================
   NAVIGATION NODES — Floor 2
   Columns:
   id, zone_id, dept_id, label, node_type,
   x_coord, y_coord, floor_number,
   is_accessible, has_elevator, is_vertical, vertical_id
============================ */

const nodes: [string, string, null, string, string, number, number, number, 1, number, number, string | null][] = [

  // ── Anomalous / off-canvas node (kept as-is from source JSON) ───────────
  ["F2_N1",  ZONE, null, "rect118",                              "DEPARTMENT_ENTRY",  562,  -794, FLOOR, 1, 0, 0, null],

  // ── Named rooms ─────────────────────────────────────────────────────────
  ["F2_N2",  ZONE, null, "ENT OPD",                             "DEPARTMENT_ENTRY",  191,   830, FLOOR, 1, 0, 0, null],
  ["F2_N10", ZONE, null, "DERMATOLOGY OPD",                     "DEPARTMENT_ENTRY",  190,   358, FLOOR, 1, 0, 0, null],
  ["F2_N20", ZONE, null, "OPTHAMOLOGY WARD MALE",               "DEPARTMENT_ENTRY",  186,   147, FLOOR, 1, 0, 0, null],
  ["F2_N29", ZONE, null, "DVL WARD",                            "DEPARTMENT_ENTRY",  434,    71, FLOOR, 1, 0, 0, null],
  ["F2_N30", ZONE, null, "OPTHAMOLOGY WARD FEMALE",             "DEPARTMENT_ENTRY",  642,    70, FLOOR, 1, 0, 0, null],
  ["F2_N36", ZONE, null, "PSYCOLOGY WARD",                      "DEPARTMENT_ENTRY",  831,   168, FLOOR, 1, 0, 0, null],
  ["F2_N63", ZONE, null, "PSYCIATRY OPD",                       "DEPARTMENT_ENTRY",  693,   909, FLOOR, 1, 0, 0, null],
  ["F2_N66", ZONE, null, "OPTHAMOLOGY OPD",                     "DEPARTMENT_ENTRY",  509,   968, FLOOR, 1, 0, 0, null],
  ["F2_N69", ZONE, null, "OPTHAMOLOGY OT COMPLEX",              "DEPARTMENT_ENTRY",  722,   319, FLOOR, 1, 0, 0, null],
  ["F2_N70", ZONE, null, "CENTRAL LABORATORY,BLOOD CENTER,ICTC","DEPARTMENT_ENTRY",  655,   500, FLOOR, 1, 0, 0, null],
  ["F2_N73", ZONE, null, "TOILET FEMALE",                       "RESTROOM",          477,   364, FLOOR, 1, 0, 0, null],
  ["F2_N74", ZONE, null, "TOILET MALE",                         "RESTROOM",          600,   364, FLOOR, 1, 0, 0, null],

  // ── Vertical connectors ──────────────────────────────────────────────────
  ["F2_N40", ZONE, null, "LIFT 2",   "ELEVATOR",  456, 449, FLOOR, 1, 1, 1, "F2_V_LIFT_2"],
  ["F2_N41", ZONE, null, "LIFT 3",   "ELEVATOR",  617, 449, FLOOR, 1, 1, 1, "F2_V_LIFT_3"],
  ["F2_N50", ZONE, null, "STAIRS 1", "STAIRCASE", 456, 703, FLOOR, 1, 0, 1, "F2_V_STAIRS_1"],
  ["F2_N51", ZONE, null, "LIFT 1",   "ELEVATOR",  617, 703, FLOOR, 1, 1, 1, "F2_V_LIFT_1"],
  ["F2_N71", ZONE, null, "RAMP",     "RAMP",      456, 581, FLOOR, 1, 0, 1, "F2_V_RAMP_1"],
  ["F2_N72", ZONE, null, "STAIRS 2", "STAIRCASE", 617, 580, FLOOR, 1, 0, 1, "F2_V_STAIRS_2"],

  // ── Corridor junctions ──────────────────────────────────────────────────
  ["F2_N3",  ZONE, null, "F2_N3",  "CORRIDOR_JUNCTION", 191, 748, FLOOR, 1, 0, 0, null],
  ["F2_N4",  ZONE, null, "F2_N4",  "CORRIDOR_JUNCTION", 218, 748, FLOOR, 1, 0, 0, null],
  ["F2_N5",  ZONE, null, "F2_N5",  "CORRIDOR_JUNCTION", 237, 748, FLOOR, 1, 0, 0, null],
  ["F2_N6",  ZONE, null, "F2_N6",  "CORRIDOR_JUNCTION", 237, 714, FLOOR, 1, 0, 0, null],
  ["F2_N7",  ZONE, null, "F2_N7",  "CORRIDOR_JUNCTION", 237, 674, FLOOR, 1, 0, 0, null],
  ["F2_N8",  ZONE, null, "F2_N8",  "CORRIDOR_JUNCTION", 237, 626, FLOOR, 1, 0, 0, null],
  ["F2_N9",  ZONE, null, "F2_N9",  "CORRIDOR_JUNCTION", 237, 572, FLOOR, 1, 0, 0, null],
  ["F2_N12", ZONE, null, "F2_N12", "CORRIDOR_JUNCTION", 241, 420, FLOOR, 1, 0, 0, null],
  ["F2_N13", ZONE, null, "F2_N13", "CORRIDOR_JUNCTION", 241, 377, FLOOR, 1, 0, 0, null],
  ["F2_N14", ZONE, null, "F2_N14", "CORRIDOR_JUNCTION", 241, 328, FLOOR, 1, 0, 0, null],
  ["F2_N15", ZONE, null, "F2_N15", "CORRIDOR_JUNCTION", 241, 292, FLOOR, 1, 0, 0, null],
  ["F2_N16", ZONE, null, "F2_N16", "CORRIDOR_JUNCTION", 241, 255, FLOOR, 1, 0, 0, null],
  ["F2_N17", ZONE, null, "F2_N17", "CORRIDOR_JUNCTION", 241, 234, FLOOR, 1, 0, 0, null],
  ["F2_N18", ZONE, null, "F2_N18", "CORRIDOR_JUNCTION", 241, 213, FLOOR, 1, 0, 0, null],
  ["F2_N19", ZONE, null, "F2_N19", "CORRIDOR_JUNCTION", 295, 234, FLOOR, 1, 0, 0, null],
  ["F2_N21", ZONE, null, "F2_N21", "CORRIDOR_JUNCTION", 351, 234, FLOOR, 1, 0, 0, null],
  ["F2_N22", ZONE, null, "F2_N22", "CORRIDOR_JUNCTION", 405, 234, FLOOR, 1, 0, 0, null],
  ["F2_N23", ZONE, null, "F2_N23", "CORRIDOR_JUNCTION", 460, 234, FLOOR, 1, 0, 0, null],
  ["F2_N24", ZONE, null, "F2_N24", "CORRIDOR_JUNCTION", 537, 234, FLOOR, 1, 0, 0, null],
  ["F2_N25", ZONE, null, "F2_N25", "CORRIDOR_JUNCTION", 537, 177, FLOOR, 1, 0, 0, null],
  ["F2_N26", ZONE, null, "F2_N26", "CORRIDOR_JUNCTION", 537, 114, FLOOR, 1, 0, 0, null],
  ["F2_N27", ZONE, null, "F2_N27", "CORRIDOR_JUNCTION", 516, 114, FLOOR, 1, 0, 0, null],
  ["F2_N28", ZONE, null, "F2_N28", "CORRIDOR_JUNCTION", 556, 114, FLOOR, 1, 0, 0, null],
  ["F2_N31", ZONE, null, "F2_N31", "CORRIDOR_JUNCTION", 602, 234, FLOOR, 1, 0, 0, null],
  ["F2_N32", ZONE, null, "F2_N32", "CORRIDOR_JUNCTION", 656, 234, FLOOR, 1, 0, 0, null],
  ["F2_N33", ZONE, null, "F2_N33", "CORRIDOR_JUNCTION", 722, 234, FLOOR, 1, 0, 0, null],
  ["F2_N34", ZONE, null, "F2_N34", "CORRIDOR_JUNCTION", 779, 234, FLOOR, 1, 0, 0, null],
  ["F2_N35", ZONE, null, "F2_N35", "CORRIDOR_JUNCTION", 831, 234, FLOOR, 1, 0, 0, null],
  ["F2_N37", ZONE, null, "F2_N37", "CORRIDOR_JUNCTION", 537, 295, FLOOR, 1, 0, 0, null],
  ["F2_N38", ZONE, null, "F2_N38", "CORRIDOR_JUNCTION", 535, 364, FLOOR, 1, 0, 0, null],
  ["F2_N39", ZONE, null, "F2_N39", "CORRIDOR_JUNCTION", 535, 449, FLOOR, 1, 0, 0, null],
  ["F2_N42", ZONE, null, "F2_N42", "CORRIDOR_JUNCTION", 456, 497, FLOOR, 1, 0, 0, null],
  ["F2_N43", ZONE, null, "F2_N43", "CORRIDOR_JUNCTION", 617, 500, FLOOR, 1, 0, 0, null],
  ["F2_N44", ZONE, null, "F2_N44", "CORRIDOR_JUNCTION", 456, 539, FLOOR, 1, 0, 0, null],
  ["F2_N45", ZONE, null, "F2_N45", "CORRIDOR_JUNCTION", 617, 539, FLOOR, 1, 0, 0, null],
  ["F2_N46", ZONE, null, "F2_N46", "CORRIDOR_JUNCTION", 534, 539, FLOOR, 1, 0, 0, null],
  ["F2_N47", ZONE, null, "F2_N47", "CORRIDOR_JUNCTION", 534, 584, FLOOR, 1, 0, 0, null],
  ["F2_N48", ZONE, null, "F2_N48", "CORRIDOR_JUNCTION", 533, 646, FLOOR, 1, 0, 0, null],
  ["F2_N49", ZONE, null, "F2_N49", "CORRIDOR_JUNCTION", 535, 703, FLOOR, 1, 0, 0, null],
  ["F2_N52", ZONE, null, "F2_N52", "CORRIDOR_JUNCTION", 290, 748, FLOOR, 1, 0, 0, null],
  ["F2_N53", ZONE, null, "F2_N53", "CORRIDOR_JUNCTION", 358, 748, FLOOR, 1, 0, 0, null],
  ["F2_N54", ZONE, null, "F2_N54", "CORRIDOR_JUNCTION", 418, 748, FLOOR, 1, 0, 0, null],
  ["F2_N55", ZONE, null, "F2_N55", "CORRIDOR_JUNCTION", 535, 747, FLOOR, 1, 0, 0, null],
  ["F2_N56", ZONE, null, "F2_N56", "CORRIDOR_JUNCTION", 241, 496, FLOOR, 1, 0, 0, null],
  ["F2_N57", ZONE, null, "F2_N57", "CORRIDOR_JUNCTION", 289, 496, FLOOR, 1, 0, 0, null],
  ["F2_N58", ZONE, null, "F2_N58", "CORRIDOR_JUNCTION", 346, 496, FLOOR, 1, 0, 0, null],
  ["F2_N59", ZONE, null, "F2_N59", "CORRIDOR_JUNCTION", 409, 497, FLOOR, 1, 0, 0, null],
  ["F2_N60", ZONE, null, "F2_N60", "CORRIDOR_JUNCTION", 617, 749, FLOOR, 1, 0, 0, null],
  ["F2_N61", ZONE, null, "F2_N61", "CORRIDOR_JUNCTION", 718, 749, FLOOR, 1, 0, 0, null],
  ["F2_N62", ZONE, null, "F2_N62", "CORRIDOR_JUNCTION", 718, 830, FLOOR, 1, 0, 0, null],
  ["F2_N64", ZONE, null, "F2_N64", "CORRIDOR_JUNCTION", 535, 828, FLOOR, 1, 0, 0, null],
  ["F2_N65", ZONE, null, "F2_N65", "CORRIDOR_JUNCTION", 535, 872, FLOOR, 1, 0, 0, null],
  ["F2_N67", ZONE, null, "F2_N67", "CORRIDOR_JUNCTION",   0, 748, FLOOR, 1, 0, 0, null],
];

/* ============================
   NAVIGATION EDGES — Floor 2
   Columns:
   id, from_node_id, to_node_id, landmark_id,
   distance_m, est_seconds, edge_type,
   is_accessible, is_bidirectional
   Note: edge IDs in source JSON have no floor prefix ("E1") — "F2_" added here.
         from/to fields in source JSON already carry "F2_" prefix.
============================ */

const edges: [string, string, string, null, number, number, string, 1, 1][] = [
  ["F2_E1",  "F2_N20", "F2_N18",  null,  9.5, Math.round( 9.5), "CORRIDOR", 1, 1],
  ["F2_E2",  "F2_N18", "F2_N17",  null,  2.3, Math.round( 2.3), "CORRIDOR", 1, 1],
  ["F2_E3",  "F2_N17", "F2_N19",  null,  6.0, Math.round( 6.0), "CORRIDOR", 1, 1],
  ["F2_E4",  "F2_N17", "F2_N16",  null,  2.3, Math.round( 2.3), "CORRIDOR", 1, 1],
  ["F2_E5",  "F2_N16", "F2_N15",  null,  4.1, Math.round( 4.1), "CORRIDOR", 1, 1],
  ["F2_E6",  "F2_N15", "F2_N14",  null,  4.0, Math.round( 4.0), "CORRIDOR", 1, 1],
  ["F2_E7",  "F2_N14", "F2_N10",  null,  6.6, Math.round( 6.6), "CORRIDOR", 1, 1],
  ["F2_E8",  "F2_N14", "F2_N13",  null,  5.4, Math.round( 5.4), "CORRIDOR", 1, 1],
  ["F2_E9",  "F2_N13", "F2_N10",  null,  6.0, Math.round( 6.0), "CORRIDOR", 1, 1],
  ["F2_E10", "F2_N13", "F2_N12",  null,  4.8, Math.round( 4.8), "CORRIDOR", 1, 1],
  ["F2_E11", "F2_N12", "F2_N56",  null,  8.4, Math.round( 8.4), "CORRIDOR", 1, 1],
  ["F2_E12", "F2_N19", "F2_N21",  null,  6.2, Math.round( 6.2), "CORRIDOR", 1, 1],
  ["F2_E13", "F2_N21", "F2_N22",  null,  6.0, Math.round( 6.0), "CORRIDOR", 1, 1],
  ["F2_E14", "F2_N22", "F2_N23",  null,  6.1, Math.round( 6.1), "CORRIDOR", 1, 1],
  ["F2_E15", "F2_N23", "F2_N24",  null,  8.6, Math.round( 8.6), "CORRIDOR", 1, 1],
  ["F2_E16", "F2_N24", "F2_N31",  null,  7.2, Math.round( 7.2), "CORRIDOR", 1, 1],
  ["F2_E17", "F2_N31", "F2_N32",  null,  6.0, Math.round( 6.0), "CORRIDOR", 1, 1],
  ["F2_E18", "F2_N32", "F2_N33",  null,  7.3, Math.round( 7.3), "CORRIDOR", 1, 1],
  ["F2_E19", "F2_N33", "F2_N34",  null,  6.3, Math.round( 6.3), "CORRIDOR", 1, 1],
  ["F2_E20", "F2_N34", "F2_N35",  null,  5.8, Math.round( 5.8), "CORRIDOR", 1, 1],
  ["F2_E21", "F2_N35", "F2_N36",  null,  7.3, Math.round( 7.3), "CORRIDOR", 1, 1],
  ["F2_E22", "F2_N33", "F2_N69",  null,  9.4, Math.round( 9.4), "CORRIDOR", 1, 1],
  ["F2_E23", "F2_N24", "F2_N25",  null,  6.3, Math.round( 6.3), "CORRIDOR", 1, 1],
  ["F2_E24", "F2_N25", "F2_N26",  null,  7.0, Math.round( 7.0), "CORRIDOR", 1, 1],
  ["F2_E25", "F2_N26", "F2_N28",  null,  2.1, Math.round( 2.1), "CORRIDOR", 1, 1],
  ["F2_E26", "F2_N28", "F2_N30",  null, 10.7, Math.round(10.7), "CORRIDOR", 1, 1],
  ["F2_E27", "F2_N27", "F2_N26",  null,  2.3, Math.round( 2.3), "CORRIDOR", 1, 1],
  ["F2_E28", "F2_N27", "F2_N29",  null, 10.3, Math.round(10.3), "CORRIDOR", 1, 1],
  ["F2_E29", "F2_N56", "F2_N57",  null,  5.3, Math.round( 5.3), "CORRIDOR", 1, 1],
  ["F2_E30", "F2_N57", "F2_N58",  null,  6.3, Math.round( 6.3), "CORRIDOR", 1, 1],
  ["F2_E31", "F2_N58", "F2_N59",  null,  7.0, Math.round( 7.0), "CORRIDOR", 1, 1],
  ["F2_E32", "F2_N59", "F2_N42",  null,  5.2, Math.round( 5.2), "CORRIDOR", 1, 1],
  ["F2_E33", "F2_N42", "F2_N40",  null,  5.3, Math.round( 5.3), "CORRIDOR", 1, 1],
  ["F2_E34", "F2_N40", "F2_N39",  null,  8.8, Math.round( 8.8), "CORRIDOR", 1, 1],
  ["F2_E35", "F2_N39", "F2_N41",  null,  9.1, Math.round( 9.1), "CORRIDOR", 1, 1],
  ["F2_E36", "F2_N41", "F2_N43",  null,  5.7, Math.round( 5.7), "CORRIDOR", 1, 1],
  ["F2_E37", "F2_N43", "F2_N70",  null,  4.2, Math.round( 4.2), "CORRIDOR", 1, 1],
  ["F2_E38", "F2_N43", "F2_N45",  null,  4.3, Math.round( 4.3), "CORRIDOR", 1, 1],
  ["F2_E39", "F2_N45", "F2_N46",  null,  9.2, Math.round( 9.2), "CORRIDOR", 1, 1],
  ["F2_E40", "F2_N46", "F2_N44",  null,  8.7, Math.round( 8.7), "CORRIDOR", 1, 1],
  ["F2_E41", "F2_N44", "F2_N42",  null,  4.7, Math.round( 4.7), "CORRIDOR", 1, 1],
  ["F2_E42", "F2_N39", "F2_N38",  null,  9.4, Math.round( 9.4), "CORRIDOR", 1, 1],
  ["F2_E43", "F2_N38", "F2_N37",  null,  7.7, Math.round( 7.7), "CORRIDOR", 1, 1],
  ["F2_E44", "F2_N37", "F2_N24",  null,  6.8, Math.round( 6.8), "CORRIDOR", 1, 1],
  ["F2_E45", "F2_N56", "F2_N9",   null,  8.5, Math.round( 8.5), "CORRIDOR", 1, 1],
  ["F2_E46", "F2_N9",  "F2_N8",   null,  6.0, Math.round( 6.0), "CORRIDOR", 1, 1],
  ["F2_E47", "F2_N8",  "F2_N7",   null,  5.3, Math.round( 5.3), "CORRIDOR", 1, 1],
  ["F2_E48", "F2_N7",  "F2_N6",   null,  4.4, Math.round( 4.4), "CORRIDOR", 1, 1],
  ["F2_E49", "F2_N6",  "F2_N5",   null,  3.8, Math.round( 3.8), "CORRIDOR", 1, 1],
  ["F2_E50", "F2_N5",  "F2_N4",   null,  2.1, Math.round( 2.1), "CORRIDOR", 1, 1],
  ["F2_E51", "F2_N4",  "F2_N3",   null,  3.0, Math.round( 3.0), "CORRIDOR", 1, 1],
  ["F2_E52", "F2_N3",  "F2_N2",   null,  9.1, Math.round( 9.1), "CORRIDOR", 1, 1],
  ["F2_E53", "F2_N5",  "F2_N52",  null,  5.9, Math.round( 5.9), "CORRIDOR", 1, 1],
  ["F2_E54", "F2_N52", "F2_N53",  null,  7.6, Math.round( 7.6), "CORRIDOR", 1, 1],
  ["F2_E55", "F2_N53", "F2_N54",  null,  6.7, Math.round( 6.7), "CORRIDOR", 1, 1],
  ["F2_E56", "F2_N54", "F2_N55",  null, 13.0, Math.round(13.0), "CORRIDOR", 1, 1],
  ["F2_E57", "F2_N55", "F2_N64",  null,  9.0, Math.round( 9.0), "CORRIDOR", 1, 1],
  ["F2_E58", "F2_N64", "F2_N65",  null,  4.9, Math.round( 4.9), "CORRIDOR", 1, 1],
  ["F2_E59", "F2_N65", "F2_N66",  null, 11.1, Math.round(11.1), "CORRIDOR", 1, 1],
  ["F2_E60", "F2_N55", "F2_N60",  null,  9.1, Math.round( 9.1), "CORRIDOR", 1, 1],
  ["F2_E61", "F2_N60", "F2_N61",  null, 11.2, Math.round(11.2), "CORRIDOR", 1, 1],
  ["F2_E62", "F2_N61", "F2_N62",  null,  9.0, Math.round( 9.0), "CORRIDOR", 1, 1],
  ["F2_E63", "F2_N62", "F2_N63",  null,  9.2, Math.round( 9.2), "CORRIDOR", 1, 1],
  ["F2_E64", "F2_N55", "F2_N49",  null,  4.9, Math.round( 4.9), "CORRIDOR", 1, 1],
  ["F2_E65", "F2_N49", "F2_N51",  null,  9.1, Math.round( 9.1), "CORRIDOR", 1, 1],
  ["F2_E66", "F2_N49", "F2_N50",  null,  8.8, Math.round( 8.8), "CORRIDOR", 1, 1],
  ["F2_E67", "F2_N49", "F2_N48",  null,  6.3, Math.round( 6.3), "CORRIDOR", 1, 1],
  ["F2_E68", "F2_N48", "F2_N47",  null,  6.9, Math.round( 6.9), "CORRIDOR", 1, 1],
  ["F2_E69", "F2_N47", "F2_N46",  null,  5.0, Math.round( 5.0), "CORRIDOR", 1, 1],
  ["F2_E70", "F2_N73", "F2_N38",  null,  6.4, Math.round( 6.4), "CORRIDOR", 1, 1],
  ["F2_E71", "F2_N38", "F2_N74",  null,  7.2, Math.round( 7.2), "CORRIDOR", 1, 1],
];

const insertNode = db.prepare(`
  INSERT OR IGNORE INTO NAV_NODE
    (id, zone_id, department_id, label, node_type, x_coord, y_coord, floor_number,
     is_accessible, has_elevator, is_vertical, vertical_id)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`);

const insertEdge = db.prepare(`
  INSERT OR IGNORE INTO NAV_EDGE
    (id, from_node_id, to_node_id, landmark_id,
     distance_m, est_seconds, edge_type, is_accessible, is_bidirectional)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`);

const insertNodes = db.transaction(() => nodes.forEach((n) => insertNode.run(...n)));
const insertEdges = db.transaction(() => edges.forEach((e) => insertEdge.run(...e)));

insertNodes();
console.log(`Inserted ${nodes.length} nodes for Floor 2`);

insertEdges();
console.log(`Inserted ${edges.length} edges for Floor 2`);
