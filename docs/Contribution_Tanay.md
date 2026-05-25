# 1. Personal Information
* **Name:** Tanay
* **SRN:** [To Be Filled]
* **Role:** Core Developer
* **Assigned Responsibilities:** Navigation algorithm implementation.

# 2. Contribution Overview
Tanay served as the lead algorithm engineer for the project, taking full responsibility for the core pathfinding logic. He successfully implemented, optimized, and integrated the A* (A-Star) search algorithm, allowing the application to compute the shortest and most efficient indoor routes accurately.

# 3. Detailed Work Performed
* **Task 1: Algorithm Research & Selection:** Evaluated various pathfinding algorithms (Dijkstra, BFS, A*) and determined A* was optimal for weighted graph traversal in a 2D/3D indoor environment.
* **Task 2: A* Implementation:** Developed the core algorithm to traverse the node-edge graph, calculating cost (g(n)) and heuristic (h(n)) values.
* **Task 3: Turn-by-Turn Logic:** Implemented geometric logic to parse the resulting path array into discrete step-by-step instructions based on vector angles.
* **Team Collaboration:** Interfaced closely with Basavaraj (who managed the `node.dart` and `edge.dart` structures) to ensure the algorithm efficiently parsed the data models.

# 4. Technical Contribution
* **Tools Used:** VS Code, Dart DevTools.
* **Technologies Involved:** Dart (Data structures, Collections, Priority Queues).
* **Modules/Files Worked On:** `src/algorithms/a_star.dart`, `src/algorithms/path_parser.dart`.
* **Technical Decisions Made:** Selected Euclidean distance as the heuristic function to guarantee admissible and consistent estimations. Utilized Min-Heaps (Priority Queues) to optimize the retrieval of the lowest-cost node during graph traversal.

# 5. Methodology Followed
* **Working Process:** Adopted a Test-Driven Development (TDD) approach. Began by testing the algorithm on small, mock text-based graphs before integrating it with the massive hospital datasets.
* **Problem-Solving Approach:** Focused on mathematical correctness and algorithmic efficiency to ensure zero UI lag during path computation, even on older mobile devices.

# 6. Challenges Faced
* **Technical Challenges:** Handling multi-floor routing logic, specifically weighting the cost of taking stairs versus an elevator.
* **Practical Limitations:** Debugging pathfinding edge-cases where disconnected graph nodes could cause infinite loops or algorithm crashes.

# 7. Solutions Implemented
* Introduced specialized virtual edges with high traversal weights for inter-floor transitions to realistically model the time taken to switch floors.
* Implemented fail-safes and graph validation checks before executing A* to gracefully handle unreachable destination errors.

# 8. Learning Outcomes
* Mastered the practical implementation of complex graph traversal algorithms in a production environment.
* Learned how to optimize data structures (Heaps, HashMaps) for memory and performance efficiency in Dart.

# 9. Contribution Impact
Tanay’s algorithmic implementation is the fundamental brain of the application. His highly optimized A* algorithm ensures that the core requirement (FR-2) is met efficiently, directly enabling the primary utility of the Hospital Indoor Navigation System.
