# Software Requirements Specification (SRS)
## Indoor Hospital Navigation System

**Document ID:** SRS-HNS-001  
**Version:** 1.0  
**Date:** 2026-04-15  
**Prepared for:** Academic/Engineering Review  
**Standard Basis:** IEEE 29148-aligned structure (compatible with IEEE 830 style sectioning)

---

## Revision History

| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | 2026-04-15 | Project Team | Initial formal SRS baseline |

---

## Table of Contents

1. Introduction  
2. Overall Description  
3. External Interface Requirements  
4. System Features and Functional Requirements  
5. Non-Functional Requirements  
6. Data Requirements  
7. Verification and Acceptance Criteria  
8. Appendices  

---

## 1. Introduction

### 1.1 Purpose
This document specifies the complete software requirements for an indoor hospital navigation system that computes and presents navigation routes on floor maps. The system provides (i) shortest-path computation over a weighted indoor graph, (ii) turn-by-turn textual guidance, (iii) map-based visual guidance, and (iv) optional Pedestrian Dead Reckoning (PDR)-assisted position tracking.  

This SRS is intended for developers, testers, reviewers, and project stakeholders. It defines verifiable requirements and acceptance criteria to support implementation, validation, and future maintenance.

### 1.2 Scope
The software system enables users to:
- select a start location and destination from hospital rooms,
- compute a route through graph nodes/edges representing indoor pathways,
- view route distance and floor traversal,
- receive structured directions,
- visualize route geometry and turn points on SVG floor maps,
- optionally run simulation mode and sensor-based PDR tracking.

The scope includes client-side processing in a Flutter application. External server-side route computation is not part of this baseline release.

### 1.3 Definitions, Acronyms, and Abbreviations
- **A\***: Informed graph search algorithm for least-cost pathfinding.
- **PDR**: Pedestrian Dead Reckoning; step and heading-based position update.
- **POI**: Point of Interest (e.g., OPD room, waiting area, billing).
- **Node**: Graph vertex representing room/junction/lift/stairs.
- **Edge**: Graph link with metric distance weight.
- **Accessible Mode**: Route mode constrained to accessible connections.
- **SRS**: Software Requirements Specification.

### 1.4 References
- IEEE 29148: Systems and software engineering — Life cycle processes — Requirements engineering.
- IEEE 830 (legacy structure): Recommended practice for SRS.
- Flutter SDK documentation.
- `assets/data/hospital_nav_graph.json` schema used in this project.

### 1.5 Document Conventions
- Normative statements use **shall**.
- Recommendations use **should**.
- Optional behavior uses **may**.
- Requirement identifiers are formatted as `REQ-<CATEGORY>-<NUMBER>`.

---

## 2. Overall Description

### 2.1 Product Perspective
The system is a standalone client application built with Flutter and rendered primarily on SVG floor maps. It uses an internal navigation graph loaded from local assets. Core subsystems are:
1. Graph loading and model construction.
2. Pathfinding and route reconstruction.
3. Direction generation (instruction synthesis).
4. Visual map rendering (path, arrows, markers).
5. State management for navigation, simulation, and PDR.

### 2.2 Product Functions (Summary)
- Load graph metadata, nodes, and edges from JSON assets.
- Search room nodes by name.
- Select source and destination.
- Compute shortest path with weighted edges.
- Compute route distance in meters.
- Generate turn-by-turn guidance.
- Render route and direction indicators.
- Support manual floor switching.
- Support optional accessible routing mode.
- Support optional simulation and PDR debug workflows.

### 2.3 User Classes and Characteristics
1. **Visitors/Patients**: Non-technical users requiring clear and concise wayfinding.
2. **Hospital Staff**: Frequent users requiring rapid route setup.
3. **Developers/Testers**: Technical users validating navigation correctness and UI behavior.

### 2.4 Operating Environment
- Runtime: Flutter application.
- Platforms: Web and desktop-class environments (Windows/macOS/Linux), with mobile-compatible architecture.
- Data source: Local bundled assets (`assets/data`, `assets/maps`).
- Sensors (optional): Accelerometer/Gyroscope/Magnetometer via `sensors_plus`.

### 2.5 Design and Implementation Constraints
- The route engine shall preserve graph-based A\* routing semantics.
- Asset-based map and graph files shall be available at runtime.
- Coordinate geometry is expressed in map pixel space; distances are edge-metric (meters).
- The UI shall remain operational without network connectivity.

### 2.6 Assumptions and Dependencies
- Graph JSON contains valid node IDs and edge references.
- Edge distances are pre-calibrated in meters.
- Floor maps correspond to graph coordinate space.
- PDR accuracy depends on hardware sensor quality and calibration.

---

## 3. External Interface Requirements

### 3.1 User Interfaces
#### 3.1.1 Primary Map Screen
- **REQ-UI-001:** The system shall display an interactive floor map with zoom/pan support.
- **REQ-UI-002:** The system shall provide controls for floor switching.
- **REQ-UI-003:** The system shall provide controls for selecting start and destination nodes.
- **REQ-UI-004:** The system shall display computed route distance and visited floors.
- **REQ-UI-005:** The system shall provide a route clear/reset action.

#### 3.1.2 Directions Panel
- **REQ-UI-006:** The system shall display ordered turn-by-turn instructions.
- **REQ-UI-007:** Each instruction shall include a maneuver icon and text.
- **REQ-UI-008:** Distance-bearing instructions shall display metric values in meters.
- **REQ-UI-009:** The panel shall remain usable on constrained viewport sizes (collapsed/expanded behavior).

#### 3.1.3 Visual Guidance Overlay
- **REQ-UI-010:** The route path shall be rendered as a polyline over the map.
- **REQ-UI-011:** The start point shall be rendered with a green marker.
- **REQ-UI-012:** The destination point shall be rendered with a red marker.
- **REQ-UI-013:** Turn points shall be rendered as distinct markers.
- **REQ-UI-014:** Directional arrow cues shall be rendered along route segments.

### 3.2 Software Interfaces
- **REQ-SI-001:** The system shall ingest graph data from `assets/data/hospital_nav_graph.json`.
- **REQ-SI-002:** The system shall ingest floor maps from `assets/maps/`.
- **REQ-SI-003:** The system shall use Provider-based state management for navigation state propagation.
- **REQ-SI-004:** If PDR mode is enabled, the system shall interface with motion sensors through `sensors_plus`.

### 3.3 Hardware Interfaces
- **REQ-HW-001:** Sensor-driven features shall require device motion sensors; absent sensors shall not crash the application.
- **REQ-HW-002:** Non-sensor features (graph routing and map rendering) shall function without hardware sensor availability.

### 3.4 Communications Interfaces
- **REQ-COM-001:** Baseline navigation operation shall not require network communication.

---

## 4. System Features and Functional Requirements

### 4.1 Graph Loading and Validation
- **REQ-FN-001:** On startup, the system shall load graph JSON and construct in-memory node/edge models.
- **REQ-FN-002:** The system shall parse graph metadata, including `pixelsPerMeter`.
- **REQ-FN-003:** Bidirectional edges shall be represented in adjacency structures for traversal.
- **REQ-FN-004:** If graph load fails, the system shall enter a safe fallback state without application termination.

### 4.2 Location Search and Selection
- **REQ-FN-010:** The system shall provide case-insensitive search over room nodes.
- **REQ-FN-011:** Selecting a start node shall set active floor to the start node floor.
- **REQ-FN-012:** Selecting destination shall trigger route computation when start exists.
- **REQ-FN-013:** Route state shall be cleared when the user invokes clear action.

### 4.3 Route Computation
- **REQ-FN-020:** The system shall compute a minimum-cost route using A\* over weighted edges.
- **REQ-FN-021:** Edge weights shall be interpreted in meters.
- **REQ-FN-022:** Inaccessible links/nodes shall be excluded when accessible mode is enabled.
- **REQ-FN-023:** If no route exists, the system shall return a null/empty route state and retain UI stability.
- **REQ-FN-024:** Route distance shall equal the sum of edge distances along the computed path.

### 4.4 Direction Generation (Turn-by-Turn)
- **REQ-FN-030:** The system shall convert raw path nodes into structured instructions.
- **REQ-FN-031:** The system shall classify maneuvers using vector geometry between successive path segments.
- **REQ-FN-032:** Maneuver classes shall include, at minimum: straight, left, right, floor-change, arrive.
- **REQ-FN-033:** The system should classify slight-left and slight-right where angular thresholds are met.
- **REQ-FN-034:** Consecutive collinear or near-collinear edges shall be merged into a single distance instruction.
- **REQ-FN-035:** Instruction text shall include explicit distances where applicable (e.g., “Walk straight for Xm”).
- **REQ-FN-036:** The first instruction shall identify start location; the final instruction shall identify destination.

### 4.5 Landmark-Aware Guidance
- **REQ-FN-040:** The system shall attempt to attach nearby landmarks/POIs to turn instructions when available.
- **REQ-FN-041:** Landmark selection shall be restricted to same-floor candidates within a bounded proximity threshold.
- **REQ-FN-042:** If no reliable landmark is found, instruction generation shall remain valid without landmark text.

### 4.6 Visual Navigation Synchronization
- **REQ-FN-050:** The set of turn markers shown on map shall correspond to turn events in the instruction list.
- **REQ-FN-051:** Directional arrows shall align with route segment orientation.
- **REQ-FN-052:** Simulation or PDR current position indicator shall be overlayed without obscuring start/end semantics.

### 4.7 Floor Handling
- **REQ-FN-060:** The system shall support floor-filtered rendering of route geometry.
- **REQ-FN-061:** Manual floor switching shall not discard current route.
- **REQ-FN-062:** Floor-transition instructions shall be generated when path includes cross-floor movement.

### 4.8 PDR and Map-Matching (Optional Operation)
- **REQ-FN-070:** When PDR is enabled and origin is initialized, step events shall update user position estimates.
- **REQ-FN-071:** The system shall perform map-matching by projecting estimated position onto nearest active route segment on the same floor.
- **REQ-FN-072:** Position correction shall apply only within configured deviation threshold; outside threshold, raw position may be retained.
- **REQ-FN-073:** PDR mode shall be user-toggleable at runtime.

### 4.9 Simulation
- **REQ-FN-080:** Simulation mode shall animate traversal from start node to destination over route path points.
- **REQ-FN-081:** Simulation shall update floor context when route enters a different floor.
- **REQ-FN-082:** Simulation shall terminate automatically at route completion or when stopped by user.

---

## 5. Non-Functional Requirements

### 5.1 Performance
- **REQ-NF-001:** For graphs up to 500 nodes and 1500 edges, route computation shall complete within 200 ms on a typical desktop browser environment.
- **REQ-NF-002:** UI interaction (search input, panel expand/collapse, floor switch) shall maintain perceptible responsiveness (<100 ms interaction latency target).
- **REQ-NF-003:** Map rendering shall sustain smooth pan/zoom behavior without frame-stall artifacts under normal route overlay complexity.

### 5.2 Reliability and Availability
- **REQ-NF-010:** Application shall not crash when graph data fails to load; graceful fallback behavior is mandatory.
- **REQ-NF-011:** State transitions (start/destination updates, route clear, mode toggles) shall be deterministic and recoverable.

### 5.3 Usability
- **REQ-NF-020:** Instruction phrasing shall be concise, directive, and unambiguous.
- **REQ-NF-021:** Visual encoding shall use consistent color semantics (start=green, destination=red, turn=distinct warning/accent).
- **REQ-NF-022:** Distance display units shall be metric and consistent across UI elements.

### 5.4 Maintainability
- **REQ-NF-030:** Direction analysis logic shall be modularized from pathfinding logic.
- **REQ-NF-031:** Instruction synthesis shall be implemented as a separate component from geometry analysis.
- **REQ-NF-032:** Rendering logic shall be isolated from path analysis/generation logic.
- **REQ-NF-033:** New POI classes and floors shall be incorporable by data update without mandatory algorithm redesign.

### 5.5 Portability
- **REQ-NF-040:** Core routing and instruction logic shall remain platform-agnostic and executable across Flutter-supported targets.

### 5.6 Security and Privacy
- **REQ-NF-050:** The system shall process navigation and sensor data locally in baseline mode.
- **REQ-NF-051:** No personally identifiable information shall be required for core navigation functionality.

---

## 6. Data Requirements

### 6.1 Graph Data Schema (Logical)
The navigation graph shall define:
- `metadata`: version, building identifier, `pixelsPerMeter`, optional penalties.
- `floors`: floor IDs and labels.
- `nodes`: `{id, name, type, x, y, floor, accessible, ...}`.
- `edges`: `{from, to, distance, type, bidirectional}`.

### 6.2 Data Integrity Constraints
- **REQ-DT-001:** Each edge endpoint shall reference an existing node ID.
- **REQ-DT-002:** Distances shall be positive real values.
- **REQ-DT-003:** Node IDs shall be unique.
- **REQ-DT-004:** Floor IDs used in nodes shall exist in floor metadata.
- **REQ-DT-005:** Coordinate system shall be consistent with map rendering coordinate frame.

### 6.3 Retention and Persistence
- **REQ-DT-010:** Graph/map assets shall be read-only at runtime in baseline client mode.
- **REQ-DT-011:** User route state may be held in memory for current session only unless persistence is explicitly added in future revisions.

---

## 7. Verification and Acceptance Criteria

### 7.1 Functional Verification Matrix (Representative)

| Requirement ID | Verification Method | Acceptance Criterion |
|---|---|---|
| REQ-FN-020 | Unit + integration test | Computed path cost equals minimal known benchmark on test graph |
| REQ-FN-024 | Unit test | `totalDistance == sum(edge.distance)` for reconstructed route |
| REQ-FN-034 | Unit test | Collinear 3+ edge chain yields one straight instruction segment |
| REQ-FN-050 | Integration/UI test | Number and indices of turn markers match generated turn events |
| REQ-UI-011/012 | UI test | Start rendered green; destination rendered red |
| REQ-FN-071 | Simulation test | Snapped PDR position projects to nearest route segment on same floor |
| REQ-NF-001 | Performance benchmark | Route result produced within 200 ms for reference graph size |

### 7.2 Test Data Strategy
- Synthetic micro-graphs for deterministic angle and turn tests.
- Real hospital graph assets for integration validation.
- Edge cases: disconnected graphs, zero-result search queries, same start/destination, single-edge paths, multi-floor transitions.

### 7.3 Exit Criteria
The release baseline is acceptable when:
1. All critical functional requirements (`REQ-FN-*` core routing and directions) pass.
2. No crash-level defects remain in startup, route computation, and route rendering flows.
3. Performance and UI acceptance checks meet thresholds defined in Section 5.

---

## 8. Appendices

### 8.1 Architectural Mapping (Current Implementation)
- Graph loading: `GraphLoaderService`
- Navigation state orchestration: `NavigationProvider`
- Pathfinding: `PathfindingService`
- Path analysis: `PathAnalyzer`
- Instruction synthesis: `DirectionGenerator`
- Route rendering: `PathOverlay`, `FloorMapView`
- Instruction presentation: `DirectionsPanel`
- Optional movement sources: `SimulationProvider`, `PdrProvider`

### 8.2 Future Extensions (Non-Baseline)
- Re-routing when off-route threshold is exceeded.
- Multi-building and campus-level routing.
- Real-time crowd-aware edge weighting.
- Voice navigation output and multilingual instruction generation.

### 8.3 Requirement Prioritization
- **High Priority:** REQ-FN-001..036, REQ-UI-001..014, REQ-NF-001/010/020.
- **Medium Priority:** REQ-FN-040..082, REQ-NF-030..033.
- **Low Priority:** Extended analytics, persistence, and advanced predictive rerouting.

---

## Approval

Prepared by: ____________________  
Reviewed by: ____________________  
Approved by: ____________________  
Date: ____________________

