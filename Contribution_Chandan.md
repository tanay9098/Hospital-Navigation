# Personal Information  
**Name:** Chandan M K  
**SRN:** PES1PG24CA234  
**Assigned Responsibilities:** Ground visits and real-world validation; Identifying regions/places to include; Identifying blueprint differences; Developed graph plotting tool for SVG floor maps; Integration of all features.  

# Contribution Overview  
I played a pivotal dual role, bridging the physical real-world environment with the digital application architecture. I led the on-site verification process to ensure digital accuracy and developed a proprietary graph-plotting utility that drastically reduced the time required to map SVG floors. Furthermore, I acted as a primary integration specialist, merging disparate modules into a cohesive application.  

# Detailed Work Performed  
*   **Task 1: Physical Validation:** I conducted extensive ground visits to the hospital. I cross-referenced digital blueprints with physical reality to identify missing corridors, blocked paths, and unmapped POIs (Points of Interest).  
*   **Task 2: Tool Development:** I built a custom internal software tool that allows developers to visually click on SVG maps to generate underlying mathematical graph nodes and edges automatically.  
*   **Task 3: Integration:** I managed the merge pipeline, connecting the UI, algorithms, and data structures.  
*   **Task 4: Screen Design:** I designed all major UI screens, including the Home Screen, Location Selection (Search/Dropdowns), and the primary Map Navigation View.  
*   **Task 5: Pedestrian Dead Reckoning System (PDR):** I engineered the core indoor navigation logic utilizing PDR technology, processing step counts and directional data to accurately map user movement through the facility.  

# Technical Contribution  
*   **Tools Used:** Custom-built graph-plotter, VS Code, Git.  
*   **Technologies Involved:** Dart, JSON (for exporting graph data), UI/Canvas rendering for the internal tool.  
*   **Modules/Files Worked On:** `tools/graph_plotter`, `lib/main.dart`, Application core configuration files.  
*   **Technical Decisions Made:** I decided to build an internal tool rather than manually writing JSON graph data, saving weeks of manual data entry and preventing human error in coordinate mapping.  

# Methodology Followed  
*   **Execution Strategy:** Field-first approach. I recognized that the best algorithm is useless if the underlying map data is flawed. I prioritized real-world accuracy before finalizing the graph data.  
*   **Integration Approach:** I used iterative integration, continuously merging small feature branches to prevent massive merge conflicts at the end of the development cycle.  

# Challenges Faced  
*   **Technical Challenges:** Synchronizing the output of the custom graph plotting tool with the exact data model requirements of `node.dart` and `edge.dart`.  
*   **Practical Limitations:** Dealing with restricted access to certain hospital zones during ground visits, which required careful estimation.  

# Solutions Implemented  
*   I designed the graph plotting tool to export strictly validated JSON arrays that mapped 1:1 with the application’s serialization logic.  
*   I established a feedback loop with Basavaraj to systematically review and correct discrepancies identified during ground visits.  

# Contribution Impact  
My custom tooling saved the team immense manual labor, while my ground-truthing efforts ensured the application was not just theoretically sound, but practically functional in the real world. My system integration efforts were crucial in delivering a unified, working product.  
