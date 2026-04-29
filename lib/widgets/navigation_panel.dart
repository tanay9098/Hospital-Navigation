import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/widgets/search_sheet.dart';

class NavigationPanel extends StatefulWidget {
  const NavigationPanel({super.key});

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  bool _isExpanded = false;

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Consumer2<NavigationProvider, SimulationProvider>(
      builder: (context, navProvider, simProvider, child) {
        final hasRoute = navProvider.activeRoute != null;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(
            maxHeight: _isExpanded ? screenHeight * 0.45 : 120, // Taller to account for safe area
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4), // Shadow downwards
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Safe Area Padding
                SizedBox(height: MediaQuery.of(context).padding.top),

                // Loading Indicator
                if (navProvider.isCalculatingRoute)
                  const LinearProgressIndicator(minHeight: 2),
                
                // ── Collapsed: summary row (TAPPABLE) ──
                if (!_isExpanded)
                  GestureDetector(
                    onTap: _togglePanel,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search, color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasRoute
                                      ? '${navProvider.startNode?.name} → ${navProvider.destinationNode?.name}'
                                      : navProvider.startNode?.name ?? 'Where do you want to go?',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: hasRoute ? null : Colors.grey.shade600,
                                  ),
                                ),
                                if (!hasRoute)
                                  Text(
                                    'Tap to search rooms & departments',
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          if (hasRoute)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _formatDistance(navProvider.activeRoute!.totalDistance),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 24),
                        ],
                      ),
                    ),
                  ),

                // ── Expanded: full controls ──
                if (_isExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search Inputs Group with Swap Button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey.shade50,
                                ),
                                child: Column(
                                  children: [
                                    _buildLocationTile(
                                      context,
                                      icon: Icons.my_location,
                                      iconColor: Colors.blue,
                                      label: navProvider.startNode?.name ?? 'Choose Starting Point',
                                      onTap: () => _showSearch(context, true),
                                      showBorder: true,
                                      onClear: navProvider.startNode != null ? () => navProvider.clearStart() : null,
                                    ),
                                    _buildLocationTile(
                                      context,
                                      icon: Icons.location_on,
                                      iconColor: Colors.red,
                                      label: navProvider.destinationNode?.name ?? 'Choose Destination',
                                      onTap: () => _showSearch(context, false),
                                      showBorder: false,
                                      onClear: navProvider.destinationNode != null ? () => navProvider.clearDestination() : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Swap button
                            IconButton(
                              onPressed: (navProvider.startNode != null || navProvider.destinationNode != null)
                                  ? () => navProvider.swapNodes()
                                  : null,
                              icon: const Icon(Icons.swap_vert, size: 22),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                                shape: const CircleBorder(),
                                minimumSize: const Size(42, 42),
                              ),
                              tooltip: 'Swap start & destination',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Route Info & Actions
                        if (hasRoute) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _formatDistance(navProvider.activeRoute!.totalDistance),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '~${_formatWalkTime(navProvider.activeRoute!.totalDistance)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _formatFloors(navProvider.activeRoute!.floorsVisited.toList()),
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              if (simProvider.isSimulating)
                                _buildActionButton(
                                  label: 'Stop',
                                  icon: Icons.close,
                                  color: Colors.red.shade600,
                                  onPressed: () => simProvider.stopSimulation(),
                                )
                              else
                                _buildActionButton(
                                  label: 'Start',
                                  icon: Icons.navigation,
                                  color: theme.colorScheme.primary,
                                  onPressed: () {
                                    final route = navProvider.fullRoute ?? navProvider.activeRoute;
                                    if (route == null) return;
                                    setState(() => _isExpanded = false); // collapse when starting
                                    simProvider.startSimulation(
                                      route,
                                      onNodeReached: (node) {
                                        if (navProvider.checkTransition(node)) {
                                          simProvider.pauseSimulation();
                                        }
                                      },
                                      onFloorChanged: (floor) => navProvider.setFloor(floor),
                                      onArrived: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.check_circle, color: Colors.white),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text('You have arrived at ${navProvider.destinationNode?.name}!'),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.green.shade600,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            duration: const Duration(seconds: 4),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                // ── Drag handle at the bottom ──
                GestureDetector(
                  onTap: _togglePanel,
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null) {
                      setState(() {
                        _isExpanded = details.primaryVelocity! > 0; // swipe down = expand
                      });
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    required bool showBorder,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showBorder ? Border(bottom: BorderSide(color: Colors.grey.shade200)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatWalkTime(double meters) {
    final minutes = (meters / 80).ceil(); // ~80m per minute average indoor walking
    if (minutes <= 1) return '1 min walk';
    return '$minutes min walk';
  }

  String _formatFloors(List<int> floors) {
    final names = floors.map((f) {
      final config = kFloorConfigs[f];
      return config?.shortName ?? 'F$f';
    }).join(' → ');
    return 'Via: $names';
  }

  void _showSearch(BuildContext context, bool isStart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SearchSheet(isStart: isStart),
    ).then((_) {
      // Keep panel expanded after selection so user can pick the other field
      if (mounted) {
        setState(() => _isExpanded = true);
      }
    });
  }
}
