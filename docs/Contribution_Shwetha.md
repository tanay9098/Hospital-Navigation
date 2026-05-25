# 1. Personal Information
* **Name:** Shwetha
* **SRN:** [To Be Filled]
* **Role:** Frontend Developer
* **Assigned Responsibilities:** UI (User Interface) of the application.

# 2. Contribution Overview
Shwetha spearheaded the frontend development, transforming the complex underlying logic of pathfinding and map rendering into an intuitive, accessible, and user-friendly mobile interface. Her work ensured that hospital visitors, often under stress, could interact with the application effortlessly.

# 3. Detailed Work Performed
* **Task 1: Screen Design & Implementation:** Developed all major UI screens, including the Home Screen, Location Selection (Search/Dropdowns), and the primary Map Navigation View.
* **Task 2: Interactive Map Overlay:** Implemented the logic to overlay the routing path (provided by the algorithm) seamlessly onto the SVG maps on the frontend.
* **Task 3: Floor Transition Prompts:** Developed the permission-based UI pop-ups required for FR-7, ensuring smooth user experience during multi-floor transit.
* **Team Collaboration:** Worked closely with Arnab to ensure UI components accommodated varying text lengths for multilingual support, and with Tanay to correctly hook up the visual path rendering to the algorithm's output.

# 4. Technical Contribution
* **Tools Used:** Figma (for design mockups), VS Code, Flutter DevTools (Widget Inspector).
* **Technologies Involved:** Flutter Framework (Widgets, State Management, Animations), Dart.
* **Modules/Files Worked On:** `src/screens/*.dart`, `src/components/*.dart`.
* **Technical Decisions Made:** Utilized Flutter's rich widget ecosystem for responsive design, ensuring the app looked perfect on both small smartphones and large tablets. Implemented smooth animations for path drawing to make the UI feel premium and responsive.

# 5. Methodology Followed
* **Working Process:** Followed a User-Centered Design (UCD) approach. Created wireframes, reviewed them with the team, and iteratively built the Flutter widgets.
* **Problem-Solving Approach:** Broke down the complex navigation screen into smaller, modular components (e.g., search bar component, map viewer component, instruction banner component) to keep the codebase maintainable.

# 6. Challenges Faced
* **Technical Challenges:** Managing the complex state of the application during active navigation (e.g., updating the step-by-step instruction banner in real-time as the user's logical position changed).
* **Practical Limitations:** Ensuring the UI remained fluid (60 FPS) while simultaneously rendering large SVG files and plotting hundreds of path coordinates.

# 7. Solutions Implemented
* Used efficient state management techniques to only rebuild the specific parts of the UI that changed, preventing full-screen re-renders and maintaining high performance.
* Designed modular and reusable UI widgets to keep the codebase DRY (Don't Repeat Yourself).

# 8. Learning Outcomes
* Achieved advanced proficiency in Flutter UI development, responsive layouts, and cross-platform design principles.
* Learned how to effectively manage complex, reactive state in a mobile application.
* Gained experience in accessibility-first design for public utility applications.

# 9. Contribution Impact
Shwetha’s UI development brought the project to life. By providing a clean, responsive, and intuitive interface, she ensured that the highly technical backend systems were wrapped in a package that was actually usable by everyday hospital visitors.
