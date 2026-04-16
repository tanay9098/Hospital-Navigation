import db from "../db";

/* ============================
   LANDMARKS (Ground Floor)
============================ */

const landmarks = [
  ["L1", "F0", "Blue Reception Desk", "COUNTER", 10, 5, "Main reception counter"],
  ["L2", "F0", "Pharmacy Counter", "COUNTER", 30, 8, "Medicine dispensing counter"],
  ["L3", "F0", "Elevator Lobby Sign", "SIGNAGE", 20, 15, "Elevator direction sign"],
  ["L4", "F0", "Emergency Entry Sign", "SIGNAGE", 5, 20, "Emergency entry indicator"]
];

const insertLandmark = db.prepare(`
INSERT OR IGNORE INTO LANDMARK
(id, floor_id, name, type, x_coord, y_coord, description)
VALUES (?, ?, ?, ?, ?, ?, ?)
`);

landmarks.forEach(l => insertLandmark.run(...l));


/* ============================
   NAVIGATION NODES
============================ */

const nodes = [
  ["N1", "Z_F0_C", null, "Main Entrance", "EXIT", 0, 0, 0, 1, 0],
  ["N2", "Z_F0_C", "D1", "Reception Desk", "RECEPTION", 10, 5, 0, 1, 0],
  ["N3", "Z_F0_C", "D2", "Emergency Entry", "DEPARTMENT_ENTRY", 5, 20, 0, 1, 0],
  ["N4", "Z_F0_C", "D4", "Pharmacy", "DEPARTMENT_ENTRY", 30, 8, 0, 1, 0],
  ["N5", "Z_F0_S", null, "Elevator Lobby", "ELEVATOR", 20, 15, 0, 1, 1],
  ["N6", "Z_F0_C", null, "Corridor Junction A", "CORRIDOR_JUNCTION", 15, 10, 0, 1, 0],
  ["N7", "Z_F0_C", null, "Corridor Junction B", "CORRIDOR_JUNCTION", 25, 10, 0, 1, 0],
  ["N8", "Z_F0_C", null, "Information Desk", "WAITING_AREA", 12, 7, 0, 1, 0],
  ["N9", "Z_F0_S", "D3", "Ambulance Bay Access", "EXIT", 2, 25, 0, 1, 0],
  ["N10","Z_F0_S", null, "Secondary Exit", "EXIT", 35, 0, 0, 1, 0]
];

const insertNode = db.prepare(`
INSERT OR IGNORE INTO NAV_NODE
(id, zone_id, department_id, label, node_type,
 x_coord, y_coord, floor_number,
 is_accessible, has_elevator)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`);

nodes.forEach(n => insertNode.run(...n));


/* ============================
   NAVIGATION EDGES
============================ */

const edges = [

["E1","N1","N6",null,10,15,"CORRIDOR",1,1],
["E2","N6","N2","L1",5,8,"CORRIDOR",1,1],
["E3","N6","N7",null,8,12,"CORRIDOR",1,1],
["E4","N7","N4","L2",6,10,"CORRIDOR",1,1],
["E5","N6","N8",null,3,5,"CORRIDOR",1,1],
["E6","N7","N5","L3",7,10,"CORRIDOR",1,1],
["E7","N6","N3","L4",12,18,"CORRIDOR",1,1],
["E8","N3","N9",null,5,7,"CORRIDOR",1,1],
["E9","N7","N10",null,12,16,"CORRIDOR",1,1],

/* elevator connection */
["E10","N5","N6",null,4,6,"ELEVATOR_UP",1,1]

];

const insertEdge = db.prepare(`
INSERT OR IGNORE INTO NAV_EDGE
(id, from_node_id, to_node_id, landmark_id,
 distance_m, est_seconds, edge_type,
 is_accessible, is_bidirectional)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
`);

edges.forEach(e => insertEdge.run(...e));

console.log("Ground floor navigation graph seeded.");