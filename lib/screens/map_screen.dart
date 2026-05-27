import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/widgets/map_view.dart';
import 'package:hospital_nav/widgets/navigation_panel.dart';
import 'package:hospital_nav/widgets/directions_panel.dart';
import 'package:hospital_nav/widgets/floor_transition_dialog.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';
import 'package:hospital_nav/widgets/compass_widget.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // GlobalKey to access the FloorMapViewState for resetView()
  static final GlobalKey<FloorMapViewState> _mapKey = GlobalKey<FloorMapViewState>();

  @override
  Widget build(BuildContext context) {
    return Consumer3<NavigationProvider, SimulationProvider, PdrProvider>(
      builder: (context, navProvider, simProvider, pdrProvider, child) {
        final canPop = navProvider.activeRoute == null && !simProvider.isSimulating && !pdrProvider.isPdrEnabled;
        
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            
            if (simProvider.isSimulating) {
              simProvider.stopSimulation();
            } else if (pdrProvider.isPdrEnabled) {
              pdrProvider.togglePdr(false);
            } else if (navProvider.activeRoute != null) {
              navProvider.clearRoute();
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                
                if (isDesktop) {
                  return _buildDesktopLayout(context);
                } else {
                  return _buildMobileLayout(context);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // ═══ Left Side Panel (Controls) ═══
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Navigation Panel (Search & Route Info)
                const NavigationPanel(),
                const SizedBox(height: 16),
                
                // Directions Panel (Turn-by-turn)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: DirectionsPanel(),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),

        // ═══ Right Side (Map & FABs) ═══
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: FloorMapView(key: _mapKey),
              ),
              _buildRightControls(context),
              const Positioned.fill(
                child: FloorTransitionDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        // ═══ Layer 1: Map (base) + Path Overlay ═══
        Positioned.fill(
          child: FloorMapView(key: _mapKey),
        ),

        // ═══ Layer 2: Panels & Controls ═══
        SafeArea(
          child: Consumer2<SimulationProvider, PdrProvider>(
            builder: (context, simProvider, pdrProvider, child) {
              final isNavigating = simProvider.isSimulating || pdrProvider.isPdrEnabled;

              return Stack(
                children: [
                  // Top Panel (Route Planning) - Hide if navigating
                  if (!isNavigating)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: NavigationPanel(),
                    ),

                  // Bottom Panel (Active Navigation Directions)
                  if (isNavigating)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: const DirectionsPanel(),
                        ),
                      ),
                    ),

                  // Map Controls (Right Side)
                  Consumer<NavigationProvider>(
                    builder: (context, navProvider, child) {
                      final hasRoute = navProvider.activeRoute != null;
                      return Positioned(
                        bottom: isNavigating ? 140 : 32, // Move FABs up if panel is showing
                        right: 16,
                        child: _buildRightControls(context, hasRoute),
                      );
                    },
                  ),

                ],
              );
            },
          ),
        ),

        // ═══ Layer 3: Transition Dialog ═══
        const Positioned.fill(
          child: FloorTransitionDialog(),
        ),
      ],
    );
  }

  Widget _buildRightControls(BuildContext context, [bool hasRoute = false]) {
    final theme = Theme.of(context);
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      right: 16,
      bottom: hasRoute ? 240 : 16, // Move up if directions panel is active
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildGlassPill(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: CompassWidget(),
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassPill(
            child: IconButton(
              tooltip: 'Reset map view',
              onPressed: () {
                final state = _mapKey.currentState;
                if (state != null) {
                  final renderBox = state.context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final size = renderBox.size;
                    state.resetView(BoxConstraints.tight(size));
                  }
                }
              },
              icon: Icon(Icons.my_location, size: 22, color: theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassPill(
            child: Consumer<NavigationProvider>(
              builder: (context, navProvider, child) {
                final floorKeys = kFloorConfigs.keys.toList()..sort((a, b) => b.compareTo(a));
                final List<Widget> children = [];
                for (int i = 0; i < floorKeys.length; i++) {
                  final floorIndex = floorKeys[i];
                  final floorConfig = kFloorConfigs[floorIndex]!;
                  final isTop = i == 0;
                  final isBottom = i == floorKeys.length - 1;
                  
                  children.add(
                    _buildFloorButton(
                      context,
                      label: floorConfig.shortName,
                      isActive: navProvider.activeFloor == floorIndex,
                      onPressed: () => navProvider.setFloor(floorIndex),
                      isTop: isTop,
                      isBottom: isBottom,
                    ),
                  );
                }
                
                return Container(
                  height: 140, // Shows ~3 floors
                  width: 52, // Enough for the 44px button + some padding
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPill({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFloorButton(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    required bool isTop,
    required bool isBottom,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(isTop ? 24 : 0),
        bottom: Radius.circular(isBottom ? 24 : 0),
      ),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
