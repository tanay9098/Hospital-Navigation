/**
 * PES Hospital Electronic City – Mock Hospital Blueprint
 *
 * 9 levels (Ground Floor + Floors 1–8), ~120 location nodes.
 *
 * Coordinate system (per floor):
 *   X = 0 (west wall) → 100 (east wall)
 *   Y = 0 (south / main entrance side) → 100 (north / back wall)
 *
 * Transit infrastructure present on every floor:
 *   – Elevator Bank A  (North / x=30) – accessible, serves all floors
 *   – Elevator Bank B  (South / x=70) – accessible, serves all floors
 *   – North Stairwell  (x=10)  – not accessible
 *   – South Stairwell  (x=90)  – not accessible
 *
 * connections: [ fromCode, toCode, distanceMetres, direction ]
 *   All connections are ONE-WAY here; the seeder adds the reverse automatically.
 *   Elevator / stairwell vertical connections use direction "up".
 */

// ── Location definitions ──────────────────────────────────────────────────────

const locations = [

  // ════════════════════════════════════════
  //  GROUND FLOOR  (Floor 0)
  //  Emergency, Reception, Pharmacy, Lobby
  // ════════════════════════════════════════
  { code: 'GF-ENT',    name: 'Main Entrance',                    floor: 0, type: 'entrance',  category: 'facility',       description: 'Main entrance and exit of PES Hospital. Wheelchair ramp available.',          coordinates: { x: 50, y: 0  }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-SEC',    name: 'Security Office',                  floor: 0, type: 'room',      category: 'facility',       description: 'Visitor registration, security desk and ID verification.',                   coordinates: { x: 15, y: 5  }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-AMB',    name: 'Ambulance Bay',                    floor: 0, type: 'room',      category: 'facility',       description: 'Emergency ambulance entry and paramedic bay.',                               coordinates: { x: 85, y: 5  }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-LOBBY',  name: 'Main Lobby',                       floor: 0, type: 'corridor',  category: 'transit',        description: 'Central lobby with seating, wheelchairs and volunteer help desk.',            coordinates: { x: 50, y: 20 }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-REC',    name: 'Reception & Information Desk',     floor: 0, type: 'room',      category: 'facility',       description: 'Patient registration, visitor passes, hospital information and helpdesk.',    coordinates: { x: 35, y: 30 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: 'GF-EMG',    name: 'Emergency Department',             floor: 0, type: 'room',      category: 'department',     description: '24/7 emergency care. Walk-in triage, resuscitation bays and acute care.',    coordinates: { x: 85, y: 30 }, isAccessible: true,  ivrMenuNumber: 2    },
  { code: 'GF-TRM',    name: 'Trauma Center',                    floor: 0, type: 'room',      category: 'department',     description: 'Level 1 trauma center for critical injuries. Adjoins Emergency.',              coordinates: { x: 85, y: 45 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: 'GF-PHA',    name: 'Pharmacy',                         floor: 0, type: 'room',      category: 'facility',       description: '24/7 hospital pharmacy. Prescription dispensing and OTC medicines.',          coordinates: { x: 15, y: 35 }, isAccessible: true,  ivrMenuNumber: 4    },
  { code: 'GF-ATM',    name: 'ATM & Cash Counter',               floor: 0, type: 'room',      category: 'facility',       description: 'ATM machines (all major banks) and hospital cash payment counter.',           coordinates: { x: 15, y: 55 }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-CAF',    name: 'Ground Floor Cafeteria',           floor: 0, type: 'room',      category: 'facility',       description: 'Visitor cafeteria – vegetarian and non-vegetarian food, open 6 AM–10 PM.',   coordinates: { x: 85, y: 55 }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-COR',    name: 'Ground Floor Central Corridor',    floor: 0, type: 'corridor',  category: 'transit',        description: 'Main east-west corridor connecting all ground floor sections.',               coordinates: { x: 50, y: 55 }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-ELA',    name: 'Elevator Bank A (North)',          floor: 0, type: 'elevator',  category: 'transit',        description: 'Accessible elevators – north side. Serves all floors.',                      coordinates: { x: 30, y: 68 }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-ELB',    name: 'Elevator Bank B (South)',          floor: 0, type: 'elevator',  category: 'transit',        description: 'Accessible elevators – south side. Serves all floors.',                      coordinates: { x: 70, y: 68 }, isAccessible: true,  ivrMenuNumber: null },
  { code: 'GF-STA',    name: 'North Stairwell',                  floor: 0, type: 'stairwell', category: 'transit',        description: 'Emergency stairwell – north wing.',                                          coordinates: { x: 10, y: 68 }, isAccessible: false, ivrMenuNumber: null },
  { code: 'GF-STB',    name: 'South Stairwell',                  floor: 0, type: 'stairwell', category: 'transit',        description: 'Emergency stairwell – south wing.',                                          coordinates: { x: 90, y: 68 }, isAccessible: false, ivrMenuNumber: null },

  // ════════════════════════════════════════
  //  FLOOR 1 – OPD Block A
  //  General Medicine, Pediatrics, ENT,
  //  Ophthalmology, Dermatology, Radiology, Lab
  // ════════════════════════════════════════
  { code: '1F-COR',    name: 'Floor 1 Central Corridor',         floor: 1, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 1 connecting all OPD Block A departments.',           coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '1F-ELA',    name: 'Elevator Bank A – Floor 1',        floor: 1, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 1.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '1F-ELB',    name: 'Elevator Bank B – Floor 1',        floor: 1, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 1.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '1F-STA',    name: 'North Stairwell – Floor 1',        floor: 1, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 1.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '1F-STB',    name: 'South Stairwell – Floor 1',        floor: 1, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 1.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '1F-GMED',   name: 'OPD – General Medicine',           floor: 1, type: 'room',      category: 'department',     description: 'General physician OPD. Fever, infections, diabetes, hypertension and more.', coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '1F-PED',    name: 'OPD – Pediatrics',                 floor: 1, type: 'room',      category: 'department',     description: 'Children\'s OPD. Newborn to 18 years. Vaccination clinic co-located.',        coordinates: { x: 50, y: 10 }, isAccessible: true,  ivrMenuNumber: 2    },
  { code: '1F-ENT',    name: 'OPD – ENT (Ear Nose & Throat)',    floor: 1, type: 'room',      category: 'department',     description: 'Ear, nose and throat specialist OPD. Audiometry lab inside.',                 coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '1F-OPTH',   name: 'OPD – Ophthalmology',              floor: 1, type: 'room',      category: 'department',     description: 'Eye specialist OPD. Slit-lamp, fundus examination and refraction.',            coordinates: { x: 15, y: 85 }, isAccessible: true,  ivrMenuNumber: 4    },
  { code: '1F-DERM',   name: 'OPD – Dermatology',                floor: 1, type: 'room',      category: 'department',     description: 'Skin and hair disorders. Cosmetology procedures available.',                   coordinates: { x: 50, y: 90 }, isAccessible: true,  ivrMenuNumber: 5    },
  { code: '1F-XRAY',   name: 'Radiology & Imaging',              floor: 1, type: 'room',      category: 'department',     description: 'X-Ray, CT scan, MRI, ultrasound and mammography. Report same day.',          coordinates: { x: 85, y: 85 }, isAccessible: true,  ivrMenuNumber: 6    },
  { code: '1F-LAB',    name: 'Blood Collection & Pathology Lab', floor: 1, type: 'room',      category: 'department',     description: 'Blood, urine, stool tests. NABL-accredited lab. Reports in 4–6 hours.',      coordinates: { x: 15, y: 50 }, isAccessible: true,  ivrMenuNumber: 7    },
  { code: '1F-BILL',   name: 'Billing Counter',                  floor: 1, type: 'room',      category: 'facility',       description: 'OPD billing, insurance claims and cashless processing counter.',               coordinates: { x: 85, y: 50 }, isAccessible: true,  ivrMenuNumber: 8    },

  // ════════════════════════════════════════
  //  FLOOR 2 – OPD Block B (Ortho & Rehab)
  //  Orthopedics, Sports Medicine,
  //  Rheumatology, Physiotherapy,
  //  Occupational Therapy, Medical Records
  // ════════════════════════════════════════
  { code: '2F-COR',    name: 'Floor 2 Central Corridor',         floor: 2, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 2.',                                                  coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '2F-ELA',    name: 'Elevator Bank A – Floor 2',        floor: 2, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 2.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '2F-ELB',    name: 'Elevator Bank B – Floor 2',        floor: 2, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 2.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '2F-STA',    name: 'North Stairwell – Floor 2',        floor: 2, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 2.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '2F-STB',    name: 'South Stairwell – Floor 2',        floor: 2, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 2.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '2F-ORTH',   name: 'OPD – Orthopedics',                floor: 2, type: 'room',      category: 'department',     description: 'Bone and joint OPD. Fracture clinic, joint replacement consultation.',       coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '2F-SPM',    name: 'OPD – Sports Medicine',            floor: 2, type: 'room',      category: 'department',     description: 'Sports injuries, ligament tears, athletic performance rehabilitation.',       coordinates: { x: 50, y: 10 }, isAccessible: true,  ivrMenuNumber: 2    },
  { code: '2F-RHEU',   name: 'OPD – Rheumatology',               floor: 2, type: 'room',      category: 'department',     description: 'Arthritis, lupus, gout and autoimmune joint disorders.',                      coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '2F-PHY',    name: 'Physiotherapy Department',          floor: 2, type: 'room',      category: 'department',     description: 'Physical therapy, exercise rehab, dry needling and electrotherapy.',          coordinates: { x: 15, y: 85 }, isAccessible: true,  ivrMenuNumber: 4    },
  { code: '2F-OCC',    name: 'Occupational Therapy',              floor: 2, type: 'room',      category: 'department',     description: 'Functional rehabilitation for stroke, injury and disability patients.',       coordinates: { x: 50, y: 90 }, isAccessible: true,  ivrMenuNumber: 5    },
  { code: '2F-PLR',    name: 'Plaster Room',                      floor: 2, type: 'room',      category: 'department',     description: 'Fracture casting, plaster of Paris and fiberglass cast application.',         coordinates: { x: 85, y: 85 }, isAccessible: true,  ivrMenuNumber: 6    },
  { code: '2F-MRD',    name: 'Medical Records Department',        floor: 2, type: 'room',      category: 'facility',       description: 'Patient history, discharge summaries, medical certificate requests.',          coordinates: { x: 85, y: 50 }, isAccessible: true,  ivrMenuNumber: 7    },

  // ════════════════════════════════════════
  //  FLOOR 3 – Cardiology & Pulmonology
  //  Cardiology OPD, CICU, Echo/ECG Lab,
  //  Cath Lab, Pulmonology, Respiratory Therapy
  // ════════════════════════════════════════
  { code: '3F-COR',    name: 'Floor 3 Central Corridor',         floor: 3, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 3.',                                                  coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '3F-ELA',    name: 'Elevator Bank A – Floor 3',        floor: 3, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 3.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '3F-ELB',    name: 'Elevator Bank B – Floor 3',        floor: 3, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 3.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '3F-STA',    name: 'North Stairwell – Floor 3',        floor: 3, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 3.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '3F-STB',    name: 'South Stairwell – Floor 3',        floor: 3, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 3.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '3F-CARD',   name: 'OPD – Cardiology',                 floor: 3, type: 'room',      category: 'department',     description: 'Heart specialist OPD. Hypertension, arrhythmia, heart failure consultation.',coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '3F-CICU',   name: 'Cardiac ICU (CICU)',               floor: 3, type: 'room',      category: 'department',     description: 'Cardiac intensive care for post-MI, post-surgical and critical cardiac patients.', coordinates: { x: 50, y: 10 }, isAccessible: false, ivrMenuNumber: 2   },
  { code: '3F-ECHO',   name: 'Echo & ECG Laboratory',            floor: 3, type: 'room',      category: 'department',     description: '2D Echo, Doppler, Stress Test, Holter monitoring and 12-lead ECG.',          coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '3F-CATH',   name: 'Catheterization Laboratory',       floor: 3, type: 'room',      category: 'department',     description: 'Cardiac cath lab for coronary angiography, angioplasty and stenting.',       coordinates: { x: 15, y: 85 }, isAccessible: false, ivrMenuNumber: 4    },
  { code: '3F-PULM',   name: 'OPD – Pulmonology',                floor: 3, type: 'room',      category: 'department',     description: 'Lung specialist OPD. Asthma, COPD, TB, sleep apnea management.',             coordinates: { x: 50, y: 90 }, isAccessible: true,  ivrMenuNumber: 5    },
  { code: '3F-RESP',   name: 'Respiratory Therapy',              floor: 3, type: 'room',      category: 'department',     description: 'Nebulization, chest physiotherapy, spirometry and pulmonary rehab.',         coordinates: { x: 85, y: 85 }, isAccessible: true,  ivrMenuNumber: 6    },
  { code: '3F-SLP',    name: 'Sleep Disorders Lab',              floor: 3, type: 'room',      category: 'department',     description: 'Overnight sleep study (polysomnography) for apnea and insomnia.',            coordinates: { x: 85, y: 50 }, isAccessible: true,  ivrMenuNumber: 7    },

  // ════════════════════════════════════════
  //  FLOOR 4 – Gynecology & Maternity
  //  Gynecology OPD, Antenatal Clinic,
  //  Maternity Ward, Labor Room, NICU, Lactation
  // ════════════════════════════════════════
  { code: '4F-COR',    name: 'Floor 4 Central Corridor',         floor: 4, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 4.',                                                  coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '4F-ELA',    name: 'Elevator Bank A – Floor 4',        floor: 4, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 4.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '4F-ELB',    name: 'Elevator Bank B – Floor 4',        floor: 4, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 4.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '4F-STA',    name: 'North Stairwell – Floor 4',        floor: 4, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 4.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '4F-STB',    name: 'South Stairwell – Floor 4',        floor: 4, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 4.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '4F-GYN',    name: 'OPD – Gynecology & Obstetrics',    floor: 4, type: 'room',      category: 'department',     description: 'Women\'s health OPD. PCOS, menstrual disorders, infertility consultation.',  coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '4F-ANC',    name: 'Antenatal Clinic',                 floor: 4, type: 'room',      category: 'department',     description: 'Prenatal care, anomaly scans, high-risk pregnancy monitoring.',               coordinates: { x: 50, y: 10 }, isAccessible: true,  ivrMenuNumber: 2    },
  { code: '4F-MAT',    name: 'Maternity Ward',                   floor: 4, type: 'room',      category: 'department',     description: 'In-patient maternity ward with private and semi-private rooms.',             coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '4F-LBR',    name: 'Labor Room & Delivery Suite',      floor: 4, type: 'room',      category: 'department',     description: 'Delivery suites with fetal monitoring. Normal and C-section deliveries.',    coordinates: { x: 15, y: 85 }, isAccessible: false, ivrMenuNumber: 4    },
  { code: '4F-NICU',   name: 'Neonatal ICU (NICU)',              floor: 4, type: 'room',      category: 'department',     description: 'Intensive care for premature and critically ill newborns.',                   coordinates: { x: 50, y: 90 }, isAccessible: false, ivrMenuNumber: 5    },
  { code: '4F-LAC',    name: 'Lactation & Maternal Counseling',  floor: 4, type: 'room',      category: 'department',     description: 'Breastfeeding support, postpartum care and maternal mental health.',          coordinates: { x: 85, y: 85 }, isAccessible: true,  ivrMenuNumber: 6    },

  // ════════════════════════════════════════
  //  FLOOR 5 – Neurology & Psychiatry
  //  Neurology OPD, Neurology ICU,
  //  Psychiatry OPD, Counseling,
  //  Mental Health Ward, EEG Lab, Memory Clinic
  // ════════════════════════════════════════
  { code: '5F-COR',    name: 'Floor 5 Central Corridor',         floor: 5, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 5.',                                                  coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '5F-ELA',    name: 'Elevator Bank A – Floor 5',        floor: 5, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 5.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '5F-ELB',    name: 'Elevator Bank B – Floor 5',        floor: 5, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 5.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '5F-STA',    name: 'North Stairwell – Floor 5',        floor: 5, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 5.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '5F-STB',    name: 'South Stairwell – Floor 5',        floor: 5, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 5.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '5F-NEUR',   name: 'OPD – Neurology',                  floor: 5, type: 'room',      category: 'department',     description: 'Brain and spine disorders OPD. Epilepsy, migraine, Parkinson\'s, stroke.',   coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '5F-NICU',   name: 'Neurology ICU',                    floor: 5, type: 'room',      category: 'department',     description: 'Neuro-ICU for stroke, traumatic brain injury, status epilepticus.',          coordinates: { x: 50, y: 10 }, isAccessible: false, ivrMenuNumber: 2    },
  { code: '5F-PSYC',   name: 'OPD – Psychiatry',                 floor: 5, type: 'room',      category: 'department',     description: 'Mental health OPD. Depression, anxiety, schizophrenia, addiction.',          coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '5F-COUN',   name: 'Psychology & Counseling Center',   floor: 5, type: 'room',      category: 'department',     description: 'Individual, couple and family therapy. Child psychology available.',         coordinates: { x: 15, y: 85 }, isAccessible: true,  ivrMenuNumber: 4    },
  { code: '5F-MHW',    name: 'Mental Health Ward',               floor: 5, type: 'room',      category: 'department',     description: 'In-patient psychiatric ward with structured therapeutic program.',            coordinates: { x: 50, y: 90 }, isAccessible: true,  ivrMenuNumber: 5    },
  { code: '5F-EEG',    name: 'EEG & Neurophysiology Lab',        floor: 5, type: 'room',      category: 'department',     description: 'Electroencephalogram, nerve conduction studies and EMG tests.',               coordinates: { x: 85, y: 85 }, isAccessible: true,  ivrMenuNumber: 6    },
  { code: '5F-MEM',    name: 'Memory Clinic',                    floor: 5, type: 'room',      category: 'department',     description: 'Dementia assessment, cognitive testing and Alzheimer\'s management.',         coordinates: { x: 85, y: 50 }, isAccessible: true,  ivrMenuNumber: 7    },

  // ════════════════════════════════════════
  //  FLOOR 6 – Surgery & Operation Theatres
  //  General Surgery, Urology, Plastic Surgery,
  //  OT Complex, Pre-Op, Post-Op, Surgical ICU
  // ════════════════════════════════════════
  { code: '6F-COR',    name: 'Floor 6 Central Corridor',         floor: 6, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 6.',                                                  coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '6F-ELA',    name: 'Elevator Bank A – Floor 6',        floor: 6, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 6.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '6F-ELB',    name: 'Elevator Bank B – Floor 6',        floor: 6, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 6.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '6F-STA',    name: 'North Stairwell – Floor 6',        floor: 6, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 6.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '6F-STB',    name: 'South Stairwell – Floor 6',        floor: 6, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 6.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '6F-GSUR',   name: 'OPD – General Surgery',            floor: 6, type: 'room',      category: 'department',     description: 'General and laparoscopic surgery OPD. Hernia, gallbladder, appendix.',      coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '6F-URO',    name: 'OPD – Urology',                    floor: 6, type: 'room',      category: 'department',     description: 'Kidney, bladder and prostate OPD. Cystoscopy and lithotripsy services.',    coordinates: { x: 50, y: 10 }, isAccessible: true,  ivrMenuNumber: 2    },
  { code: '6F-PLS',    name: 'OPD – Plastic & Reconstructive Surgery', floor: 6, type: 'room', category: 'department',  description: 'Reconstructive surgery, burns, cleft lip/palate and cosmetic procedures.',   coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '6F-OT',     name: 'Operation Theatre Complex (OT 1–8)',floor: 6, type: 'room',      category: 'department',     description: 'Eight modular operation theatres with laminar flow. Pre-registration required.', coordinates: { x: 15, y: 85 }, isAccessible: false, ivrMenuNumber: 4   },
  { code: '6F-PREOP',  name: 'Pre-Op Preparation Area',          floor: 6, type: 'room',      category: 'department',     description: 'Pre-operative anaesthesia assessment, consent and patient preparation.',     coordinates: { x: 50, y: 85 }, isAccessible: false, ivrMenuNumber: null },
  { code: '6F-POSTOP', name: 'Post-Op Recovery Room',            floor: 6, type: 'room',      category: 'department',     description: 'Post-anaesthesia care unit (PACU). Monitored recovery after surgery.',       coordinates: { x: 85, y: 85 }, isAccessible: false, ivrMenuNumber: null },
  { code: '6F-SICU',   name: 'Surgical ICU (SICU)',              floor: 6, type: 'room',      category: 'department',     description: 'Surgical intensive care for high-risk post-operative patients.',             coordinates: { x: 85, y: 50 }, isAccessible: false, ivrMenuNumber: 5    },

  // ════════════════════════════════════════
  //  FLOOR 7 – Oncology & Specialised Units
  //  Oncology OPD, Radiation, Chemotherapy,
  //  BMT, Blood Bank, Hematology, Palliative Care
  // ════════════════════════════════════════
  { code: '7F-COR',    name: 'Floor 7 Central Corridor',         floor: 7, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 7.',                                                  coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '7F-ELA',    name: 'Elevator Bank A – Floor 7',        floor: 7, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 7.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '7F-ELB',    name: 'Elevator Bank B – Floor 7',        floor: 7, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 7.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '7F-STA',    name: 'North Stairwell – Floor 7',        floor: 7, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 7.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '7F-STB',    name: 'South Stairwell – Floor 7',        floor: 7, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 7.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '7F-ONCO',   name: 'OPD – Oncology',                   floor: 7, type: 'room',      category: 'department',     description: 'Cancer specialist OPD. Medical, surgical and radiation oncology.',           coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '7F-RADON',  name: 'Radiation Oncology',               floor: 7, type: 'room',      category: 'department',     description: 'Radiotherapy using LINAC. Simulation CT and treatment planning co-located.', coordinates: { x: 50, y: 10 }, isAccessible: true,  ivrMenuNumber: 2    },
  { code: '7F-CHEMO',  name: 'Chemotherapy Suite',               floor: 7, type: 'room',      category: 'department',     description: '20-bay day-care chemotherapy infusion centre with recliner chairs.',        coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '7F-BMT',    name: 'Bone Marrow Transplant Unit',      floor: 7, type: 'room',      category: 'department',     description: 'Autologous and allogeneic BMT. HEPA-filtered isolation rooms.',               coordinates: { x: 15, y: 85 }, isAccessible: false, ivrMenuNumber: 4    },
  { code: '7F-BB',     name: 'Blood Bank',                       floor: 7, type: 'room',      category: 'department',     description: 'NBTC-licensed blood bank. Donation, storage and transfusion services.',      coordinates: { x: 50, y: 90 }, isAccessible: true,  ivrMenuNumber: 5    },
  { code: '7F-HEM',    name: 'Hematology Laboratory',            floor: 7, type: 'room',      category: 'department',     description: 'Specialised blood disorder testing, bone marrow biopsy lab.',               coordinates: { x: 85, y: 85 }, isAccessible: true,  ivrMenuNumber: 6    },
  { code: '7F-PAL',    name: 'Palliative & Comfort Care',        floor: 7, type: 'room',      category: 'department',     description: 'Holistic symptom management and end-of-life care for serious illness.',      coordinates: { x: 85, y: 50 }, isAccessible: true,  ivrMenuNumber: 7    },

  // ════════════════════════════════════════
  //  FLOOR 8 – Administration & Support
  //  Director, Medical Superintendent,
  //  HR, Finance, IT, Conference, Cafeteria, Rooftop
  // ════════════════════════════════════════
  { code: '8F-COR',    name: 'Floor 8 Central Corridor',         floor: 8, type: 'corridor',  category: 'transit',        description: 'Main corridor on Floor 8.',                                                  coordinates: { x: 50, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '8F-ELA',    name: 'Elevator Bank A – Floor 8',        floor: 8, type: 'elevator',  category: 'transit',        description: 'North elevator landing – Floor 8.',                                          coordinates: { x: 30, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '8F-ELB',    name: 'Elevator Bank B – Floor 8',        floor: 8, type: 'elevator',  category: 'transit',        description: 'South elevator landing – Floor 8.',                                          coordinates: { x: 70, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
  { code: '8F-STA',    name: 'North Stairwell – Floor 8',        floor: 8, type: 'stairwell', category: 'transit',        description: 'North stairwell landing – Floor 8.',                                         coordinates: { x: 10, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '8F-STB',    name: 'South Stairwell – Floor 8',        floor: 8, type: 'stairwell', category: 'transit',        description: 'South stairwell landing – Floor 8.',                                         coordinates: { x: 90, y: 50 }, isAccessible: false, ivrMenuNumber: null },
  { code: '8F-DIR',    name: "Hospital Director's Office",        floor: 8, type: 'room',      category: 'administrative', description: 'Office of the Hospital Director. Appointments via front desk.',               coordinates: { x: 15, y: 15 }, isAccessible: true,  ivrMenuNumber: 1    },
  { code: '8F-MSUP',   name: "Medical Superintendent's Office",  floor: 8, type: 'room',      category: 'administrative', description: 'Clinical governance, complaints and medical superintendent meetings.',        coordinates: { x: 50, y: 10 }, isAccessible: true,  ivrMenuNumber: 2    },
  { code: '8F-HR',     name: 'Human Resources Department',       floor: 8, type: 'room',      category: 'administrative', description: 'Staff recruitment, payroll, attendance and HR policy.',                      coordinates: { x: 85, y: 15 }, isAccessible: true,  ivrMenuNumber: 3    },
  { code: '8F-FIN',    name: 'Finance & Accounts Department',    floor: 8, type: 'room',      category: 'administrative', description: 'Hospital accounts, budgeting and vendor payments.',                          coordinates: { x: 15, y: 85 }, isAccessible: true,  ivrMenuNumber: 4    },
  { code: '8F-IT',     name: 'IT & Systems Department',          floor: 8, type: 'room',      category: 'administrative', description: 'Hospital information systems, network and tech support.',                    coordinates: { x: 50, y: 85 }, isAccessible: true,  ivrMenuNumber: 5    },
  { code: '8F-CONF',   name: 'Conference Hall & CME Centre',     floor: 8, type: 'room',      category: 'facility',       description: '200-seat conference hall for CME, academic events and seminars.',            coordinates: { x: 85, y: 85 }, isAccessible: true,  ivrMenuNumber: 6    },
  { code: '8F-SCAF',   name: 'Staff Cafeteria',                  floor: 8, type: 'room',      category: 'facility',       description: 'Staff-only cafeteria. Hot meals, snacks and beverages.',                    coordinates: { x: 85, y: 50 }, isAccessible: true,  ivrMenuNumber: 7    },
  { code: '8F-ROOF',   name: 'Terrace & Healing Garden',         floor: 8, type: 'room',      category: 'facility',       description: 'Open rooftop healing garden for patients and visitors. Fresh air zone.',     coordinates: { x: 15, y: 50 }, isAccessible: true,  ivrMenuNumber: null },
];

// ── Connection definitions ────────────────────────────────────────────────────
// [ fromCode, toCode, distanceMetres, direction ]
// The seeder will automatically add reverse connections.

const connections = [
  // ── GROUND FLOOR ──────────────────────────────────────
  ['GF-ENT',   'GF-SEC',   35, 'west'],
  ['GF-ENT',   'GF-AMB',   35, 'east'],
  ['GF-ENT',   'GF-LOBBY', 25, 'north'],
  ['GF-LOBBY', 'GF-REC',   20, 'northwest'],
  ['GF-LOBBY', 'GF-EMG',   35, 'east'],
  ['GF-LOBBY', 'GF-PHA',   35, 'west'],
  ['GF-LOBBY', 'GF-COR',   35, 'north'],
  ['GF-REC',   'GF-PHA',   25, 'west'],
  ['GF-EMG',   'GF-TRM',   20, 'north'],
  ['GF-COR',   'GF-ATM',   35, 'west'],
  ['GF-COR',   'GF-CAF',   35, 'east'],
  ['GF-COR',   'GF-ELA',   20, 'west'],
  ['GF-COR',   'GF-ELB',   20, 'east'],
  ['GF-COR',   'GF-STA',   40, 'northwest'],
  ['GF-COR',   'GF-STB',   40, 'northeast'],
  ['GF-ELA',   'GF-STA',   20, 'west'],
  ['GF-ELB',   'GF-STB',   20, 'east'],

  // ── FLOOR 1 ────────────────────────────────────────────
  ['1F-ELA',   '1F-COR',   20, 'east'],
  ['1F-ELB',   '1F-COR',   20, 'west'],
  ['1F-STA',   '1F-COR',   40, 'southeast'],
  ['1F-STB',   '1F-COR',   40, 'southwest'],
  ['1F-ELA',   '1F-STA',   20, 'west'],
  ['1F-ELB',   '1F-STB',   20, 'east'],
  ['1F-COR',   '1F-GMED',  45, 'northwest'],
  ['1F-COR',   '1F-PED',   40, 'north'],
  ['1F-COR',   '1F-ENT',   45, 'northeast'],
  ['1F-COR',   '1F-OPTH',  45, 'southwest'],
  ['1F-COR',   '1F-DERM',  40, 'south'],
  ['1F-COR',   '1F-XRAY',  45, 'southeast'],
  ['1F-COR',   '1F-LAB',   35, 'west'],
  ['1F-COR',   '1F-BILL',  35, 'east'],

  // ── FLOOR 2 ────────────────────────────────────────────
  ['2F-ELA',   '2F-COR',   20, 'east'],
  ['2F-ELB',   '2F-COR',   20, 'west'],
  ['2F-STA',   '2F-COR',   40, 'southeast'],
  ['2F-STB',   '2F-COR',   40, 'southwest'],
  ['2F-ELA',   '2F-STA',   20, 'west'],
  ['2F-ELB',   '2F-STB',   20, 'east'],
  ['2F-COR',   '2F-ORTH',  45, 'northwest'],
  ['2F-COR',   '2F-SPM',   40, 'north'],
  ['2F-COR',   '2F-RHEU',  45, 'northeast'],
  ['2F-COR',   '2F-PHY',   45, 'southwest'],
  ['2F-COR',   '2F-OCC',   40, 'south'],
  ['2F-COR',   '2F-PLR',   45, 'southeast'],
  ['2F-COR',   '2F-MRD',   35, 'east'],

  // ── FLOOR 3 ────────────────────────────────────────────
  ['3F-ELA',   '3F-COR',   20, 'east'],
  ['3F-ELB',   '3F-COR',   20, 'west'],
  ['3F-STA',   '3F-COR',   40, 'southeast'],
  ['3F-STB',   '3F-COR',   40, 'southwest'],
  ['3F-ELA',   '3F-STA',   20, 'west'],
  ['3F-ELB',   '3F-STB',   20, 'east'],
  ['3F-COR',   '3F-CARD',  45, 'northwest'],
  ['3F-COR',   '3F-CICU',  40, 'north'],
  ['3F-COR',   '3F-ECHO',  45, 'northeast'],
  ['3F-COR',   '3F-CATH',  45, 'southwest'],
  ['3F-COR',   '3F-PULM',  40, 'south'],
  ['3F-COR',   '3F-RESP',  45, 'southeast'],
  ['3F-COR',   '3F-SLP',   35, 'east'],

  // ── FLOOR 4 ────────────────────────────────────────────
  ['4F-ELA',   '4F-COR',   20, 'east'],
  ['4F-ELB',   '4F-COR',   20, 'west'],
  ['4F-STA',   '4F-COR',   40, 'southeast'],
  ['4F-STB',   '4F-COR',   40, 'southwest'],
  ['4F-ELA',   '4F-STA',   20, 'west'],
  ['4F-ELB',   '4F-STB',   20, 'east'],
  ['4F-COR',   '4F-GYN',   45, 'northwest'],
  ['4F-COR',   '4F-ANC',   40, 'north'],
  ['4F-COR',   '4F-MAT',   45, 'northeast'],
  ['4F-COR',   '4F-LBR',   45, 'southwest'],
  ['4F-COR',   '4F-NICU',  40, 'south'],
  ['4F-COR',   '4F-LAC',   45, 'southeast'],

  // ── FLOOR 5 ────────────────────────────────────────────
  ['5F-ELA',   '5F-COR',   20, 'east'],
  ['5F-ELB',   '5F-COR',   20, 'west'],
  ['5F-STA',   '5F-COR',   40, 'southeast'],
  ['5F-STB',   '5F-COR',   40, 'southwest'],
  ['5F-ELA',   '5F-STA',   20, 'west'],
  ['5F-ELB',   '5F-STB',   20, 'east'],
  ['5F-COR',   '5F-NEUR',  45, 'northwest'],
  ['5F-COR',   '5F-NICU',  40, 'north'],
  ['5F-COR',   '5F-PSYC',  45, 'northeast'],
  ['5F-COR',   '5F-COUN',  45, 'southwest'],
  ['5F-COR',   '5F-MHW',   40, 'south'],
  ['5F-COR',   '5F-EEG',   45, 'southeast'],
  ['5F-COR',   '5F-MEM',   35, 'east'],

  // ── FLOOR 6 ────────────────────────────────────────────
  ['6F-ELA',   '6F-COR',   20, 'east'],
  ['6F-ELB',   '6F-COR',   20, 'west'],
  ['6F-STA',   '6F-COR',   40, 'southeast'],
  ['6F-STB',   '6F-COR',   40, 'southwest'],
  ['6F-ELA',   '6F-STA',   20, 'west'],
  ['6F-ELB',   '6F-STB',   20, 'east'],
  ['6F-COR',   '6F-GSUR',  45, 'northwest'],
  ['6F-COR',   '6F-URO',   40, 'north'],
  ['6F-COR',   '6F-PLS',   45, 'northeast'],
  ['6F-COR',   '6F-OT',    45, 'southwest'],
  ['6F-COR',   '6F-PREOP', 40, 'south'],
  ['6F-COR',   '6F-POSTOP',45, 'southeast'],
  ['6F-COR',   '6F-SICU',  35, 'east'],

  // ── FLOOR 7 ────────────────────────────────────────────
  ['7F-ELA',   '7F-COR',   20, 'east'],
  ['7F-ELB',   '7F-COR',   20, 'west'],
  ['7F-STA',   '7F-COR',   40, 'southeast'],
  ['7F-STB',   '7F-COR',   40, 'southwest'],
  ['7F-ELA',   '7F-STA',   20, 'west'],
  ['7F-ELB',   '7F-STB',   20, 'east'],
  ['7F-COR',   '7F-ONCO',  45, 'northwest'],
  ['7F-COR',   '7F-RADON', 40, 'north'],
  ['7F-COR',   '7F-CHEMO', 45, 'northeast'],
  ['7F-COR',   '7F-BMT',   45, 'southwest'],
  ['7F-COR',   '7F-BB',    40, 'south'],
  ['7F-COR',   '7F-HEM',   45, 'southeast'],
  ['7F-COR',   '7F-PAL',   35, 'east'],

  // ── FLOOR 8 ────────────────────────────────────────────
  ['8F-ELA',   '8F-COR',   20, 'east'],
  ['8F-ELB',   '8F-COR',   20, 'west'],
  ['8F-STA',   '8F-COR',   40, 'southeast'],
  ['8F-STB',   '8F-COR',   40, 'southwest'],
  ['8F-ELA',   '8F-STA',   20, 'west'],
  ['8F-ELB',   '8F-STB',   20, 'east'],
  ['8F-COR',   '8F-DIR',   45, 'northwest'],
  ['8F-COR',   '8F-MSUP',  40, 'north'],
  ['8F-COR',   '8F-HR',    45, 'northeast'],
  ['8F-COR',   '8F-FIN',   45, 'southwest'],
  ['8F-COR',   '8F-IT',    40, 'south'],
  ['8F-COR',   '8F-CONF',  45, 'southeast'],
  ['8F-COR',   '8F-SCAF',  35, 'east'],
  ['8F-COR',   '8F-ROOF',  35, 'west'],

  // ── VERTICAL – ELEVATOR BANK A (all floors, direction = "up") ──
  ['GF-ELA', '1F-ELA', 60, 'up'],
  ['1F-ELA', '2F-ELA', 60, 'up'],
  ['2F-ELA', '3F-ELA', 60, 'up'],
  ['3F-ELA', '4F-ELA', 60, 'up'],
  ['4F-ELA', '5F-ELA', 60, 'up'],
  ['5F-ELA', '6F-ELA', 60, 'up'],
  ['6F-ELA', '7F-ELA', 60, 'up'],
  ['7F-ELA', '8F-ELA', 60, 'up'],

  // ── VERTICAL – ELEVATOR BANK B ─────────────────────────
  ['GF-ELB', '1F-ELB', 60, 'up'],
  ['1F-ELB', '2F-ELB', 60, 'up'],
  ['2F-ELB', '3F-ELB', 60, 'up'],
  ['3F-ELB', '4F-ELB', 60, 'up'],
  ['4F-ELB', '5F-ELB', 60, 'up'],
  ['5F-ELB', '6F-ELB', 60, 'up'],
  ['6F-ELB', '7F-ELB', 60, 'up'],
  ['7F-ELB', '8F-ELB', 60, 'up'],

  // ── VERTICAL – NORTH STAIRWELL (30 s per floor) ────────
  ['GF-STA', '1F-STA', 30, 'up'],
  ['1F-STA', '2F-STA', 30, 'up'],
  ['2F-STA', '3F-STA', 30, 'up'],
  ['3F-STA', '4F-STA', 30, 'up'],
  ['4F-STA', '5F-STA', 30, 'up'],
  ['5F-STA', '6F-STA', 30, 'up'],
  ['6F-STA', '7F-STA', 30, 'up'],
  ['7F-STA', '8F-STA', 30, 'up'],

  // ── VERTICAL – SOUTH STAIRWELL ─────────────────────────
  ['GF-STB', '1F-STB', 30, 'up'],
  ['1F-STB', '2F-STB', 30, 'up'],
  ['2F-STB', '3F-STB', 30, 'up'],
  ['3F-STB', '4F-STB', 30, 'up'],
  ['4F-STB', '5F-STB', 30, 'up'],
  ['5F-STB', '6F-STB', 30, 'up'],
  ['6F-STB', '7F-STB', 30, 'up'],
  ['7F-STB', '8F-STB', 30, 'up'],
];

// ── Department metadata ───────────────────────────────────────────────────────

const departments = [
  // Ground Floor
  { name: 'Emergency Department',             shortName: 'Emergency',    locationCode: 'GF-EMG',  floor: 0, specialties: ['Emergency Medicine','Trauma','Resuscitation'],                         contactNumber: '080-12345678', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 2 },
  { name: 'Reception & Information',          shortName: 'Reception',    locationCode: 'GF-REC',  floor: 0, specialties: ['Patient Registration','Visitor Information','Helpdesk'],               contactNumber: '080-12345600', workingHours: { weekdays: '6:00 AM – 10:00 PM', weekends: '7:00 AM – 8:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'Pharmacy',                         shortName: 'Pharmacy',     locationCode: 'GF-PHA',  floor: 0, specialties: ['Dispensing','OTC Medicines','Drug Information'],                       contactNumber: '080-12345610', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 4 },
  { name: 'Trauma Center',                    shortName: 'Trauma',       locationCode: 'GF-TRM',  floor: 0, specialties: ['Trauma Surgery','Critical Care','Polytrauma'],                         contactNumber: '080-12345679', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 3 },
  // Floor 1
  { name: 'OPD – General Medicine',           shortName: 'General OPD',  locationCode: '1F-GMED', floor: 1, specialties: ['Internal Medicine','Diabetes','Hypertension','Infections'],             contactNumber: '080-12345620', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'OPD – Pediatrics',                 shortName: 'Pediatrics',   locationCode: '1F-PED',  floor: 1, specialties: ['Pediatrics','Neonatology','Vaccination','Child Development'],           contactNumber: '080-12345621', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 2 },
  { name: 'OPD – ENT',                        shortName: 'ENT',          locationCode: '1F-ENT',  floor: 1, specialties: ['Ear','Nose','Throat','Audiometry','Sinusitis'],                         contactNumber: '080-12345622', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 3 },
  { name: 'OPD – Ophthalmology',              shortName: 'Eye Clinic',   locationCode: '1F-OPTH', floor: 1, specialties: ['Cataract','Glaucoma','Retina','Refractive Errors','LASIK'],             contactNumber: '080-12345623', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 4 },
  { name: 'OPD – Dermatology',                shortName: 'Skin Clinic',  locationCode: '1F-DERM', floor: 1, specialties: ['Psoriasis','Eczema','Acne','Hair Loss','Cosmetology'],                  contactNumber: '080-12345624', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 5 },
  { name: 'Radiology & Imaging',              shortName: 'Radiology',    locationCode: '1F-XRAY', floor: 1, specialties: ['X-Ray','CT Scan','MRI','Ultrasound','Mammography'],                     contactNumber: '080-12345625', workingHours: { weekdays: '7:00 AM – 8:00 PM', weekends: '8:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 6 },
  { name: 'Blood Collection & Pathology Lab', shortName: 'Pathology Lab', locationCode: '1F-LAB', floor: 1, specialties: ['Hematology','Biochemistry','Microbiology','Histopathology'],            contactNumber: '080-12345626', workingHours: { weekdays: '6:00 AM – 8:00 PM', weekends: '7:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 7 },
  { name: 'Billing Counter',                  shortName: 'Billing',      locationCode: '1F-BILL', floor: 1, specialties: ['OPD Billing','Insurance Claims','Cashless'],                            contactNumber: '080-12345627', workingHours: { weekdays: '7:00 AM – 8:00 PM', weekends: '8:00 AM – 4:00 PM', is24x7: false }, ivrMenuNumber: 8 },
  // Floor 2
  { name: 'OPD – Orthopedics',                shortName: 'Orthopedics',  locationCode: '2F-ORTH', floor: 2, specialties: ['Fractures','Joint Replacement','Spine Surgery','Sports Injuries'],       contactNumber: '080-12345630', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'OPD – Sports Medicine',            shortName: 'Sports Med',   locationCode: '2F-SPM',  floor: 2, specialties: ['Ligament Injuries','Muscle Tears','Athletic Rehabilitation'],           contactNumber: '080-12345631', workingHours: { weekdays: '8:00 AM – 5:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 2 },
  { name: 'OPD – Rheumatology',               shortName: 'Rheumatology', locationCode: '2F-RHEU', floor: 2, specialties: ['Rheumatoid Arthritis','Lupus','Gout','Fibromyalgia'],                   contactNumber: '080-12345632', workingHours: { weekdays: '8:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 3 },
  { name: 'Physiotherapy Department',         shortName: 'Physio',       locationCode: '2F-PHY',  floor: 2, specialties: ['Physical Therapy','Electrotherapy','Hydrotherapy','Post-Op Rehab'],     contactNumber: '080-12345633', workingHours: { weekdays: '7:00 AM – 7:00 PM', weekends: '8:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 4 },
  { name: 'Occupational Therapy',             shortName: 'OT Therapy',   locationCode: '2F-OCC',  floor: 2, specialties: ['Functional Rehab','Stroke Rehab','Hand Therapy','ADL Training'],         contactNumber: '080-12345634', workingHours: { weekdays: '8:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 5 },
  { name: 'Plaster Room',                     shortName: 'Plaster Room', locationCode: '2F-PLR',  floor: 2, specialties: ['Fracture Casting','Fiberglass Cast','Plaster of Paris'],                contactNumber: '080-12345635', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 6 },
  { name: 'Medical Records Department',       shortName: 'Medical Records', locationCode: '2F-MRD', floor: 2, specialties: ['Patient Records','Discharge Summaries','Medical Certificates'],      contactNumber: '080-12345636', workingHours: { weekdays: '9:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 7 },
  // Floor 3
  { name: 'OPD – Cardiology',                 shortName: 'Cardiology',   locationCode: '3F-CARD', floor: 3, specialties: ['Heart Disease','Arrhythmia','Heart Failure','Interventional Cardiology'], contactNumber: '080-12345640', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'Cardiac ICU (CICU)',               shortName: 'CICU',         locationCode: '3F-CICU', floor: 3, specialties: ['Post-MI Care','Cardiac Monitoring','Hemodynamic Support'],              contactNumber: '080-12345641', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 2 },
  { name: 'Echo & ECG Laboratory',            shortName: 'Echo/ECG Lab', locationCode: '3F-ECHO', floor: 3, specialties: ['2D Echo','Stress Test','Holter Monitor','ECG','Doppler'],              contactNumber: '080-12345642', workingHours: { weekdays: '7:00 AM – 7:00 PM', weekends: '8:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 3 },
  { name: 'Catheterization Laboratory',       shortName: 'Cath Lab',     locationCode: '3F-CATH', floor: 3, specialties: ['Coronary Angiography','Angioplasty','Stenting','PTCA'],                 contactNumber: '080-12345643', workingHours: { weekdays: '7:00 AM – 7:00 PM', weekends: '8:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 4 },
  { name: 'OPD – Pulmonology',                shortName: 'Pulmonology',  locationCode: '3F-PULM', floor: 3, specialties: ['Asthma','COPD','Tuberculosis','Sleep Apnea','ILD'],                    contactNumber: '080-12345644', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 5 },
  { name: 'Respiratory Therapy',              shortName: 'Resp Therapy', locationCode: '3F-RESP', floor: 3, specialties: ['Nebulization','Spirometry','Chest Physio','Ventilator Management'],     contactNumber: '080-12345645', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 6 },
  { name: 'Sleep Disorders Lab',              shortName: 'Sleep Lab',    locationCode: '3F-SLP',  floor: 3, specialties: ['Polysomnography','Sleep Apnea','Insomnia','Narcolepsy'],               contactNumber: '080-12345646', workingHours: { weekdays: '8:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 7 },
  // Floor 4
  { name: 'OPD – Gynecology & Obstetrics',    shortName: 'Gynecology',   locationCode: '4F-GYN',  floor: 4, specialties: ['Gynecology','Obstetrics','PCOS','Infertility','Menopause'],             contactNumber: '080-12345650', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'Antenatal Clinic',                 shortName: 'ANC',          locationCode: '4F-ANC',  floor: 4, specialties: ['Prenatal Care','Anomaly Scan','High-Risk Pregnancy','Fetal Medicine'],  contactNumber: '080-12345651', workingHours: { weekdays: '8:00 AM – 5:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 2 },
  { name: 'Maternity Ward',                   shortName: 'Maternity',    locationCode: '4F-MAT',  floor: 4, specialties: ['Normal Delivery','Postnatal Care','Maternity Stay'],                    contactNumber: '080-12345652', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 3 },
  { name: 'Labor Room & Delivery Suite',      shortName: 'Labor Room',   locationCode: '4F-LBR',  floor: 4, specialties: ['Normal Delivery','Caesarean Section','Fetal Monitoring'],              contactNumber: '080-12345653', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 4 },
  { name: 'Neonatal ICU (NICU)',              shortName: 'NICU',         locationCode: '4F-NICU', floor: 4, specialties: ['Premature Infants','Neonatal Intensive Care','Phototherapy'],           contactNumber: '080-12345654', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 5 },
  { name: 'Lactation & Maternal Counseling',  shortName: 'Lactation',    locationCode: '4F-LAC',  floor: 4, specialties: ['Breastfeeding Support','Postpartum Care','Maternal Mental Health'],     contactNumber: '080-12345655', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 6 },
  // Floor 5
  { name: 'OPD – Neurology',                  shortName: 'Neurology',    locationCode: '5F-NEUR', floor: 5, specialties: ['Epilepsy','Migraine','Stroke','Parkinson\'s','Multiple Sclerosis'],     contactNumber: '080-12345660', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'Neurology ICU',                    shortName: 'Neuro ICU',    locationCode: '5F-NICU', floor: 5, specialties: ['Stroke Management','TBI','Status Epilepticus','Neuro Monitoring'],      contactNumber: '080-12345661', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 2 },
  { name: 'OPD – Psychiatry',                 shortName: 'Psychiatry',   locationCode: '5F-PSYC', floor: 5, specialties: ['Depression','Anxiety','Schizophrenia','Bipolar Disorder','Addiction'],  contactNumber: '080-12345662', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 3 },
  { name: 'Psychology & Counseling Center',   shortName: 'Counseling',   locationCode: '5F-COUN', floor: 5, specialties: ['Individual Therapy','Couple Therapy','Child Psychology','CBT'],          contactNumber: '080-12345663', workingHours: { weekdays: '9:00 AM – 6:00 PM', weekends: '10:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 4 },
  { name: 'Mental Health Ward',               shortName: 'MH Ward',      locationCode: '5F-MHW',  floor: 5, specialties: ['In-Patient Psychiatry','Therapeutic Programs','De-Addiction'],          contactNumber: '080-12345664', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 5 },
  { name: 'EEG & Neurophysiology Lab',        shortName: 'EEG Lab',      locationCode: '5F-EEG',  floor: 5, specialties: ['EEG','Nerve Conduction Study','EMG','Evoked Potentials'],              contactNumber: '080-12345665', workingHours: { weekdays: '8:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 6 },
  { name: 'Memory Clinic',                    shortName: 'Memory Clinic',locationCode: '5F-MEM',  floor: 5, specialties: ['Dementia','Alzheimer\'s','Cognitive Testing','Memory Disorders'],       contactNumber: '080-12345666', workingHours: { weekdays: '9:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 7 },
  // Floor 6
  { name: 'OPD – General Surgery',            shortName: 'General Surgery', locationCode: '6F-GSUR', floor: 6, specialties: ['Laparoscopy','Hernia','Gallbladder','Appendix','Colorectal'],      contactNumber: '080-12345670', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'OPD – Urology',                    shortName: 'Urology',      locationCode: '6F-URO',  floor: 6, specialties: ['Kidney Stones','Prostate','Bladder','Cystoscopy','Lithotripsy'],       contactNumber: '080-12345671', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 2 },
  { name: 'OPD – Plastic & Reconstructive Surgery', shortName: 'Plastic Surgery', locationCode: '6F-PLS', floor: 6, specialties: ['Burns','Cleft Lip','Reconstructive Surgery','Cosmetic Procedures'], contactNumber: '080-12345672', workingHours: { weekdays: '8:00 AM – 5:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 3 },
  { name: 'Operation Theatre Complex',        shortName: 'OT Complex',   locationCode: '6F-OT',   floor: 6, specialties: ['General Surgery','Orthopedic Surgery','Cardiac Surgery','Laparoscopy'], contactNumber: '080-12345673', workingHours: { weekdays: '7:00 AM – 9:00 PM', weekends: '7:00 AM – 5:00 PM', is24x7: false }, ivrMenuNumber: 4 },
  { name: 'Surgical ICU (SICU)',              shortName: 'SICU',         locationCode: '6F-SICU', floor: 6, specialties: ['Post-Op Care','Surgical Critical Care','Ventilator Management'],        contactNumber: '080-12345674', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 5 },
  // Floor 7
  { name: 'OPD – Oncology',                   shortName: 'Oncology',     locationCode: '7F-ONCO', floor: 7, specialties: ['Medical Oncology','Cancer Staging','Targeted Therapy','Immunotherapy'], contactNumber: '080-12345680', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 1 },
  { name: 'Radiation Oncology',               shortName: 'Radiotherapy', locationCode: '7F-RADON',floor: 7, specialties: ['LINAC Therapy','Brachytherapy','Stereotactic Radiosurgery','IMRT'],   contactNumber: '080-12345681', workingHours: { weekdays: '7:00 AM – 6:00 PM', weekends: '8:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 2 },
  { name: 'Chemotherapy Suite',               shortName: 'Chemo Suite',  locationCode: '7F-CHEMO',floor: 7, specialties: ['IV Chemotherapy','Oral Chemotherapy','Port Management','Day Care'],    contactNumber: '080-12345682', workingHours: { weekdays: '7:00 AM – 7:00 PM', weekends: '8:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 3 },
  { name: 'Bone Marrow Transplant Unit',      shortName: 'BMT Unit',     locationCode: '7F-BMT',  floor: 7, specialties: ['Autologous BMT','Allogeneic BMT','Stem Cell Therapy','Hematology'],    contactNumber: '080-12345683', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 4 },
  { name: 'Blood Bank',                       shortName: 'Blood Bank',   locationCode: '7F-BB',   floor: 7, specialties: ['Blood Donation','Blood Transfusion','Component Separation','Apheresis'], contactNumber: '080-12345684', workingHours: { weekdays: '24/7', weekends: '24/7', is24x7: true  }, ivrMenuNumber: 5 },
  { name: 'Hematology Laboratory',            shortName: 'Hematology Lab',locationCode: '7F-HEM', floor: 7, specialties: ['CBC','Peripheral Smear','Bone Marrow Biopsy','Coagulation Studies'],   contactNumber: '080-12345685', workingHours: { weekdays: '7:00 AM – 7:00 PM', weekends: '8:00 AM – 2:00 PM', is24x7: false }, ivrMenuNumber: 6 },
  { name: 'Palliative & Comfort Care',        shortName: 'Palliative',   locationCode: '7F-PAL',  floor: 7, specialties: ['Pain Management','End-of-Life Care','Hospice','Symptom Control'],      contactNumber: '080-12345686', workingHours: { weekdays: '8:00 AM – 6:00 PM', weekends: '9:00 AM – 1:00 PM', is24x7: false }, ivrMenuNumber: 7 },
  // Floor 8
  { name: "Hospital Director's Office",       shortName: 'Director',     locationCode: '8F-DIR',  floor: 8, specialties: ['Administration','Hospital Management'],                                 contactNumber: '080-12345690', workingHours: { weekdays: '9:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 1 },
  { name: "Medical Superintendent's Office",  shortName: 'Med Supt',     locationCode: '8F-MSUP', floor: 8, specialties: ['Clinical Governance','Complaints','Medical Administration'],            contactNumber: '080-12345691', workingHours: { weekdays: '9:00 AM – 5:00 PM', weekends: 'Closed',          is24x7: false }, ivrMenuNumber: 2 },
  { name: 'Conference Hall & CME Centre',     shortName: 'Conference',   locationCode: '8F-CONF', floor: 8, specialties: ['Medical Education','Seminars','CME Programs'],                          contactNumber: '080-12345695', workingHours: { weekdays: '8:00 AM – 8:00 PM', weekends: '9:00 AM – 5:00 PM', is24x7: false }, ivrMenuNumber: 6 },
];

module.exports = { locations, connections, departments };
