# 1. Personal Information
* **Name:** Niteesh
* **SRN:** [To Be Filled]
* **Role:** Core Developer
* **Assigned Responsibilities:** Preparation of SVG maps from hospital blueprints; Multi-lingual audio implementation.

# 2. Contribution Overview
Niteesh was instrumental in bridging the gap between raw hospital blueprints and a navigable digital format. He successfully converted architectural blueprints into Scalable Vector Graphics (SVG), ensuring they were lightweight and highly readable for the application. Furthermore, Niteesh architected and implemented the multi-lingual voice navigation system, allowing users to receive audio guidance in their preferred language, enhancing the application's accessibility.

# 3. Detailed Work Performed
* **Task 1: SVG Map Preparation:** Acquired raw hospital blueprints and processed them into clean, scalable SVG formats. Removed unnecessary architectural clutter to ensure the maps were user-friendly.
* **Task 2: Multi-lingual Audio Integration:** Researched and integrated an offline Text-to-Speech (TTS) engine. Mapped localized textual navigation instructions to audio outputs.
* **Team Collaboration:** Worked closely with Chandan (who mapped the graphs onto the SVGs) and Arnab (who provided the localized text strings) to ensure audio cues matched the visual instructions.

# 4. Technical Contribution
* **Tools Used:** SVG editing software (e.g., Inkscape/Adobe Illustrator), Flutter framework, VS Code.
* **Technologies Involved:** Dart, XML (SVG), `flutter_tts` package.
* **Modules/Files Worked On:** `assets/maps/*.svg`, `src/audio/tts_manager.dart`.
* **Technical Decisions Made:** Chosen SVGs over PNG/JPEG to prevent pixelation during deep zooming and to keep the app bundle size small. Decided to use device-native TTS engines to maintain the strict offline operation requirement (FR-6).

# 5. Methodology Followed
* **Working Process:** Iterative refinement of SVG maps based on UI rendering tests. Audio implementation followed an event-driven model where the navigation state manager triggered audio cues upon reaching specific nodes.
* **Problem-Solving Approach:** Broke down the audio implementation into smaller steps: first testing basic English TTS, then integrating language switching, and finally optimizing the timing of audio cues.

# 6. Challenges Faced
* **Technical Challenges:** Dealing with the varying quality and scale of raw hospital blueprints. Synchronizing audio cues so they did not overlap if the user moved quickly between navigation nodes.
* **Practical Limitations:** Ensuring the TTS engine worked fully offline for all intended regional languages.

# 7. Solutions Implemented
* Standardized a specific SVG viewport and scaling factor to ensure consistency across all hospital floors.
* Implemented an audio queueing system in the TTS manager to prevent overlapping voice instructions, ensuring clear and concise guidance.

# 8. Learning Outcomes
* Gained deep understanding of vector graphics optimization for mobile rendering.
* Acquired practical experience with cross-platform native hardware integration (Text-to-Speech APIs).
* Improved cross-team communication skills by aligning asset creation with algorithmic requirements.

# 9. Contribution Impact
Niteesh's SVG preparations provided the foundational visual interface of the entire project. His multi-lingual audio implementation directly satisfied FR-9 and drastically improved the application's accessibility, ensuring users could navigate hands-free without staring at their screens.
