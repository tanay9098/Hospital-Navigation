import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';
import 'package:hospital_nav/services/direction_generator.dart';
import 'package:hospital_nav/models/route_result.dart';

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
  RouteResult? _cachedRoute;
  List<NavigationInstruction> _cachedSteps = [];
  bool _wasSimulating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer3<NavigationProvider, SimulationProvider, SettingsProvider>(
      builder: (context, navProvider, simProvider, settingsProvider, child) {
        final isSimulating = simProvider.isSimulating;
        if (isSimulating && !_wasSimulating) {
          _isExpanded = true;
        } else if (!isSimulating && _wasSimulating) {
          _isExpanded = false;
        }
        _wasSimulating = isSimulating;

        // Use the simulation's own stored route for stable step tracking,
        // falling back to the nav provider's route when not simulating.
        final route = simProvider.currentRoute ?? navProvider.activeRoute;
        if (route == null) {
          return const SizedBox.shrink();
        }

        final lang = settingsProvider.selectedLanguageCode.isEmpty
            ? 'en'
            : settingsProvider.selectedLanguageCode;

        // Generate localized steps once per route to avoid UI shaking
        if (_cachedRoute != route) {
          _cachedRoute = route;
          if (route.analysis != null) {
            final generator = DirectionGenerator(settingsProvider.instructionFormatter);
            _cachedSteps = generator.generate(
              path: route.path,
              analysis: route.analysis!,
            );
          } else {
            _cachedSteps = route.steps;
          }
        }
        
        final steps = _cachedSteps;
        
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Floating Transit Preference Pill ──
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTransitOption(context, navProvider, settingsProvider, 'lift', Icons.elevator),
                    _buildTransitOption(context, navProvider, settingsProvider, 'stairs', Icons.stairs),
                    _buildTransitOption(context, navProvider, settingsProvider, 'ramp', Icons.accessible),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Main Glassmorphic Panel ──
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Expanded: scrollable upcoming steps ──
                      if (_isExpanded)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: steps.length,
                            separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                            itemBuilder: (context, index) {
                              final step = steps[index];
                              final isPast = index < activeStepIndex;
                              final isActive = index == activeStepIndex;
                              
                              return InkWell(
                                onTap: () {
                                  simProvider.jumpToInstruction(step.pathIndex);
                                  settingsProvider.speak(step.textForLang(lang));
                                },
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _stepColor(step.maneuver, isActive).withOpacity(isActive ? 0.3 : 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(step.icon, size: 20, color: _stepColor(step.maneuver, isActive)),
                                  ),
                                  title: Text(
                                    step.textForLang(lang),
                                    style: TextStyle(
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                        color: isPast ? Colors.grey.shade400 : Colors.black87,
                                    ),
                                  ),
                                  trailing: isActive ? const Icon(Icons.my_location, color: Colors.blue, size: 16) : null,
                                  dense: true,
                                ),
                              );
                            },
                          ),
                        ),

                      // ── Active Step Header (with controls) ──
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                          ),
                          child: Row(
                            children: [
                              Icon(currentStep.icon, color: Colors.white, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentStep.textForLang(lang),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                              // Controls inline
                              if (simProvider.isSimulating)
                                IconButton(
                                  icon: Icon(simProvider.isAutoMode ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.white, size: 28),
                                  onPressed: () => simProvider.toggleAutoMode(),
                                ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                                onPressed: () {
                                   simProvider.stopSimulation();
                                   Provider.of<PdrProvider>(context, listen: false).togglePdr(false);
                                   Provider.of<NavigationProvider>(context, listen: false).clearRoute();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransitOption(BuildContext context, NavigationProvider navProvider, SettingsProvider settingsProvider, String value, IconData icon) {
    final isSelected = navProvider.transitPreference == value;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        final simProvider = Provider.of<SimulationProvider>(context, listen: false);
        final wasSimulating = simProvider.isSimulating;

        // If the simulation is running, stop it before changing the route.
        if (wasSimulating) {
          simProvider.stopSimulation();
        }

        navProvider.setTransitPreference(value);

        // If the simulation was running, restart it with the new route
        // after the async route recalculation completes.
        // _calculateRoute uses Future.microtask, so we schedule after it.
        if (wasSimulating) {
          Future.microtask(() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final newRoute = navProvider.fullRoute ?? navProvider.activeRoute;
              if (newRoute != null) {
                simProvider.startSimulation(
                  newRoute,
                  onNodeReached: (node) {
                    if (navProvider.checkTransition(node)) {
                      simProvider.pauseSimulation();
                    }
                  },
                  onFloorChanged: (floor) => navProvider.setFloor(floor),
                );
              }
            });
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                settingsProvider.translate(value == 'stairs' ? 'stairs_only' : value),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
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
