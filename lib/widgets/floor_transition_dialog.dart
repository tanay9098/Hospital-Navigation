import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/models/floor_config.dart';

class FloorTransitionDialog extends StatelessWidget {
  const FloorTransitionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, SimulationProvider>(
      builder: (context, navProvider, simProvider, child) {
        if (!navProvider.transitionHandler.isTransitionPending ||
            navProvider.transitionHandler.targetFloor == null) {
          return const SizedBox.shrink();
        }

        final targetFloor = navProvider.transitionHandler.targetFloor!;
        final targetFloorName = kFloorConfigs[targetFloor]?.floorName ?? 'Floor $targetFloor';

        final transitionNode = navProvider.transitionHandler.pendingTransitionNode;
        final transitType = transitionNode?.type ?? 'lift';
        
        IconData transitIcon = Icons.elevator;
        String transitName = 'the lift';
        
        if (transitType == 'stairs') {
          transitIcon = Icons.stairs;
          transitName = 'the stairs';
        } else if (transitType == 'ramp') {
          transitIcon = Icons.accessible;
          transitName = 'the ramp';
        }

        return Container(
          color: Colors.black54,
          child: Center(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(transitIcon, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      'Floor Transition',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have reached $transitName. Have you moved to $targetFloorName?',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            navProvider.transitionHandler.cancelTransition();
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('No', style: TextStyle(color: Colors.red)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            navProvider.confirmTransition();
                            // Resume simulation automatically after confirming floor change
                            simProvider.resumeSimulation();
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Yes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
