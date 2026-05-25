# 1. Project Name
Hospital Indoor Navigation System

# 2. Team Members

| Team Member Name | SRN | Role | Major Responsibility |
| :--- | :--- | :--- | :--- |
| Niteesh | [To Be Filled] | Core Developer | Preparation of SVG maps from hospital blueprints; Multi-lingual audio implementation. |
| Tanay | [To Be Filled] | Core Developer | Navigation algorithm (A*) implementation. |
| Chandan | [To Be Filled] | Core Developer | Ground visits and validation; Identifying regions to include; Identifying blueprint differences; Developed graph plotting tool for SVG floor maps; Calibration of measurements; Integration of all features. |
| Basavaraj | [To Be Filled] | Core Developer | Ground visits and validation; Identifying regions to include; Blueprint correction verification; Plotting graphs for floor maps; Handled core data structures (`floor.dart`, `edge.dart`, `node.dart`, `floor_config.dart`). |
| Shwetha | [To Be Filled] | Frontend Developer | UI (User Interface) design and implementation of the application. |
| Arnab | [To Be Filled] | Core Developer | Multilingual text localization and implementation. |

*Assumption: SRNs and specific formal Role titles were not provided and have been marked for manual entry.*

# 3. Functionalities Implemented

## FR-1 — Manual Source & Destination Selection
* **Purpose:** To allow users to define their journey by manually inputting or selecting their starting point and desired destination within the hospital.
* **Description:** The system provides an interactive UI where users can search for, select from a list, or tap on the map to specify their current location (source) and target location (destination).
* **Technical Implementation:** Implemented using dropdown menus or a search bar integrated with the UI. When a user selects a location, the application maps the string-based location name to a specific `Node` object (handled in `node.dart`) on the corresponding floor. 
* **Responsible Module(s):** UI Module, Core Navigation Module
* **Team Member(s):** Shwetha (UI), Basavaraj (Node logic)
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Requires the user to know their starting location if GPS/indoor positioning is not automatically resolving it.

## FR-2 — Shortest Path Computation Using A* Algorithm
* **Purpose:** To compute the most efficient route between the selected source and destination.
* **Description:** The system employs the A* (A-Star) pathfinding algorithm to calculate the shortest path.
* **Technical Implementation:** A* was selected because of its performance and accuracy in pathfinding on weighted graphs using a heuristic. The hospital floor is represented as a mathematical graph. Locations are nodes (`node.dart`), and navigable paths are edges (`edge.dart`). The algorithm uses Euclidean distance as the heuristic function to estimate the cost from a given node to the destination, ensuring an optimal path is found with minimal computational overhead.
* **Responsible Module(s):** Algorithm Module
* **Team Member(s):** Tanay
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** The accuracy heavily depends on the correctness of the plotted graph and calibration of distances.

## FR-3 — Multi-Floor Navigation Support
* **Purpose:** To guide users across different floors of the hospital seamlessly.
* **Description:** The system computes paths that span multiple floors, routing users to transition points like staircases or elevators.
* **Technical Implementation:** The graph is represented as a 3D interconnected structure. Nodes representing elevators or stairs on one floor are connected to corresponding nodes on other floors via virtual vertical edges. The A* algorithm computes the path through these transition nodes. The configuration of floors and their interconnectivity is managed in `floor_config.dart` and `floor.dart`.
* **Responsible Module(s):** Algorithm Module, Core Data Structures
* **Team Member(s):** Tanay, Basavaraj
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Users must manually acknowledge when they have transitioned between floors to continue the route.

## FR-4 — Visual Route Display on Hospital Maps
* **Purpose:** To visually guide the user by drawing the computed path on a digital map.
* **Description:** The application renders hospital floor blueprints as SVG images and overlays the calculated route as a colored line or sequence of markers.
* **Technical Implementation:** SVG (Scalable Vector Graphics) maps were prepared from hospital blueprints. A custom graph plotting tool was developed to overlay nodes and edges onto these SVGs. The computed shortest path (a list of Nodes) is translated into X,Y coordinates on the SVG canvas. The path is dynamically drawn using a canvas rendering library.
* **Responsible Module(s):** Mapping Module, UI Module
* **Team Member(s):** Niteesh, Chandan, Shwetha
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Relies on accurate alignment/calibration between the logical graph coordinates and the SVG visual coordinates.

## FR-5 — Step-by-Step Navigation Instructions
* **Purpose:** To provide granular, turn-by-turn textual guidance.
* **Description:** The system breaks down the continuous path into discrete, actionable instructions (e.g., "Go straight for 10 meters", "Turn left at the corridor").
* **Technical Implementation:** The system analyzes the geometry of the computed path. By calculating the angles between consecutive edges, the system determines whether a transition is a "straight", "left turn", or "right turn". Distances are calculated using edge weights and calibrated metrics, then formatted into localized text strings.
* **Responsible Module(s):** Algorithm Module, Localization Module
* **Team Member(s):** Tanay, Arnab
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Depends on the accuracy of the floor calibration to provide exact distances.

## FR-6 — Complete Offline Operation
* **Purpose:** To ensure the navigation system functions reliably without relying on internet connectivity, which is often patchy in hospital environments.
* **Description:** The entire application, including maps, routing algorithms, and localized text/audio, operates locally on the device.
* **Technical Implementation:** All SVG maps, graph data (nodes, edges), language files, and the pathfinding logic are bundled directly into the application's assets at compile time. No external API calls are made for routing. This architecture guarantees zero latency in path computation and maximum privacy/reliability.
* **Responsible Module(s):** Core Application Architecture
* **Team Member(s):** Entire Team
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Increases the initial application bundle size (APK/IPA).

## FR-7 — Permission-Based Floor Switching
* **Purpose:** To maintain context and ensure the user has physically reached the next floor before updating the map.
* **Description:** When the route involves a floor change, the system pauses navigation and prompts the user to confirm once they have reached the new floor (e.g., via elevator or stairs).
* **Technical Implementation:** The UI detects when the active navigation node transitions from a node on Floor A to a node on Floor B. It triggers a modal dialog prompting the user. Navigation state and map rendering are paused until the user interacts with the prompt, at which point the SVG map for Floor B is loaded and path rendering resumes.
* **Responsible Module(s):** UI Module, Navigation State Manager
* **Team Member(s):** Shwetha
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Requires active user interaction during multi-floor transit.

## FR-8 — Multilingual Text-Based User Interface
* **Purpose:** To make the application accessible to a diverse user base by providing the UI in multiple languages.
* **Description:** All UI elements and step-by-step navigation texts can be switched dynamically to different supported languages.
* **Technical Implementation:** A localization framework is integrated into the application. A dictionary of key-value pairs for different languages (e.g., English, Hindi, Kannada) is maintained in JSON/ARB files. The UI components observe the current locale state and dynamically render the corresponding strings.
* **Responsible Module(s):** Multilingual Module, UI Module
* **Team Member(s):** Arnab, Shwetha
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Requires manual translation and maintenance of language files.

## FR-9 — Multilingual Voice-Based Navigation Guidance
* **Purpose:** To provide hands-free, audio-based navigation instructions in the user's preferred language.
* **Description:** The step-by-step text instructions are converted into voice cues.
* **Technical Implementation:** The application integrates a Text-to-Speech (TTS) engine. When a new navigation instruction is generated, the localized text string is passed to the TTS service, matching the application's active language locale.
* **Responsible Module(s):** Audio Module, Multilingual Module
* **Team Member(s):** Niteesh
* **Current Status:** Fully Implemented
* **Dependencies/Limitations:** Relies on the device's built-in TTS engines and installed language packs to function fully offline.

## Additional Functionalities
* **Graph Plotting Tool:** A custom tool was developed by Chandan to plot graphs overlaying the SVG floor maps, simplifying the process of generating nodes and edges.
* **Blueprint Correction & Calibration:** Extensive ground visits by Chandan and Basavaraj ensured that the digital graph perfectly matched the physical hospital environment, resolving any discrepancies in the original blueprints.

# 4. Future Enhancements

| Enhancement | Purpose | Expected Benefits | Technical Feasibility |
| :--- | :--- | :--- | :--- |
| Pedestrian Dead Reckoning (PDR) | To track user movement in real-time without GPS. | Automatic updates of user location on the map; eliminates the need for manual floor switching confirmation. | Medium. Requires complex integration of smartphone accelerometer and gyroscope data. |
| Bluetooth Beacon Integration | To achieve high-accuracy indoor positioning. | Pinpoint accuracy for user location; automatic rerouting if the user strays from the path. | High. Requires physical installation of beacons in the hospital and hardware maintenance. |
| Wheelchair-Accessible Route Optimization | To provide safe paths for patients with limited mobility. | Ensures routes avoid stairs and prioritize elevators and ramps. | High. Can be implemented by adding a "wheelchair accessible" weight/boolean to edges in the graph. |
| Emergency Route Navigation | To guide users to the nearest exit during emergencies. | Enhances hospital safety protocols. | High. Requires adding a new destination type (exits) and overriding standard routing. |

# 5. Tools and Technologies Used

*Assumption: Based on the file extensions provided (`.dart`), the framework used is assumed to be Flutter. Version numbers are assumed standard stable versions as of the project timeline.*

| Technology / Tool | Purpose | Version Number | Why Used |
| :--- | :--- | :--- | :--- |
| Dart | Primary Programming Language | 3.2.0 | Native language for the Flutter framework, offering strong typing and object-oriented features. |
| Flutter | Mobile UI Framework | 3.16.0 | Allows for cross-platform (Android/iOS) development from a single codebase with high performance. |
| flutter_svg | SVG Rendering Library | 2.0.9 | Required for rendering scalable, high-quality hospital blueprints without pixelation. |
| flutter_tts | Text-to-Speech Library | 3.8.3 | Used to implement offline multilingual voice guidance seamlessly. |
| Visual Studio Code | Integrated Development Environment (IDE) | 1.85.0 | Lightweight, highly customizable IDE with excellent Flutter/Dart support. |
| Git | Version Control System | 2.43.0 | Essential for tracking changes, resolving conflicts, and managing team collaboration. |
| GitHub | Repository Hosting | N/A (Cloud) | Used for source code management, branch workflows, and team coordination. |
| Custom Graph Plotter | Internal Tool for Node Mapping | 1.0.0 | Developed internally to efficiently map Nodes/Edges onto the SVGs accurately. |

# 6. GitHub Repository Details

## Repository Information
* **GitHub Repository Link:** `[Insert GitHub Link Here]`
* **Repository Purpose:** Centralized version control and collaboration platform for the Hospital Indoor Navigation source code, assets, and documentation.
* **Branching Strategy:** 
  * `main`: Contains production-ready, stable code.
  * `develop`: Integration branch for new features.
  * `feature/*`: Dedicated branches for individual tasks (e.g., `feature/a-star-algo`, `feature/svg-rendering`).
* **Contribution Workflow:** Developers create feature branches, commit changes, and open Pull Requests (PRs) to `develop`. PRs require code review and successful local testing before merging.

## Repository Directory Structure (README FORMAT)

```text
project-root/
│── src/
│   ├── components/       # Reusable UI widgets (buttons, dialogs, map overlays)
│   ├── screens/          # Main application views (Home, MapNavigation, Settings)
│   ├── algorithms/       # Core pathfinding logic (A* implementation)
│   ├── multilingual/     # Localization files (JSON/ARB) and language switching logic
│   ├── models/           # Data structures (node.dart, edge.dart, floor.dart, floor_config.dart)
│   ├── assets/           # Static files (SVG floor maps, icon images, offline data)
│── tools/                # Custom graph plotting tool scripts
│── docs/                 # Project documentation and architectural diagrams
│── pubspec.yaml          # Flutter dependency manager and project configuration
│── README.md             # Developer onboarding and setup instructions
```

* **`src/models/`**: The backbone of the application data state. Contains `node.dart` and `edge.dart` which define the mathematical graph, and `floor.dart` / `floor_config.dart` which manage floor interconnectivity and scaling.
* **`src/algorithms/`**: Contains the pure Dart implementation of the A* algorithm. Isolated from UI for testability.
* **`src/assets/`**: Houses all hospital blueprints in SVG format to ensure high-fidelity zooming. Must be pre-loaded for offline functionality.
* **`tools/`**: Contains the proprietary scripts developed internally (by Chandan) to assist in plotting the SVG graphs.
* **`pubspec.yaml`**: Defines all external dependencies (like `flutter_svg`, `flutter_tts`) and asset declarations required by the build system.
