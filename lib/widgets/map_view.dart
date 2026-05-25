import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/widgets/path_overlay.dart';

class FloorMapView extends StatefulWidget {
  final VoidCallback? onResetView;

  const FloorMapView({super.key, this.onResetView});

  @override
  State<FloorMapView> createState() => FloorMapViewState();
}

class FloorMapViewState extends State<FloorMapView> {
  final TransformationController _transformController = TransformationController();
  double _fitScale = 1.0;
  bool _initialized = false;
  bool _isTrackingUser = true;
  bool _pendingCenter = false; // Guard against redundant post-frame callbacks

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Resets the map view to fit the full SVG inside the viewport, centered.
  void resetView(BoxConstraints constraints) {
    if (!mounted) return;
    _isTrackingUser = true; // Re-enable tracking on reset/re-center
    
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final floorConfig = kFloorConfigs[navProvider.activeFloor] ?? kFloorConfigs[0]!;
    final mapWidth = floorConfig.baseMapWidth;
    final mapHeight = floorConfig.baseMapHeight;
    
    if (mapWidth == 0 || mapHeight == 0) return;
    
    final scaleX = constraints.maxWidth / mapWidth;
    final scaleY = constraints.maxHeight / mapHeight;
    _fitScale = min(scaleX, scaleY);

    final scaledWidth = mapWidth * _fitScale;
    final scaledHeight = mapHeight * _fitScale;
    final tx = (constraints.maxWidth - scaledWidth) / 2;
    final ty = (constraints.maxHeight - scaledHeight) / 2;

    final matrix = Matrix4.diagonal3Values(_fitScale, _fitScale, 1.0);
    matrix.setEntry(0, 3, tx);
    matrix.setEntry(1, 3, ty);
    _transformController.value = matrix;
  }

  void centerOnPosition(Offset pos, BoxConstraints constraints) {
    if (!mounted) return;
    final matrix = _transformController.value;
    double currentScale = matrix.getMaxScaleOnAxis();

    // Determine an appropriate zoom level when following the user.
    // Ensure it's comfortably zoomed in relative to the fitScale.
    final double followScale = max(currentScale, _fitScale >= 1.0 ? 1.5 : _fitScale * 3.0);

    double tx = (constraints.maxWidth / 2) - (pos.dx * followScale);
    double ty = (constraints.maxHeight / 2) - (pos.dy * followScale);

    final newMatrix = Matrix4.diagonal3Values(followScale, followScale, 1.0);
    newMatrix.setEntry(0, 3, tx);
    newMatrix.setEntry(1, 3, ty);

    _transformController.value = newMatrix;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        final floorConfig = kFloorConfigs[navProvider.activeFloor] ?? kFloorConfigs[0]!;
        final mapAsset = floorConfig.mapAsset;
        final baseMapWidth = floorConfig.baseMapWidth;
        final baseMapHeight = floorConfig.baseMapHeight;
        final mapDrawScale = floorConfig.mapDrawScale;
        
        final currentMapWidth = baseMapWidth * mapDrawScale;
        final currentMapHeight = baseMapHeight * mapDrawScale;

        List<Offset> routePoints = [];
        List<Offset> turnPoints = [];
        if (navProvider.activeRoute != null) {
          final route = navProvider.activeRoute!;
          
          // Only draw the route if it actually belongs to the currently viewed floor.
          if (route.path.isNotEmpty && route.path.first.floor == navProvider.activeFloor) {
            for (var node in route.path) {
              routePoints.add(Offset(node.x * mapDrawScale, node.y * mapDrawScale));
            }

            for (final turnPathIndex in route.turnPointIndices) {
              if (turnPathIndex < 0 || turnPathIndex >= route.path.length) continue;
              final turnNode = route.path[turnPathIndex];
              turnPoints.add(Offset(turnNode.x * mapDrawScale, turnNode.y * mapDrawScale));
            }
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate fit-to-screen on first layout pass
            if (!_initialized) {
              _initialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                resetView(constraints);
                setState(() {});
              });
            }

            return InteractiveViewer(
              transformationController: _transformController,
              onInteractionStart: (details) {
                // If user pans or zooms manually, stop tracking so they can navigate the map freely.
                setState(() {
                  _isTrackingUser = false;
                });
              },
              minScale: 0.05,
              maxScale: 6.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: SizedBox(
                width: currentMapWidth,
                height: currentMapHeight,
                child: Stack(
                  children: [
                    ColoredBox(
                      color: Colors.white,
                      child: SvgPicture.asset(
                        mapAsset,
                        width: currentMapWidth,
                        height: currentMapHeight,
                        fit: BoxFit.fill,
                        placeholderBuilder: (BuildContext context) => Container(
                          width: currentMapWidth,
                          height: currentMapHeight,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('Loading Map...', style: TextStyle(fontSize: 100, color: Colors.black54)),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: POIOverlay(
                        nodes: navProvider.floorManager.activeGraph?.nodes.values.toList() ?? [],
                        mapDrawScale: mapDrawScale,
                      ),
                    ),
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: Consumer2<SimulationProvider, PdrProvider>(
                          builder: (context, simProvider, pdrProvider, _) {
                            Offset? currentSimPos;
                            double mapHeading = 0.0;

                            if (pdrProvider.isPdrEnabled && pdrProvider.currentPosition != null) {
                              final snappedPos = navProvider.processPdrUpdate(pdrProvider.currentPosition!);
                              if (snappedPos.floor == navProvider.activeFloor) {
                                currentSimPos = Offset(snappedPos.x * mapDrawScale, snappedPos.y * mapDrawScale);
                                mapHeading = snappedPos.heading;
                              }
                            } else if (simProvider.isSimulating && simProvider.currentFloor == navProvider.activeFloor) {
                              currentSimPos = Offset(simProvider.currentX * mapDrawScale, simProvider.currentY * mapDrawScale);
                              mapHeading = simProvider.currentHeading;
                            }

                            if (currentSimPos != null && _isTrackingUser && !_pendingCenter) {
                              _pendingCenter = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _pendingCenter = false;
                                if (mounted && _isTrackingUser) {
                                  centerOnPosition(currentSimPos!, constraints);
                                }
                              });
                            }

                            return CustomPaint(
                              size: Size(currentMapWidth, currentMapHeight),
                              painter: PathOverlay(
                                points: routePoints,
                                turnPoints: turnPoints,
                                isSimulating: simProvider.isSimulating || (pdrProvider.isPdrEnabled && currentSimPos != null),
                                currentPosition: currentSimPos,
                                heading: mapHeading,
                                scale: mapDrawScale,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class POIOverlay extends StatelessWidget {
  final List<dynamic> nodes;
  final double mapDrawScale;

  const POIOverlay({
    super.key,
    required this.nodes,
    required this.mapDrawScale,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: POIPainter(
                  nodes: nodes,
                  scale: mapDrawScale,
                ),
              ),
            ),
            // Only render labels for nodes that have a label (rooms, lifts, stairs, ramps)
            ...nodes.where((n) => n.label != null && n.label.toString().isNotEmpty).map((node) {
              final translatedName = settingsProvider.transliterateLabel(node.label.toString());
              
              return Positioned(
                left: (node.x * mapDrawScale) - 50,
                top: (node.y * mapDrawScale) + 14, // below the icon
                width: 100, // Fixed width for centering
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      translatedName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class POIPainter extends CustomPainter {
  final List<dynamic> nodes;
  final double scale;

  POIPainter({required this.nodes, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    try {
      for (var node in nodes) {
        IconData? icon;
        Color color = Colors.grey.shade600;

        final type = node.type.toString().toLowerCase();
        final label = (node.label ?? '').toString().toLowerCase();

        if (type == 'lift') {
          icon = Icons.elevator;
          color = Colors.blue.shade600;
        } else if (type == 'stairs') {
          icon = Icons.stairs;
          color = Colors.orange.shade600;
        } else if (type == 'ramp') {
          icon = Icons.accessible;
          color = Colors.green.shade600;
        } else if (label.contains('toilet_female')) {
          icon = Icons.female;
          color = Colors.purple.shade600;
        } else if (label.contains('toilet_male')) {
          icon = Icons.male;
          color = Colors.blue.shade600;
        } else if (label.contains('toilet') || label.contains('restroom')) {
          icon = Icons.wc;
          color = Colors.purple.shade600;
        } else if (label.contains('entrance') || label.contains('exit')) {
          icon = Icons.door_front_door;
          color = Colors.brown.shade600;
        }

        if (icon != null) {
          _drawIcon(canvas, Offset(node.x * scale, node.y * scale), icon, color);
        }
      }
    } catch (e) {
      debugPrint('Error in POIPainter: $e');
    }
  }

  void _drawIcon(Canvas canvas, Offset pos, IconData icon, Color color) {
    const double iconSize = 24.0;
    
    // Draw background circle for better visibility
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(pos, iconSize * 0.7, bgPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(pos, iconSize * 0.7, borderPaint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
    );
    
    textPainter.layout();
    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(POIPainter oldDelegate) => oldDelegate.nodes != nodes || oldDelegate.scale != scale;
}
