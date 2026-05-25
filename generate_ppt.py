import collections
import collections.abc
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor

def create_presentation():
    prs = Presentation()
    
    # Choose a simple theme by modifying master background if needed, but default is fine.
    # We will use built-in layouts.
    # 0: Title, 1: Title and Content, 2: Section Header, 3: Two Content
    
    # TITLE SLIDE
    title_slide_layout = prs.slide_layouts[0]
    slide = prs.slides.add_slide(title_slide_layout)
    title = slide.shapes.title
    subtitle = slide.placeholders[1]
    
    title.text = "Hospital Indoor Navigation System"
    subtitle.text = "Project Presentation\n\nTeam Members:\nNiteesh, Tanay, Chandan, Basavaraj, Shwetha, Arnab\n\nDepartment of Computer Science & Engineering"
    
    # Format subtitle
    for paragraph in subtitle.text_frame.paragraphs:
        paragraph.font.size = Pt(20)

    def add_content_slide(title_text, bullets):
        slide_layout = prs.slide_layouts[1]
        slide = prs.slides.add_slide(slide_layout)
        title = slide.shapes.title
        title.text = title_text
        
        content = slide.placeholders[1]
        tf = content.text_frame
        tf.clear()
        
        for bullet in bullets:
            p = tf.add_paragraph()
            p.text = bullet
            p.level = 0
            # Optional formatting for sub-bullets based on indentation
            if bullet.startswith("  -"):
                p.level = 1
                p.text = bullet.strip()[2:].strip()

    # ABSTRACT
    add_content_slide("Abstract", [
        "Problem Statement: Patients and visitors struggle to navigate complex hospital environments; GPS fails indoors.",
        "Objectives: Create an offline, accurate indoor navigation app providing turn-by-turn routing across floors.",
        "Proposed Solution: A Flutter-based mobile app utilizing custom SVG maps, A* pathfinding, and multi-lingual voice guidance.",
        "Expected Outcomes: Improved patient experience, reduced staff interruptions, and reliable indoor localization without internet dependency."
    ])

    # INTRODUCTION
    add_content_slide("Introduction", [
        "Background & Motivation:",
        "  - Large hospitals often feel like mazes.",
        "  - Existing outdoor maps (e.g., Google Maps) are ineffective indoors.",
        "Problem Addressed:",
        "  - Lack of reliable indoor mapping and turn-by-turn routing for pedestrians.",
        "Significance & Purpose:",
        "  - Enhances accessibility for all demographics.",
        "  - Saves valuable time during critical medical visits.",
        "  - Provides an extensible platform for future hospital management features."
    ])

    # TOOLS AND TECHNOLOGIES USED
    add_content_slide("Tools and Technologies Used", [
        "Flutter (v3.16.0): Mobile UI Framework for cross-platform apps.",
        "Dart (v3.2.0): Core programming language for business logic.",
        "flutter_svg (v2.0.9): For rendering high-quality vector hospital blueprints.",
        "flutter_tts (v3.8.3): Enables offline multilingual voice navigation.",
        "Custom Graph Plotter: Internal tool used for mapping Nodes/Edges onto SVGs.",
        "Git & GitHub: Version control and collaboration.",
        "Visual Studio Code: Integrated Development Environment (IDE)."
    ])

    # SYSTEM ARCHITECTURE / WORKFLOW
    add_content_slide("System Architecture & Workflow", [
        "1. Map Digitization: Converting blueprints to SVG and plotting the mathematical graph.",
        "2. Input Selection: User selects Source and Destination nodes manually or via search.",
        "3. Path Computation: A* Algorithm computes the shortest path.",
        "  - Handles 3D space (multi-floor transitions via virtual edges).",
        "4. Instruction Generation: Path geometry is analyzed to generate text/audio directions.",
        "5. Visual Overlay: The computed path is mapped back onto SVG coordinates.",
        "6. UI Update: The screen updates dynamically as the user progresses."
    ])

    # FEATURES IMPLEMENTED
    add_content_slide("Features Implemented", [
        "Manual Source & Destination Selection: Interactive search and selection.",
        "Shortest Path Computation: Utilizes the A* algorithm with Euclidean heuristics.",
        "Multi-Floor Navigation: Seamless routing through stairs and elevators.",
        "Visual Route Display: High-fidelity path drawing over interactive SVG maps.",
        "Step-by-Step Instructions: Textual turn-by-turn guidance based on path geometry.",
        "Complete Offline Operation: All maps and routing algorithms bundled locally.",
        "Multilingual Support: Text and Voice (English, Hindi, Kannada, Tamil, Telugu).",
        "Permission-Based Floor Switching: Manual acknowledgment during floor transitions."
    ])

    # METHODOLOGY / WORKING PROCESS
    add_content_slide("Methodology & Working Process", [
        "Ground Validation:",
        "  - Physical hospital visits to ensure digital graph matches reality.",
        "  - Blueprint correction and calibration of map coordinates.",
        "Algorithm Design:",
        "  - A* search using Euclidean distance for optimal offline performance.",
        "Natural Language Generation (NLG):",
        "  - Translating vector edge angles into 'left', 'right', and 'straight' instructions.",
        "Localization Integration:",
        "  - Mapping UI strings and navigation cues across 5 languages."
    ])

    # CHALLENGES FACED & SOLUTIONS
    add_content_slide("Challenges Faced & Solutions", [
        "Challenge: Accurate scaling and calibration of floor blueprints.",
        "  - Solution: Developed a custom internal plotting tool and conducted extensive physical testing.",
        "Challenge: Providing indoor positioning without GPS or internet.",
        "  - Solution: Engineered a 100% offline architecture with all assets bundled into the app.",
        "Challenge: Handling multi-floor navigation seamlessly.",
        "  - Solution: Introduced virtual vertical edges and manual floor switch confirmation prompts to maintain context."
    ])

    # FUTURE ENHANCEMENTS
    add_content_slide("Future Enhancements", [
        "Pedestrian Dead Reckoning (PDR): Track user movement using smartphone sensors (accelerometer/gyro) for automatic location updates.",
        "Bluetooth Beacon Integration: Deploy hardware for high-accuracy, pinpoint indoor positioning and automatic rerouting.",
        "Wheelchair-Accessible Routes: Add edge weights to optimize paths avoiding stairs and prioritizing elevators.",
        "Emergency Evacuation Routing: Dynamic routing to guide users to the nearest exit during emergencies."
    ])

    # CONCLUSION
    add_content_slide("Conclusion", [
        "Project Outcomes:",
        "  - Successfully delivered a functional, accurate, and fully offline indoor navigation prototype.",
        "Impact:",
        "  - Solves a critical, real-world problem for hospital visitors and reduces staff burden.",
        "Key Achievements:",
        "  - Implementation of a complex 3D A* graph.",
        "  - Seamless multilingual voice guidance without API dependencies.",
        "  - High-fidelity visual mapping using SVGs."
    ])
    
    # Save presentation
    prs.save("Hospital_Indoor_Navigation_Presentation.pptx")
    print("Presentation saved successfully as 'Hospital_Indoor_Navigation_Presentation.pptx'")

if __name__ == "__main__":
    create_presentation()
