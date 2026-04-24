import db from "../db";

const ZONE = "Z_F1_C";
const FLOOR = 1;

/* ============================
   NAVIGATION NODES — Floor 1
   Columns:
   id, zone_id, dept_id, label, node_type,
   x_coord, y_coord, floor_number,
   is_accessible, has_elevator, is_vertical, vertical_id
============================ */

const nodes: [string, string, null, string, string, number, number, number, 1, number, number, string | null][] = [

  // ── Corridor junctions ──────────────────────────────────────────────────
  ["F1_N1",   ZONE, null, "N1",   "CORRIDOR_JUNCTION", 2319, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N2",   ZONE, null, "N2",   "CORRIDOR_JUNCTION", 2095, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N3",   ZONE, null, "N3",   "CORRIDOR_JUNCTION", 1798, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N4",   ZONE, null, "N4",   "CORRIDOR_JUNCTION", 1504, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N5",   ZONE, null, "N5",   "CORRIDOR_JUNCTION", 1251, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N7",   ZONE, null, "N7",   "CORRIDOR_JUNCTION", 2319, 1113, FLOOR, 1, 0, 0, null],
  ["F1_N8",   ZONE, null, "N8",   "CORRIDOR_JUNCTION", 2319, 1004, FLOOR, 1, 0, 0, null],
  ["F1_N9",   ZONE, null, "N9",   "CORRIDOR_JUNCTION", 2319,  936, FLOOR, 1, 0, 0, null],
  ["F1_N11",  ZONE, null, "N11",  "CORRIDOR_JUNCTION", 2468, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N12",  ZONE, null, "N12",  "CORRIDOR_JUNCTION", 2648, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N13",  ZONE, null, "N13",  "CORRIDOR_JUNCTION", 2848, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N14",  ZONE, null, "N14",  "CORRIDOR_JUNCTION", 3037, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N15",  ZONE, null, "N15",  "CORRIDOR_JUNCTION", 3126, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N16",  ZONE, null, "N16",  "CORRIDOR_JUNCTION", 3278, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N17",  ZONE, null, "N17",  "CORRIDOR_JUNCTION", 3383, 1243, FLOOR, 1, 0, 0, null],
  ["F1_N19",  ZONE, null, "N19",  "CORRIDOR_JUNCTION", 3126, 1404, FLOOR, 1, 0, 0, null],
  ["F1_N20",  ZONE, null, "N20",  "CORRIDOR_JUNCTION", 3126, 1550, FLOOR, 1, 0, 0, null],
  ["F1_N21",  ZONE, null, "N21",  "CORRIDOR_JUNCTION", 3126, 1757, FLOOR, 1, 0, 0, null],
  ["F1_N22",  ZONE, null, "N22",  "CORRIDOR_JUNCTION", 3126, 1940, FLOOR, 1, 0, 0, null],
  ["F1_N23",  ZONE, null, "N23",  "CORRIDOR_JUNCTION", 3126, 2082, FLOOR, 1, 0, 0, null],
  ["F1_N24",  ZONE, null, "N24",  "CORRIDOR_JUNCTION", 3126, 2211, FLOOR, 1, 0, 0, null],
  ["F1_N27",  ZONE, null, "N27",  "CORRIDOR_JUNCTION", 3295, 2211, FLOOR, 1, 0, 0, null],
  ["F1_N28",  ZONE, null, "N28",  "CORRIDOR_JUNCTION", 3444, 2211, FLOOR, 1, 0, 0, null],
  ["F1_N29",  ZONE, null, "N29",  "CORRIDOR_JUNCTION", 3444, 2360, FLOOR, 1, 0, 0, null],
  ["F1_N30",  ZONE, null, "N30",  "CORRIDOR_JUNCTION", 3444, 2523, FLOOR, 1, 0, 0, null],
  ["F1_N31",  ZONE, null, "N31",  "CORRIDOR_JUNCTION", 3444, 2608, FLOOR, 1, 0, 0, null],
  ["F1_N33",  ZONE, null, "N33",  "CORRIDOR_JUNCTION", 3444, 2726, FLOOR, 1, 0, 0, null],
  ["F1_N34",  ZONE, null, "N34",  "CORRIDOR_JUNCTION", 3444, 2869, FLOOR, 1, 0, 0, null],
  ["F1_N35",  ZONE, null, "N35",  "CORRIDOR_JUNCTION", 3444, 3028, FLOOR, 1, 0, 0, null],
  ["F1_N37",  ZONE, null, "N37",  "CORRIDOR_JUNCTION", 3126, 2306, FLOOR, 1, 0, 0, null],
  ["F1_N38",  ZONE, null, "N38",  "CORRIDOR_JUNCTION", 3126, 2452, FLOOR, 1, 0, 0, null],
  ["F1_N39",  ZONE, null, "N39",  "CORRIDOR_JUNCTION", 3126, 2601, FLOOR, 1, 0, 0, null],
  ["F1_N40",  ZONE, null, "N40",  "CORRIDOR_JUNCTION", 3126, 2733, FLOOR, 1, 0, 0, null],
  ["F1_N41",  ZONE, null, "N41",  "CORRIDOR_JUNCTION", 3126, 2872, FLOOR, 1, 0, 0, null],
  ["F1_N42",  ZONE, null, "N42",  "CORRIDOR_JUNCTION", 3126, 2997, FLOOR, 1, 0, 0, null],
  ["F1_N43",  ZONE, null, "N43",  "CORRIDOR_JUNCTION", 3126, 3119, FLOOR, 1, 0, 0, null],
  ["F1_N44",  ZONE, null, "N44",  "CORRIDOR_JUNCTION", 2224, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N45",  ZONE, null, "N45",  "CORRIDOR_JUNCTION", 2322, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N46",  ZONE, null, "N46",  "CORRIDOR_JUNCTION", 2437, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N47",  ZONE, null, "N47",  "CORRIDOR_JUNCTION", 2610, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N48",  ZONE, null, "N48",  "CORRIDOR_JUNCTION", 2793, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N49",  ZONE, null, "N49",  "CORRIDOR_JUNCTION", 2949, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N50",  ZONE, null, "N50",  "CORRIDOR_JUNCTION", 3126, 3191, FLOOR, 1, 0, 0, null],
  ["F1_N51",  ZONE, null, "N51",  "CORRIDOR_JUNCTION", 3295, 3191, FLOOR, 1, 0, 0, null],
  ["F1_N52",  ZONE, null, "N52",  "CORRIDOR_JUNCTION", 3404, 3191, FLOOR, 1, 0, 0, null],
  ["F1_N54",  ZONE, null, "N54",  "CORRIDOR_JUNCTION", 1784, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N55",  ZONE, null, "N55",  "CORRIDOR_JUNCTION", 1574, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N56",  ZONE, null, "N56",  "CORRIDOR_JUNCTION", 1265, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N58",  ZONE, null, "N58",  "CORRIDOR_JUNCTION", 2322, 3086, FLOOR, 1, 0, 0, null],
  ["F1_N59",  ZONE, null, "N59",  "CORRIDOR_JUNCTION", 2322, 3015, FLOOR, 1, 0, 0, null],
  ["F1_N60",  ZONE, null, "N60",  "CORRIDOR_JUNCTION", 2322, 2913, FLOOR, 1, 0, 0, null],
  ["F1_N61",  ZONE, null, "N61",  "CORRIDOR_JUNCTION", 2322, 2791, FLOOR, 1, 0, 0, null],
  ["F1_N62",  ZONE, null, "N62",  "CORRIDOR_JUNCTION", 2322, 2646, FLOOR, 1, 0, 0, null],
  ["F1_N63",  ZONE, null, "N63",  "CORRIDOR_JUNCTION", 2322, 2547, FLOOR, 1, 0, 0, null],
  ["F1_N64",  ZONE, null, "N64",  "CORRIDOR_JUNCTION", 2322, 2344, FLOOR, 1, 0, 0, null],
  ["F1_N65",  ZONE, null, "N65",  "CORRIDOR_JUNCTION", 2011, 2344, FLOOR, 1, 0, 0, null],
  ["F1_N66",  ZONE, null, "N66",  "CORRIDOR_JUNCTION", 2624, 2344, FLOOR, 1, 0, 0, null],
  ["F1_N69",  ZONE, null, "N69",  "CORRIDOR_JUNCTION", 2011, 2222, FLOOR, 1, 0, 0, null],
  ["F1_N71",  ZONE, null, "N71",  "CORRIDOR_JUNCTION", 2322, 2059, FLOOR, 1, 0, 0, null],
  ["F1_N72",  ZONE, null, "N72",  "CORRIDOR_JUNCTION", 2322, 1923, FLOOR, 1, 0, 0, null],
  ["F1_N73",  ZONE, null, "N73",  "CORRIDOR_JUNCTION", 2322, 1758, FLOOR, 1, 0, 0, null],
  ["F1_N74",  ZONE, null, "N74",  "CORRIDOR_JUNCTION", 2322, 1575, FLOOR, 1, 0, 0, null],
  ["F1_N75",  ZONE, null, "N75",  "CORRIDOR_JUNCTION", 2319, 1392, FLOOR, 1, 0, 0, null],
  ["F1_N81",  ZONE, null, "N81",  "CORRIDOR_JUNCTION", 1504, 1383, FLOOR, 1, 0, 0, null],
  ["F1_N82",  ZONE, null, "N82",  "CORRIDOR_JUNCTION", 1504, 1544, FLOOR, 1, 0, 0, null],
  ["F1_N83",  ZONE, null, "N83",  "CORRIDOR_JUNCTION", 1504, 1715, FLOOR, 1, 0, 0, null],
  ["F1_N84",  ZONE, null, "N84",  "CORRIDOR_JUNCTION", 1504, 1882, FLOOR, 1, 0, 0, null],
  ["F1_N85",  ZONE, null, "N85",  "CORRIDOR_JUNCTION", 1504, 2022, FLOOR, 1, 0, 0, null],
  ["F1_N86",  ZONE, null, "N86",  "CORRIDOR_JUNCTION", 1504, 2136, FLOOR, 1, 0, 0, null],
  ["F1_N87",  ZONE, null, "N87",  "CORRIDOR_JUNCTION", 1504, 2222, FLOOR, 1, 0, 0, null],
  ["F1_N88",  ZONE, null, "N88",  "CORRIDOR_JUNCTION", 1303, 2222, FLOOR, 1, 0, 0, null],
  ["F1_N89",  ZONE, null, "N89",  "CORRIDOR_JUNCTION", 1178, 2222, FLOOR, 1, 0, 0, null],
  ["F1_N90",  ZONE, null, "N90",  "CORRIDOR_JUNCTION", 1178, 2110, FLOOR, 1, 0, 0, null],
  ["F1_N92",  ZONE, null, "N92",  "CORRIDOR_JUNCTION", 1178, 2336, FLOOR, 1, 0, 0, null],
  ["F1_N93",  ZONE, null, "N93",  "CORRIDOR_JUNCTION", 1178, 2486, FLOOR, 1, 0, 0, null],
  ["F1_N94",  ZONE, null, "N94",  "CORRIDOR_JUNCTION", 1178, 2629, FLOOR, 1, 0, 0, null],
  ["F1_N95",  ZONE, null, "N95",  "CORRIDOR_JUNCTION", 1178, 2781, FLOOR, 1, 0, 0, null],
  ["F1_N96",  ZONE, null, "N96",  "CORRIDOR_JUNCTION", 1178, 2928, FLOOR, 1, 0, 0, null],
  ["F1_N97",  ZONE, null, "N97",  "CORRIDOR_JUNCTION", 1175, 3187, FLOOR, 1, 0, 0, null],
  ["F1_N98",  ZONE, null, "N98",  "CORRIDOR_JUNCTION", 1178, 3049, FLOOR, 1, 0, 0, null],
  ["F1_N101", ZONE, null, "N101", "CORRIDOR_JUNCTION", 2624, 2214, FLOOR, 1, 0, 0, null],
  ["F1_N102", ZONE, null, "N102", "CORRIDOR_JUNCTION", 2780, 2214, FLOOR, 1, 0, 0, null],
  ["F1_N103", ZONE, null, "N103", "CORRIDOR_JUNCTION", 2993, 2219, FLOOR, 1, 0, 0, null],

  // ── Rooms / department entries ───────────────────────────────────────────
  ["F1_N6",   ZONE, null, "PEA OPD",          "DEPARTMENT_ENTRY", 1061,  1001, FLOOR, 1, 0, 0, null],
  ["F1_N10",  ZONE, null, "OBG OPD",           "DEPARTMENT_ENTRY", 2190,   733, FLOOR, 1, 0, 0, null],
  ["F1_N18",  ZONE, null, "SURGERY OPD",       "DEPARTMENT_ENTRY", 3539,  1235, FLOOR, 1, 0, 0, null],
  ["F1_N25",  ZONE, null, "BILLING",           "DEPARTMENT_ENTRY", 2993,  2347, FLOOR, 1, 0, 0, null],
  ["F1_N32",  ZONE, null, "SAMPLE COLLECTION", "DEPARTMENT_ENTRY", 3685,  2604, FLOOR, 1, 0, 0, null],
  ["F1_N36",  ZONE, null, "MEDICINE OPD",      "DEPARTMENT_ENTRY", 3580,  3377, FLOOR, 1, 0, 0, null],
  ["F1_N57",  ZONE, null, "ORTHO OPD",         "DEPARTMENT_ENTRY", 1116,  3358, FLOOR, 1, 0, 0, null],
  ["F1_N91",  ZONE, null, "DENTAL OPD",        "DEPARTMENT_ENTRY", 1033,  2017, FLOOR, 1, 0, 0, null],

  // ── Waiting areas ────────────────────────────────────────────────────────
  ["F1_N26",  ZONE, null, "WAITING AREA",      "WAITING_AREA",    3705,  2126, FLOOR, 1, 0, 0, null],
  ["F1_N53",  ZONE, null, "WAITING AREA",      "WAITING_AREA",    1984,  3187, FLOOR, 1, 0, 0, null],

  // ── Restrooms ────────────────────────────────────────────────────────────
  ["F1_N99",  ZONE, null, "TOILET FEMALE",     "RESTROOM",        2080,  1753, FLOOR, 1, 0, 0, null],
  ["F1_N100", ZONE, null, "TOILET MALE",       "RESTROOM",        2542,  1765, FLOOR, 1, 0, 0, null],

  // ── Lifts (vertical connectors) ──────────────────────────────────────────
  ["F1_N67",  ZONE, null, "LIFT 3",            "ELEVATOR",        2624,  2073, FLOOR, 1, 1, 1, "F1_V_LIFT_3"],
  ["F1_N68",  ZONE, null, "LIFT 2",            "ELEVATOR",        2011,  2073, FLOOR, 1, 1, 1, "F1_V_LIFT_2"],
  ["F1_N79",  ZONE, null, "LIFT 1",            "ELEVATOR",        2610,  3016, FLOOR, 1, 1, 1, "F1_V_LIFT_1"],

  // ── Stairs (vertical connectors) ─────────────────────────────────────────
  ["F1_N77",  ZONE, null, "STAIRS 2",          "STAIRCASE",       2495,  2547, FLOOR, 1, 0, 1, "F1_V_STAIRS_2"],
  ["F1_N78",  ZONE, null, "STAIRS 1",          "STAIRCASE",       2171,  3015, FLOOR, 1, 0, 1, "F1_V_STAIRS_1"],

  // ── Ramp (vertical connector) ────────────────────────────────────────────
  ["F1_N76",  ZONE, null, "RAMP",              "RAMP",            2098,  2547, FLOOR, 1, 1, 1, "F1_V_RAMP_1"],
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
console.log(`Inserted ${nodes.length} Floor 1 nodes.`);


/* ============================
   NAVIGATION EDGES — Floor 1
   Columns:
   id, from_node_id, to_node_id, landmark_id,
   distance_m, est_seconds, edge_type,
   is_accessible, is_bidirectional

   est_seconds ≈ distance_m / 1.0  (≈1 m/s hospital walking pace)
============================ */

const edges: [string, string, string, null, number, number, string, 1, 1][] = [
  // id            from          to            lm   dist  sec   type         acc  bi
  ["F1_E1",   "F1_N10",  "F1_N9",   null,  6.8,  10,  "CORRIDOR", 1, 1],
  ["F1_E2",   "F1_N9",   "F1_N8",   null,  1.9,   3,  "CORRIDOR", 1, 1],
  ["F1_E3",   "F1_N8",   "F1_N7",   null,  3.1,   5,  "CORRIDOR", 1, 1],
  ["F1_E4",   "F1_N7",   "F1_N1",   null,  3.7,   6,  "CORRIDOR", 1, 1],
  ["F1_E5",   "F1_N1",   "F1_N2",   null,  6.3,   9,  "CORRIDOR", 1, 1],
  ["F1_E6",   "F1_N2",   "F1_N3",   null,  8.4,  13,  "CORRIDOR", 1, 1],
  ["F1_E7",   "F1_N3",   "F1_N4",   null,  8.3,  12,  "CORRIDOR", 1, 1],
  ["F1_E8",   "F1_N4",   "F1_N5",   null,  7.1,  11,  "CORRIDOR", 1, 1],
  ["F1_E9",   "F1_N5",   "F1_N6",   null,  8.7,  13,  "CORRIDOR", 1, 1],
  ["F1_E10",  "F1_N4",   "F1_N81",  null,  3.9,   6,  "CORRIDOR", 1, 1],
  ["F1_E11",  "F1_N81",  "F1_N82",  null,  4.5,   7,  "CORRIDOR", 1, 1],
  ["F1_E12",  "F1_N82",  "F1_N83",  null,  4.8,   7,  "CORRIDOR", 1, 1],
  ["F1_E13",  "F1_N83",  "F1_N84",  null,  4.7,   7,  "CORRIDOR", 1, 1],
  ["F1_E14",  "F1_N84",  "F1_N85",  null,  3.9,   6,  "CORRIDOR", 1, 1],
  ["F1_E15",  "F1_N85",  "F1_N86",  null,  3.2,   5,  "CORRIDOR", 1, 1],
  ["F1_E16",  "F1_N86",  "F1_N87",  null,  2.4,   4,  "CORRIDOR", 1, 1],
  ["F1_E17",  "F1_N87",  "F1_N88",  null,  5.7,   9,  "CORRIDOR", 1, 1],
  ["F1_E18",  "F1_N88",  "F1_N89",  null,  3.5,   5,  "CORRIDOR", 1, 1],
  ["F1_E19",  "F1_N89",  "F1_N90",  null,  3.2,   5,  "CORRIDOR", 1, 1],
  ["F1_E20",  "F1_N90",  "F1_N91",  null,  4.9,   7,  "CORRIDOR", 1, 1],
  ["F1_E21",  "F1_N87",  "F1_N69",  null, 14.3,  21,  "CORRIDOR", 1, 1],
  ["F1_E22",  "F1_N69",  "F1_N68",  null,  4.2,   6,  "CORRIDOR", 1, 1],
  ["F1_E23",  "F1_N69",  "F1_N65",  null,  3.4,   5,  "CORRIDOR", 1, 1],
  ["F1_E24",  "F1_N65",  "F1_N64",  null,  8.8,  13,  "CORRIDOR", 1, 1],
  ["F1_E25",  "F1_N64",  "F1_N66",  null,  8.5,  13,  "CORRIDOR", 1, 1],
  ["F1_E28",  "F1_N68",  "F1_N71",  null,  8.8,  13,  "CORRIDOR", 1, 1],
  ["F1_E29",  "F1_N71",  "F1_N67",  null,  8.5,  13,  "CORRIDOR", 1, 1],
  ["F1_E30",  "F1_N71",  "F1_N72",  null,  3.8,   6,  "CORRIDOR", 1, 1],
  ["F1_E31",  "F1_N72",  "F1_N73",  null,  4.6,   7,  "CORRIDOR", 1, 1],
  ["F1_E32",  "F1_N73",  "F1_N99",  null,  6.8,  10,  "CORRIDOR", 1, 1],
  ["F1_E33",  "F1_N73",  "F1_N100", null,  6.2,   9,  "CORRIDOR", 1, 1],
  ["F1_E34",  "F1_N73",  "F1_N74",  null,  5.2,   8,  "CORRIDOR", 1, 1],
  ["F1_E35",  "F1_N74",  "F1_N75",  null,  5.2,   8,  "CORRIDOR", 1, 1],
  ["F1_E36",  "F1_N75",  "F1_N1",   null,  4.2,   6,  "CORRIDOR", 1, 1],
  ["F1_E37",  "F1_N1",   "F1_N11",  null,  4.2,   6,  "CORRIDOR", 1, 1],
  ["F1_E38",  "F1_N11",  "F1_N12",  null,  5.1,   8,  "CORRIDOR", 1, 1],
  ["F1_E39",  "F1_N12",  "F1_N13",  null,  5.6,   8,  "CORRIDOR", 1, 1],
  ["F1_E40",  "F1_N13",  "F1_N14",  null,  5.3,   8,  "CORRIDOR", 1, 1],
  ["F1_E41",  "F1_N14",  "F1_N15",  null,  2.5,   4,  "CORRIDOR", 1, 1],
  ["F1_E42",  "F1_N15",  "F1_N16",  null,  4.3,   6,  "CORRIDOR", 1, 1],
  ["F1_E43",  "F1_N16",  "F1_N17",  null,  3.0,   5,  "CORRIDOR", 1, 1],
  ["F1_E44",  "F1_N17",  "F1_N18",  null,  4.4,   7,  "CORRIDOR", 1, 1],
  ["F1_E45",  "F1_N15",  "F1_N19",  null,  4.5,   7,  "CORRIDOR", 1, 1],
  ["F1_E46",  "F1_N19",  "F1_N20",  null,  4.1,   6,  "CORRIDOR", 1, 1],
  ["F1_E47",  "F1_N20",  "F1_N21",  null,  5.8,   9,  "CORRIDOR", 1, 1],
  ["F1_E48",  "F1_N21",  "F1_N22",  null,  5.2,   8,  "CORRIDOR", 1, 1],
  ["F1_E49",  "F1_N22",  "F1_N23",  null,  4.0,   6,  "CORRIDOR", 1, 1],
  ["F1_E50",  "F1_N23",  "F1_N24",  null,  3.6,   5,  "CORRIDOR", 1, 1],
  ["F1_E51",  "F1_N24",  "F1_N27",  null,  4.8,   7,  "CORRIDOR", 1, 1],
  ["F1_E52",  "F1_N27",  "F1_N28",  null,  4.2,   6,  "CORRIDOR", 1, 1],
  ["F1_E53",  "F1_N28",  "F1_N26",  null,  7.7,  12,  "CORRIDOR", 1, 1],
  ["F1_E54",  "F1_N28",  "F1_N29",  null,  4.2,   6,  "CORRIDOR", 1, 1],
  ["F1_E55",  "F1_N29",  "F1_N30",  null,  4.6,   7,  "CORRIDOR", 1, 1],
  ["F1_E56",  "F1_N30",  "F1_N31",  null,  2.4,   4,  "CORRIDOR", 1, 1],
  ["F1_E57",  "F1_N31",  "F1_N32",  null,  6.8,  10,  "CORRIDOR", 1, 1],
  ["F1_E58",  "F1_N31",  "F1_N33",  null,  3.3,   5,  "CORRIDOR", 1, 1],
  ["F1_E59",  "F1_N33",  "F1_N34",  null,  4.0,   6,  "CORRIDOR", 1, 1],
  ["F1_E60",  "F1_N34",  "F1_N35",  null,  4.5,   7,  "CORRIDOR", 1, 1],
  ["F1_E61",  "F1_N35",  "F1_N36",  null, 10.6,  16,  "CORRIDOR", 1, 1],
  ["F1_E62",  "F1_N52",  "F1_N36",  null,  7.2,  11,  "CORRIDOR", 1, 1],
  ["F1_E63",  "F1_N52",  "F1_N51",  null,  3.1,   5,  "CORRIDOR", 1, 1],
  ["F1_E64",  "F1_N51",  "F1_N50",  null,  4.8,   7,  "CORRIDOR", 1, 1],
  ["F1_E65",  "F1_N50",  "F1_N43",  null,  2.0,   3,  "CORRIDOR", 1, 1],
  ["F1_E66",  "F1_N43",  "F1_N42",  null,  3.4,   5,  "CORRIDOR", 1, 1],
  ["F1_E67",  "F1_N42",  "F1_N41",  null,  3.5,   5,  "CORRIDOR", 1, 1],
  ["F1_E68",  "F1_N41",  "F1_N40",  null,  3.9,   6,  "CORRIDOR", 1, 1],
  ["F1_E69",  "F1_N40",  "F1_N39",  null,  3.7,   6,  "CORRIDOR", 1, 1],
  ["F1_E70",  "F1_N39",  "F1_N38",  null,  4.2,   6,  "CORRIDOR", 1, 1],
  ["F1_E71",  "F1_N38",  "F1_N37",  null,  4.1,   6,  "CORRIDOR", 1, 1],
  ["F1_E72",  "F1_N37",  "F1_N24",  null,  2.7,   4,  "CORRIDOR", 1, 1],
  ["F1_E74",  "F1_N66",  "F1_N101", null,  3.7,   6,  "CORRIDOR", 1, 1],
  ["F1_E75",  "F1_N101", "F1_N67",  null,  4.0,   6,  "CORRIDOR", 1, 1],
  ["F1_E76",  "F1_N101", "F1_N102", null,  4.4,   7,  "CORRIDOR", 1, 1],
  ["F1_E77",  "F1_N102", "F1_N103", null,  6.0,   9,  "CORRIDOR", 1, 1],
  ["F1_E78",  "F1_N103", "F1_N24",  null,  3.8,   6,  "CORRIDOR", 1, 1],
  ["F1_E79",  "F1_N103", "F1_N25",  null,  3.6,   5,  "CORRIDOR", 1, 1],
  ["F1_E80",  "F1_N50",  "F1_N49",  null,  5.0,   8,  "CORRIDOR", 1, 1],
  ["F1_E81",  "F1_N49",  "F1_N48",  null,  4.4,   7,  "CORRIDOR", 1, 1],
  ["F1_E82",  "F1_N48",  "F1_N47",  null,  5.2,   8,  "CORRIDOR", 1, 1],
  ["F1_E83",  "F1_N47",  "F1_N46",  null,  4.9,   7,  "CORRIDOR", 1, 1],
  ["F1_E84",  "F1_N46",  "F1_N45",  null,  3.2,   5,  "CORRIDOR", 1, 1],
  ["F1_E85",  "F1_N45",  "F1_N58",  null,  2.8,   4,  "CORRIDOR", 1, 1],
  ["F1_E86",  "F1_N58",  "F1_N59",  null,  2.0,   3,  "CORRIDOR", 1, 1],
  ["F1_E87",  "F1_N59",  "F1_N60",  null,  2.9,   4,  "CORRIDOR", 1, 1],
  ["F1_E88",  "F1_N60",  "F1_N61",  null,  3.4,   5,  "CORRIDOR", 1, 1],
  ["F1_E89",  "F1_N61",  "F1_N62",  null,  4.1,   6,  "CORRIDOR", 1, 1],
  ["F1_E90",  "F1_N62",  "F1_N63",  null,  2.8,   4,  "CORRIDOR", 1, 1],
  ["F1_E91",  "F1_N63",  "F1_N64",  null,  5.7,   9,  "CORRIDOR", 1, 1],
  ["F1_E92",  "F1_N63",  "F1_N77",  null,  4.9,   7,  "CORRIDOR", 1, 1],
  ["F1_E93",  "F1_N63",  "F1_N76",  null,  6.3,   9,  "CORRIDOR", 1, 1],
  ["F1_E94",  "F1_N59",  "F1_N78",  null,  4.3,   6,  "CORRIDOR", 1, 1],
  ["F1_E95",  "F1_N59",  "F1_N79",  null,  8.1,  12,  "CORRIDOR", 1, 1],
  ["F1_E96",  "F1_N45",  "F1_N44",  null,  2.8,   4,  "CORRIDOR", 1, 1],
  ["F1_E97",  "F1_N44",  "F1_N53",  null,  6.8,  10,  "CORRIDOR", 1, 1],
  ["F1_E98",  "F1_N53",  "F1_N54",  null,  5.6,   8,  "CORRIDOR", 1, 1],
  ["F1_E99",  "F1_N54",  "F1_N55",  null,  5.9,   9,  "CORRIDOR", 1, 1],
  ["F1_E100", "F1_N55",  "F1_N56",  null,  8.7,  13,  "CORRIDOR", 1, 1],
  ["F1_E101", "F1_N56",  "F1_N57",  null,  6.4,  10,  "CORRIDOR", 1, 1],
  ["F1_E102", "F1_N57",  "F1_N97",  null,  5.1,   8,  "CORRIDOR", 1, 1],
  ["F1_E103", "F1_N97",  "F1_N98",  null,  3.9,   6,  "CORRIDOR", 1, 1],
  ["F1_E104", "F1_N98",  "F1_N96",  null,  3.4,   5,  "CORRIDOR", 1, 1],
  ["F1_E105", "F1_N96",  "F1_N95",  null,  4.1,   6,  "CORRIDOR", 1, 1],
  ["F1_E106", "F1_N95",  "F1_N94",  null,  4.3,   6,  "CORRIDOR", 1, 1],
  ["F1_E107", "F1_N94",  "F1_N93",  null,  4.0,   6,  "CORRIDOR", 1, 1],
  ["F1_E108", "F1_N93",  "F1_N92",  null,  4.2,   6,  "CORRIDOR", 1, 1],
  ["F1_E109", "F1_N92",  "F1_N89",  null,  3.2,   5,  "CORRIDOR", 1, 1],
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
console.log(`Inserted ${edges.length} Floor 1 edges.`);
console.log("Floor 1 navigation graph seeded.");
