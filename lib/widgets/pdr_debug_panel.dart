import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';

/// A collapsible debug panel for PDR sensor data.
/// Default: minimized icon. Tap to expand full debug readout.
class PdrDebugPanel extends StatefulWidget {
  const PdrDebugPanel({super.key});

  @override
  State<PdrDebugPanel> createState() => _PdrDebugPanelState();
}

class _PdrDebugPanelState extends State<PdrDebugPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PdrProvider>(
      builder: (context, pdrProvider, child) {
        // ── Minimized: icon button ──
        if (!_isExpanded) {
          return GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.bug_report, color: Colors.white70, size: 22),
                  // Active indicator badge
                  if (pdrProvider.isPdrEnabled)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        // ── Expanded: full debug card ──
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.92),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PDR Debug',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = false),
                    child: const Icon(Icons.close, color: Colors.white54, size: 18),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 12),
              // PDR toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable PDR', style: TextStyle(color: Colors.white, fontSize: 12)),
                  SizedBox(
                    height: 28,
                    child: Switch(
                      value: pdrProvider.isPdrEnabled,
                      onChanged: (val) {
                        pdrProvider.togglePdr(val);
                        if (val && pdrProvider.currentPosition == null) {
                          // Use a sensible on-map fallback from the active floor's graph
                          final navProv = Provider.of<NavigationProvider>(context, listen: false);
                          final graph = navProv.graph;
                          final floor = navProv.activeFloor;
                          if (graph != null && graph.nodes.isNotEmpty) {
                            final firstNode = graph.nodes.values.first;
                            pdrProvider.initializeFallbackPosition(
                              firstNode.x, firstNode.y, floor, 0.0,
                            );
                          }
                        }
                      },
                      activeThumbColor: Colors.greenAccent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (pdrProvider.isPdrEnabled) ...[
                _buildRow('Steps:', '${pdrProvider.totalSteps}'),
                _buildRow('Heading:', '${(pdrProvider.currentHeading * 180 / 3.14159).toStringAsFixed(1)}°'),
                _buildRow('Accel Z:', pdrProvider.rawAccelZ.toStringAsFixed(3)),
                _buildRow('Gyro Z:', pdrProvider.rawGyroZ.toStringAsFixed(3)),
                if (pdrProvider.currentPosition != null) ...[
                  const SizedBox(height: 4),
                  _buildRow('X:', pdrProvider.currentPosition!.x.toStringAsFixed(1)),
                  _buildRow('Y:', pdrProvider.currentPosition!.y.toStringAsFixed(1)),
                ],
                if (pdrProvider.hasUserSetOrigin)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '✓ User origin set',
                      style: TextStyle(color: Colors.greenAccent.withOpacity(0.7), fontSize: 10),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
