import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/services/direction_generator.dart';

/// A collapsible panel that shows step-by-step navigation directions.
/// Only visible when an active route exists.
class DirectionsPanel extends StatefulWidget {
  const DirectionsPanel({super.key});

  @override
  State<DirectionsPanel> createState() => _DirectionsPanelState();
}

class _DirectionsPanelState extends State<DirectionsPanel> {
  bool _isExpanded = false;
  int _lastSpokenStepIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer3<NavigationProvider, SimulationProvider, SettingsProvider>(
      builder: (context, navProvider, simProvider, settingsProvider, child) {
        // Use the simulation's own stored route for stable step tracking,
        // falling back to the nav provider's route when not simulating.
        final route = simProvider.currentRoute ?? navProvider.activeRoute;
        if (route == null) {
          return const SizedBox.shrink();
        }

        final lang = settingsProvider.selectedLanguageCode.isEmpty
            ? 'en'
            : settingsProvider.selectedLanguageCode;

        // Generate localized steps on-the-fly from stored PathAnalysis
        List<NavigationInstruction> steps;
        if (route.analysis != null) {
          final generator = DirectionGenerator(settingsProvider.instructionFormatter);
          steps = generator.generate(
            path: route.path,
            analysis: route.analysis!,
          );
        } else {
          steps = route.steps;
        }
        
        if (steps.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Dynamically compute active step based on simulation index
        int activeStepIndex = 0;
        final currentSimIndex = simProvider.currentStepIndex;
        for (int i = 0; i < steps.length; i++) {
          if (steps[i].pathIndex <= currentSimIndex) {
            activeStepIndex = i;
          } else {
            break;
          }
        }
        
        final currentStep = steps[activeStepIndex];

        // TTS: speak the localized instruction text
        if (simProvider.isSimulating && _lastSpokenStepIndex != activeStepIndex) {
          _lastSpokenStepIndex = activeStepIndex;
          settingsProvider.speak(currentStep.textForLang(lang));
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, -8), // Shadow upwards
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Expanded: scrollable upcoming steps (ABOVE HEADER) ──
              if (_isExpanded)
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: steps.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      final isPast = index < activeStepIndex;
                      final isActive = index == activeStepIndex;
                      
                      return InkWell(
                        onTap: () {
                          // Jump to this instruction and speak it
                          simProvider.jumpToInstruction(step.pathIndex);
                          settingsProvider.speak(step.textForLang(lang));
                        },
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _stepColor(step.maneuver, isActive).withOpacity(isActive ? 0.3 : 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(step.icon, size: 20, color: _stepColor(step.maneuver, isActive)),
                          ),
                          title: Text(
                            step.textForLang(lang),
                            style: TextStyle(
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: isPast ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: isActive ? const Icon(Icons.my_location, color: Colors.blue, size: 16) : null,
                          dense: true,
                        ),
                      );
                    },
                  ),
                ),

              // ── Quick Toggles ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Transit Preference Row
                    Row(
                      children: [
                        Text(
                          settingsProvider.translate('preference_label'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment<String>(
                                value: 'lift',
                                icon: Icon(Icons.elevator, size: 16),
                                label: Text(settingsProvider.translate('lift'), style: const TextStyle(fontSize: 13)),
                              ),
                              ButtonSegment<String>(
                                value: 'stairs',
                                icon: Icon(Icons.stairs, size: 16),
                                label: Text(settingsProvider.translate('stairs_only'), style: const TextStyle(fontSize: 13)),
                              ),
                              ButtonSegment<String>(
                                value: 'ramp',
                                icon: Icon(Icons.accessible, size: 16),
                                label: Text(settingsProvider.translate('ramp'), style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                            selected: {navProvider.transitPreference},
                            showSelectedIcon: false,
                            onSelectionChanged: (Set<String> newSelection) {
                              navProvider.setTransitPreference(newSelection.first);
                            },
                            style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              selectedBackgroundColor: Colors.blue.shade100,
                              selectedForegroundColor: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Stop Navigation Button
                        IconButton(
                          onPressed: () => simProvider.stopSimulation(),
                          icon: const Icon(Icons.close, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(44, 44),
                          ),
                          tooltip: settingsProvider.translate('stop_navigation'),
                        ),
                        const SizedBox(width: 12),
                        // Auto/Manual Toggle
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => simProvider.toggleAutoMode(),
                            icon: Icon(simProvider.isAutoMode ? Icons.pause : Icons.play_arrow, size: 18),
                            label: Text(
                              simProvider.isAutoMode
                                  ? settingsProvider.translate('pause_simulation')
                                  : settingsProvider.translate('resume_simulation'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: simProvider.isAutoMode ? Colors.green.shade600 : Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Active Step Prominent Header (BOTTOM) ──
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.primary,
                  child: Row(
                    children: [
                      Icon(currentStep.icon, color: Colors.white, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          currentStep.textForLang(lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _stepColor(ManeuverType maneuver, bool isActive) {
    if (isActive) return Colors.green;

    switch (maneuver) {
      case ManeuverType.start:
        return Colors.green;
      case ManeuverType.arrive:
        return Colors.red;
      case ManeuverType.left:
      case ManeuverType.slightLeft:
      case ManeuverType.right:
      case ManeuverType.slightRight:
      case ManeuverType.floorChange:
        return Colors.orange;
      case ManeuverType.straight:
        return Colors.blue;
    }
  }
}
