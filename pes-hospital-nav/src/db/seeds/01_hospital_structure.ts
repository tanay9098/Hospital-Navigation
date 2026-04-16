import db from "../db";

const BUILDING_ID = "B1";

/* =============================
   BUILDING
============================= */

db.prepare(`
INSERT OR IGNORE INTO BUILDING
(id, name, address, total_floors, lat, lng)
VALUES (?, ?, ?, ?, ?, ?)
`).run(
  BUILDING_ID,
  "PES Hospital",
  "Electronic City, Bengaluru",
  9,
  12.8456,
  77.6603
);

/* =============================
   FLOORS
============================= */

const floors = [
  { id: "F0", number: 0, label: "Ground Floor" },
  { id: "F1", number: 1, label: "Floor 1" },
  { id: "F2", number: 2, label: "Floor 2" },
  { id: "F3", number: 3, label: "Floor 3" },
  { id: "F4", number: 4, label: "Floor 4" },
  { id: "F5", number: 5, label: "Floor 5" },
  { id: "F6", number: 6, label: "Floor 6" },
  { id: "F7", number: 7, label: "Floor 7" },
  { id: "F8", number: 8, label: "Floor 8" }
];

const insertFloor = db.prepare(`
INSERT OR IGNORE INTO FLOOR
(id, building_id, floor_number, label, is_active)
VALUES (?, ?, ?, ?, 1)
`);

floors.forEach(f => {
  insertFloor.run(f.id, BUILDING_ID, f.number, f.label);
});

/* =============================
   ZONES
============================= */

const zones = floors.flatMap(f => [
  {
    id: `Z_${f.id}_C`,
    floor: f.id,
    name: `${f.label} Clinical Zone`,
    type: "CLINICAL",
    area: 1500,
    color: "#4CAF50"
  },
  {
    id: `Z_${f.id}_S`,
    floor: f.id,
    name: `${f.label} Support Zone`,
    type: "SUPPORT",
    area: 800,
    color: "#2196F3"
  }
]);

const insertZone = db.prepare(`
INSERT OR IGNORE INTO ZONE
(id, floor_id, name, type, area_sqm, color_code)
VALUES (?, ?, ?, ?, ?, ?)
`);

zones.forEach(z => {
  insertZone.run(z.id, z.floor, z.name, z.type, z.area, z.color);
});

/* =============================
   DEPARTMENTS
============================= */

const departments = [

/* Ground Floor */
["D1","Z_F0_C","RECP","Reception","Reception","ADMIN","R1",0,"100",0,1],
["D2","Z_F0_C","EMR","Emergency","Emergency","EMERGENCY","E1",0,"101",1,2],
["D3","Z_F0_S","AMB","Ambulance Bay","Ambulance","SUPPORT","A1",0,"102",1,3],
["D4","Z_F0_C","PHAR","Pharmacy","Pharmacy","PHARMACY","P1",0,"103",0,4],
["D5","Z_F0_S","SEC","Security","Security","SUPPORT","S1",0,"104",0,5],

/* Floor 1 */
["D11","Z_F1_C","GM","General Medicine","Gen Med","OPD","101",1,"111",0,11],
["D12","Z_F1_C","PED","Paediatrics","Peds","OPD","102",1,"112",0,12],
["D13","Z_F1_C","ENT","ENT","ENT","OPD","103",1,"113",0,13],
["D14","Z_F1_C","OPH","Ophthalmology","Eye","OPD","104",1,"114",0,14],

/* Floor 2 */
["D21","Z_F2_C","ORTH","Orthopaedics","Ortho","OPD","201",2,"121",0,21],
["D22","Z_F2_C","DERM","Dermatology","Derm","OPD","202",2,"122",0,22],
["D23","Z_F2_C","NEU","Neurology","Neuro","OPD","203",2,"123",0,23],
["D24","Z_F2_C","PHYS","Physiotherapy","Physio","SUPPORT","204",2,"124",0,24],

/* Floor 3 */
["D31","Z_F3_C","RAD","Radiology","Radiology","DIAGNOSTICS","301",3,"131",0,31],
["D32","Z_F3_C","PATH","Pathology","Path","DIAGNOSTICS","302",3,"132",0,32],
["D33","Z_F3_S","BB","Blood Bank","Blood Bank","SUPPORT","303",3,"133",1,33],

/* Floor 4 */
["D41","Z_F4_C","CARD","Cardiology OPD","Cardio","OPD","401",4,"141",0,41],
["D42","Z_F4_C","CATH","Cath Lab","Cath","SURGICAL","402",4,"142",1,42],
["D43","Z_F4_C","PULM","Pulmonology","Pulmo","OPD","403",4,"143",0,43],
["D44","Z_F4_C","CICU","CICU","CICU","IPD","404",4,"144",1,44],

/* Floor 5 */
["D51","Z_F5_C","OBG","Obs & Gynae","OBG","OPD","501",5,"151",0,51],
["D52","Z_F5_C","LAB","Labour Ward","Labour","IPD","502",5,"152",1,52],
["D53","Z_F5_C","NICU","NICU","NICU","IPD","503",5,"153",1,53],
["D54","Z_F5_S","WW","Womens Wellness","Wellness","SUPPORT","504",5,"154",0,54],

/* Floor 6 */
["D61","Z_F6_C","PSY","Psychiatry","Psych","OPD","601",6,"161",0,61],
["D62","Z_F6_C","COUN","Counselling","Counselling","SUPPORT","602",6,"162",0,62],
["D63","Z_F6_C","ADD","De-addiction","DeAdd","SUPPORT","603",6,"163",0,63],
["D64","Z_F6_C","PSYCH","Psychology","Psychology","SUPPORT","604",6,"164",0,64],

/* Floor 7 */
["D71","Z_F7_C","SURG","General Surgery","Surgery","SURGICAL","701",7,"171",0,71],
["D72","Z_F7_C","URO","Urology","Uro","SURGICAL","702",7,"172",0,72],
["D73","Z_F7_C","NEPH","Nephrology","Neph","OPD","703",7,"173",0,73],
["D74","Z_F7_C","SICU","SICU","SICU","IPD","704",7,"174",1,74],

/* Floor 8 */
["D81","Z_F8_C","OT","Operation Theatres","OT","SURGICAL","801",8,"181",1,81],
["D82","Z_F8_S","STER","Sterilisation","Sterile","SUPPORT","802",8,"182",0,82],
["D83","Z_F8_C","REC","Recovery","Recovery","IPD","803",8,"183",1,83],
["D84","Z_F8_S","ADM","Admin","Admin","ADMIN","804",8,"184",0,84]

];

const insertDept = db.prepare(`
INSERT OR IGNORE INTO DEPARTMENT
(id, zone_id, code, name, short_name, category,
 room_number, floor_number, contact_ext,
 is_emergency, ivrs_shortcode)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`);

departments.forEach(d => insertDept.run(...d));

console.log("Hospital structure seed completed.");