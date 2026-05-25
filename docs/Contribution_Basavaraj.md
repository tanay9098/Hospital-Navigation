# 1. Personal Information

-   **Name:** Basavaraj
-   **SRN:** \[To Be Filled\]
-   **Role:** Core Developer
-   **Assigned Responsibilities:** Ground visits and real-world
    validation; Identifying regions/places to include; Blueprint
    correction verification; Plotting graphs for floor maps; Handled
    `floor.dart`, `edge.dart`, `node.dart`, `floor_config.dart` files.

# 2. Contribution Overview

Basavaraj was responsible for defining and managing the core data
structures that model the physical hospital environment. By structuring
the fundamental building blocks of the application (`node`, `edge`,
`floor`), he provided the robust foundation upon which the navigation
algorithms operated. He also actively participated in field validation
and graph plotting.

# 3. Detailed Work Performed

-   **Task 1: Core Data Modeling:** Architected the Object-Oriented
    representations of the hospital environment. Created the classes and
    parameters required for `node.dart`, `edge.dart`, `floor.dart`, and
    `floor_config.dart`.
-   **Task 2: Map Graphing:** Utilized Chandan's tool and manual review
    to plot accurate graphs overlaying the SVG maps.
-   **Task 3: Field Verification:** Accompanied Chandan on ground
    visits, documenting specific coordinates, room numbers, and physical
    discrepancies to update the blueprints.

# 4. Technical Contribution

-   **Tools Used:** VS Code, Git, JSON data validators.
-   **Technologies Involved:** Dart (Object-Oriented Programming,
    Serialization/Deserialization).
-   **Modules/Files Worked On:** `src/models/node.dart`,
    `src/models/edge.dart`, `src/models/floor.dart`,
    `src/models/floor_config.dart`.
-   **Technical Decisions Made:** Implemented strict typing and factory
    constructors for the data models to ensure safe parsing of offline
    JSON map data. Included properties in `node.dart` to specify if a
    node represents a transition point (elevator/stairs).

# 5. Methodology Followed

-   **Working Process:** Employed domain-driven design principles.
    Designed the data models to mimic the physical reality of the
    hospital as closely as possible.
-   **Problem-Solving Approach:** Addressed the complexity of
    multi-floor navigation by abstracting floor configurations into
    `floor_config.dart`, keeping the core node/edge logic clean and
    highly decoupled.

# 6. Challenges Faced

-   **Technical Challenges:** Creating a robust data structure that
    could handle thousands of nodes and edges without memory bloat or
    slow deserialization times.
-   **Practical Limitations:** Ensuring the graph data accurately
    reflected the architectural nuances of the hospital, such as one-way
    corridors or restricted staff-only areas.

# 7. Solutions Implemented

-   Optimized the data models by using minimal required properties and
    efficient referencing (using ID strings rather than deeply nested
    objects).
-   Implemented accessibility flags within `edge.dart` to allow the
    routing algorithm to filter out restricted areas.

# 8. Learning Outcomes

-   Deepened knowledge of Object-Oriented design patterns and data
    modeling in Dart.
-   Gained experience in managing large datasets on mobile devices via
    efficient serialization.
-   Understood the critical relationship between abstract data
    structures and real-world physical constraints.

# 9. Contribution Impact

Basavaraj's robust data structures form the backbone of the application.
His meticulous handling of the core `.dart` files ensured that Tanay's
A\* algorithm had clean, reliable, and efficiently structured data to
process, directly guaranteeing the stability of the navigation system.
