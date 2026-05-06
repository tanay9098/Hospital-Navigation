import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/widgets/search_sheet.dart';
import 'package:hospital_nav/screens/settings_screen.dart';

class NavigationPanel extends StatefulWidget {
  const NavigationPanel({super.key});

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  bool _isExpanded = false;
  bool _isSimulationMode = true;

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Consumer3<NavigationProvider, SimulationProvider, SettingsProvider>(
      builder: (context, navProvider, simProvider, settingsProvider, child) {
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
                color: Colors.black.withOpacity(0.08),
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
                              color: Colors.blue.withOpacity(0.1),
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
                                      ? '${settingsProvider.transliterateLabel(navProvider.startNode?.label ?? '')} → ${settingsProvider.transliterateLabel(navProvider.destinationNode?.label ?? '')}'
                                      : settingsProvider.translate('search_starting_point'),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: hasRoute ? null : Colors.grey.shade600,
                                  ),
                                ),
                                if (!hasRoute)
                                  Text(
                                    settingsProvider.translate('search_destination'),
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          if (hasRoute)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _formatDistance(navProvider.activeRoute!.totalDistance, settingsProvider),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.settings, color: Colors.grey.shade600),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                            },
                          ),
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
                                      label: navProvider.startNode != null ? settingsProvider.transliterateLabel(navProvider.startNode!.label ?? navProvider.startNode!.id) : settingsProvider.translate('search_starting_point'),
                                      onTap: () => _showSearch(context, true),
                                      showBorder: true,
                                      onClear: navProvider.startNode != null ? () => navProvider.clearStart() : null,
                                    ),
                                    _buildLocationTile(
                                      context,
                                      icon: Icons.location_on,
                                      iconColor: Colors.red,
                                      label: navProvider.destinationNode != null ? settingsProvider.transliterateLabel(navProvider.destinationNode!.label ?? navProvider.destinationNode!.id) : settingsProvider.translate('search_destination'),
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
                              tooltip: settingsProvider.translate('swap_start_destination'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Route Info & Actions
                        if (hasRoute) ...[
                          // Navigation Mode Toggle
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${settingsProvider.translate('mode')}: ',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                SegmentedButton<bool>(
                                  segments: [
                                    ButtonSegment<bool>(
                                      value: true,
                                      icon: const Icon(Icons.directions_walk),
                                      label: Text(settingsProvider.translate('simulate')),
                                    ),
                                    ButtonSegment<bool>(
                                      value: false,
                                      icon: const Icon(Icons.explore),
                                      label: Text(settingsProvider.translate('manual')),
                                    ),
                                  ],
                                  selected: <bool>{_isSimulationMode},
                                  onSelectionChanged: (Set<bool> newSelection) {
                                    setState(() {
                                      _isSimulationMode = newSelection.first;
                                    });
                                  },
                                  style: SegmentedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                _formatDistance(navProvider.activeRoute!.totalDistance, settingsProvider),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '~${_formatWalkTime(navProvider.activeRoute!.totalDistance, settingsProvider)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _formatFloors(navProvider.activeRoute!.floorsVisited.toList(), settingsProvider),
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              if (simProvider.isSimulating)
                                _buildActionButton(
                                  label: settingsProvider.translate('stop'),
                                  icon: Icons.close,
                                  color: Colors.red.shade600,
                                  onPressed: () => simProvider.stopSimulation(),
                                )
                              else
                                _buildActionButton(
                                  label: settingsProvider.translate('start'),
                                  icon: Icons.navigation,
                                  color: theme.colorScheme.primary,
                                  onPressed: () {
                                    final route = navProvider.fullRoute ?? navProvider.activeRoute;
                                    if (route == null) return;
                                    setState(() => _isExpanded = false); // collapse when starting
                                    
                                    if (_isSimulationMode) {
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
                                                    child: Text('${settingsProvider.translate('nav.arrived_at_short')} ${settingsProvider.transliterateLabel(navProvider.destinationNode?.label ?? '')}!'),
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
                                    } else {
                                      // Manual Mode
                                      Provider.of<PdrProvider>(context, listen: false).togglePdr(true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(settingsProvider.translate('manual_nav_started')),
                                          behavior: SnackBarBehavior.floating,
                                        )
                                      );
                                    }
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

  String _formatDistance(double meters, SettingsProvider settingsProvider) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} ${settingsProvider.translate('unit_km')}';
    }
    return '${meters.toStringAsFixed(0)} ${settingsProvider.translate('unit_m')}';
  }

  String _formatWalkTime(double meters, SettingsProvider settingsProvider) {
    final minutes = (meters / 80).ceil(); // ~80m per minute average indoor walking
    if (minutes <= 1) return settingsProvider.translate('min_walk_singular');
    return settingsProvider.translateArgs('min_walk_plural', {'minutes': '$minutes'});
  }

  String _formatFloors(List<int> floors, SettingsProvider settingsProvider) {
    final names = floors.map((f) {
      final config = kFloorConfigs[f];
      return config?.shortName ?? '${settingsProvider.translate('floor_short_prefix')}$f';
    }).join(' → ');
    return '${settingsProvider.translate('via_prefix')}: $names';
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
