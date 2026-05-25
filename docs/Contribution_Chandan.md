# 1. Personal Information
* **Name:** Chandan
* **SRN:** [To Be Filled]
* **Role:** Core Developer
* **Assigned Responsibilities:** Ground visits and real-world validation; Identifying regions/places to include; Identifying blueprint differences; Developed graph plotting tool for SVG floor maps; Calibration of measurements; Integration of all features.

# 2. Contribution Overview
Chandan played a pivotal dual role, bridging the physical real-world environment with the digital application architecture. He led the on-site verification process to ensure digital accuracy and developed a proprietary graph-plotting utility that drastically reduced the time required to map SVG floors. Furthermore, he acted as a primary integration specialist, merging disparate modules into a cohesive application.

# 3. Detailed Work Performed
* **Task 1: Physical Validation:** Conducted extensive ground visits to the hospital. Cross-referenced digital blueprints with physical reality to identify missing corridors, blocked paths, and unmapped POIs (Points of Interest).
* **Task 2: Tool Development:** Built a custom internal software tool that allows developers to visually click on SVG maps to generate underlying mathematical graph nodes and edges automatically.
* **Task 3: Calibration:** Calibrated the pixel-to-meter ratio on the SVGs to ensure the algorithm's distance calculations matched real-world distances accurately.
* **Task 4: Integration:** Managed the merge pipeline, connecting the UI, algorithms, and data structures.

# 4. Technical Contribution
* **Tools Used:** Custom built graph-plotter, VS Code, Git.
* **Technologies Involved:** Dart, JSON (for exporting graph data), UI/Canvas rendering for the internal tool.
* **Modules/Files Worked On:** `tools/graph_plotter`, `src/main.dart`, Application core configuration files.
* **Technical Decisions Made:** Decided to build an internal tool rather than manually writing JSON graph data, saving weeks of manual data entry and preventing human error in coordinate mapping.

# 5. Methodology Followed
* **Execution Strategy:** Field-first approach. Chandan recognized that the best algorithm is useless if the underlying map data is flawed. He prioritized real-world accuracy before finalizing the graph data.
* **Integration Approach:** Used iterative integration, continuously merging small feature branches to prevent massive merge conflicts at the end of the development cycle.

# 6. Challenges Faced
* **Technical Challenges:** Synchronizing the output of the custom graph plotting tool with the exact data model requirements of `node.dart` and `edge.dart`.
* **Practical Limitations:** Dealing with restricted access to certain hospital zones during ground visits, requiring careful estimation.

# 7. Solutions Implemented
* Designed the graph plotting tool to export strictly validated JSON arrays that mapped 1:1 with the application's serialization logic.
* Established a feedback loop with Basavaraj to systematically review and correct discrepancies identified during ground visits.

# 8. Learning Outcomes
* Gained extensive experience in internal tooling development to streamline project workflows.
* Learned the complexities of spatial mapping and real-world to digital calibration.
* Developed strong project management and code integration skills.

# 9. Contribution Impact
Chandan’s custom tooling saved the team immense manual labor, while his ground-truthing ensured the application was not just theoretically sound, but practically functional in the real world. His system integration efforts were crucial in delivering a unified, working product.
