import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/route_response.dart';
import '../models/navigation_step.dart';

/// Interactive floor-plan visualisation.
/// Displays a schematic map of the selected floor with the route highlighted.
class FloorMapView extends StatefulWidget {
  final RouteResponse route;
  const FloorMapView({super.key, required this.route});

  @override
  State<FloorMapView> createState() => _FloorMapViewState();
}

class _FloorMapViewState extends State<FloorMapView> {
  // Currently displayed floor
  late int _selectedFloor;
  late List<int> _routeFloors;

  @override
  void initState() {
    super.initState();
    _routeFloors = _computeRouteFloors();
    _selectedFloor = widget.route.from.floor;
  }

  List<int> _computeRouteFloors() {
    final seen = <int>{};
    for (final step in widget.route.steps) {
      seen.add(step.floor);
    }
    final list = seen.toList()..sort();
    return list;
  }

  List<NavigationStep> _stepsOnFloor(int floor) =>
      widget.route.steps.where((s) => s.floor == floor).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Floor selector tabs
        if (_routeFloors.length > 1) _buildFloorSelector(),
        // Map canvas
        Expanded(
          child: InteractiveViewer(
            minScale: 0.7,
            maxScale: 4.0,
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _HospitalFloorPainter(
                floor: _selectedFloor,
                steps: _stepsOnFloor(_selectedFloor),
                fromFloor: widget.route.from.floor,
                toFloor: widget.route.to.floor,
              ),
            ),
          ),
        ),
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Floor: ', style: AppTheme.bodyMedium),
          ..._routeFloors.map(
            (f) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(f == 0 ? 'GF' : 'F$f'),
                selected: _selectedFloor == f,
                onSelected: (_) => setState(() => _selectedFloor = f),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: _selectedFloor == f ? Colors.white : AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    const items = [
      _LegendItem(AppTheme.stepStart, 'Your location'),
      _LegendItem(AppTheme.stepArrival, 'Destination'),
      _LegendItem(AppTheme.primary, 'Route path'),
      _LegendItem(AppTheme.stepElevator, 'Elevator'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(item.label,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF4A5568))),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  const _LegendItem(this.color, this.label);
}

// ── Custom painter ────────────────────────────────────────────────────────────

class _HospitalFloorPainter extends CustomPainter {
  final int floor;
  final List<NavigationStep> steps;
  final int fromFloor;
  final int toFloor;

  const _HospitalFloorPainter({
    required this.floor,
    required this.steps,
    required this.fromFloor,
    required this.toFloor,
  });

  // Convert 0–100 coordinate space to canvas
  Offset _toCanvas(Size size, double x, double y) {
    const pad = 32.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    return Offset(pad + x / 100 * w, pad + (1 - y / 100) * h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGrid(canvas, size);
    _drawInfrastructure(canvas, size);
    _drawDepartments(canvas, size);
    _drawRoute(canvas, size);
    _drawFloorLabel(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF0F4F8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(0),
      ),
      paint,
    );

    // Hospital outline (outer walls)
    final wallPaint = Paint()
      ..color = const Color(0xFFCBD5E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final inner = Paint()..color = Colors.white;

    const pad = 24.0;
    final rect = Rect.fromLTWH(
        pad, pad, size.width - pad * 2, size.height - pad * 2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), inner);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), wallPaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5;

    for (var i = 10; i < 100; i += 10) {
      final start = _toCanvas(size, i.toDouble(), 0);
      final end = _toCanvas(size, i.toDouble(), 100);
      canvas.drawLine(start, end, gridPaint);

      final hStart = _toCanvas(size, 0, i.toDouble());
      final hEnd = _toCanvas(size, 100, i.toDouble());
      canvas.drawLine(hStart, hEnd, gridPaint);
    }
  }

  void _drawInfrastructure(Canvas canvas, Size size) {
    // Draw fixed infrastructure for every floor:
    // Elevator Bank A (x=30, y=68), Elevator Bank B (x=70, y=68)
    // Stairs A (x=10, y=68), Stairs B (x=90, y=68)
    // Corridor (x=50, y=50–68)

    // Central corridor
    final corrPaint = Paint()..color = const Color(0xFFEDF2F7);
    final corrA = _toCanvas(size, 10, 60);
    final corrB = _toCanvas(size, 90, 42);
    canvas.drawRect(
      Rect.fromPoints(corrA, corrB),
      corrPaint,
    );

    // Elevator A
    _drawRoom(canvas, size, 30, 68, 'ELV-A', AppTheme.stepElevator, 7);
    // Elevator B
    _drawRoom(canvas, size, 70, 68, 'ELV-B', AppTheme.stepElevator, 7);
    // Stairwell A
    _drawRoom(canvas, size, 10, 68, 'STA', AppTheme.stepStairs, 6);
    // Stairwell B
    _drawRoom(canvas, size, 90, 68, 'STB', AppTheme.stepStairs, 6);
  }

  void _drawDepartments(Canvas canvas, Size size) {
    final depts = _floorDepartments(floor);
    for (final dept in depts) {
      _drawRoom(canvas, size, dept.x, dept.y, dept.shortLabel, dept.color, 9);
    }
  }

  void _drawRoom(Canvas canvas, Size size, double x, double y, String label,
      Color color, double radius) {
    final center = _toCanvas(size, x, y);

    final bgPaint = Paint()..color = color.withOpacity(0.15);
    final borderPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: radius * 5, height: radius * 3.5),
        Radius.circular(radius / 2),
      ),
      bgPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: radius * 5, height: radius * 3.5),
        Radius.circular(radius / 2),
      ),
      borderPaint,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      textAlign: TextAlign.center,
    );
    tp.layout(maxWidth: radius * 5);
    tp.paint(
        canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawRoute(Canvas canvas, Size size) {
    if (steps.isEmpty) return;

    // Collect waypoints (approximate positions based on step type)
    final waypoints = <Offset>[];

    for (final step in steps) {
      final pos = _stepPosition(step);
      if (pos != null) {
        waypoints.add(_toCanvas(size, pos.dx, pos.dy));
      }
    }

    if (waypoints.length < 2) {
      // Just draw the point
      if (waypoints.isNotEmpty) {
        _drawPin(canvas, waypoints.first, AppTheme.stepStart, 10);
      }
      return;
    }

    // Draw path
    final pathPaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(waypoints.first.dx, waypoints.first.dy);
    for (var i = 1; i < waypoints.length; i++) {
      path.lineTo(waypoints[i].dx, waypoints[i].dy);
    }
    canvas.drawPath(path, pathPaint);

    // Start pin
    _drawPin(canvas, waypoints.first, AppTheme.stepStart, 12);
    // End pin
    _drawPin(canvas, waypoints.last, AppTheme.stepArrival, 12);

    // Waypoint dots
    final dotPaint = Paint()..color = AppTheme.primary;
    for (var i = 1; i < waypoints.length - 1; i++) {
      canvas.drawCircle(waypoints[i], 4, dotPaint);
    }
  }

  void _drawPin(Canvas canvas, Offset center, Color color, double size) {
    final outerPaint = Paint()..color = color;
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, size, outerPaint);
    canvas.drawCircle(center, size * 0.45, innerPaint);
  }

  void _drawFloorLabel(Canvas canvas, Size size) {
    // Watermark: large floor number in the background
    final wtp = TextPainter(
      text: TextSpan(
        text: floor == 0 ? 'G' : '$floor',
        style: const TextStyle(
          color: Color(0xFFE8EDF3),
          fontSize: 160,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    wtp.layout();
    wtp.paint(
      canvas,
      Offset(
        size.width / 2 - wtp.width / 2,
        size.height / 2 - wtp.height / 2,
      ),
    );

    // Small floor label in top-left
    final ltp = TextPainter(
      text: TextSpan(
        text: floor == 0 ? 'Ground Floor' : 'Floor $floor',
        style: const TextStyle(
          color: Color(0xFF9AA5B4),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    ltp.layout();
    ltp.paint(canvas, const Offset(32, 8));
  }

  Offset? _stepPosition(NavigationStep step) {
    // Map step types to approximate coordinates based on known layout
    switch (step.type) {
      case 'start':
        return _codeToXY(step.locationCode);
      case 'arrival':
        return _codeToXY(step.locationCode);
      case 'elevator':
        return const Offset(30, 68); // Elevator A default
      case 'stairs':
        return const Offset(10, 68); // Stairwell A default
      case 'walk':
      case 'transit':
        return _codeToXY(step.locationCode);
      default:
        return null;
    }
  }

  /// Rough coordinate lookup based on known hospital layout patterns.
  Offset _codeToXY(String code) {
    // Elevator / stairwell codes
    if (code.endsWith('-ELA')) return const Offset(30, 68);
    if (code.endsWith('-ELB')) return const Offset(70, 68);
    if (code.endsWith('-STA')) return const Offset(10, 68);
    if (code.endsWith('-STB')) return const Offset(90, 68);
    if (code.endsWith('-COR')) return const Offset(50, 50);

    // Ground floor specials
    const coordMap = {
      'GF-ENT':   Offset(50, 5),
      'GF-LOBBY': Offset(50, 20),
      'GF-REC':   Offset(35, 30),
      'GF-EMG':   Offset(85, 30),
      'GF-TRM':   Offset(85, 45),
      'GF-PHA':   Offset(15, 35),
      'GF-ATM':   Offset(15, 55),
      'GF-CAF':   Offset(85, 55),
      'GF-SEC':   Offset(15, 5),
      'GF-AMB':   Offset(85, 5),
      // Floor 1
      '1F-GMED':  Offset(15, 15),
      '1F-PED':   Offset(50, 10),
      '1F-ENT':   Offset(85, 15),
      '1F-OPTH':  Offset(15, 85),
      '1F-DERM':  Offset(50, 90),
      '1F-XRAY':  Offset(85, 85),
      '1F-LAB':   Offset(15, 50),
      '1F-BILL':  Offset(85, 50),
      // Floor 2
      '2F-ORTH':  Offset(15, 15),
      '2F-SPM':   Offset(50, 10),
      '2F-RHEU':  Offset(85, 15),
      '2F-PHY':   Offset(15, 85),
      '2F-OCC':   Offset(50, 90),
      '2F-PLR':   Offset(85, 85),
      '2F-MRD':   Offset(85, 50),
      // Floor 3
      '3F-CARD':  Offset(15, 15),
      '3F-CICU':  Offset(50, 10),
      '3F-ECHO':  Offset(85, 15),
      '3F-CATH':  Offset(15, 85),
      '3F-PULM':  Offset(50, 90),
      '3F-RESP':  Offset(85, 85),
      '3F-SLP':   Offset(85, 50),
    };
    return coordMap[code] ?? const Offset(50, 50);
  }

  List<_DeptData> _floorDepartments(int floor) {
    switch (floor) {
      case 0:
        return [
          _DeptData(50, 5, 'Entrance', AppTheme.primary),
          _DeptData(35, 30, 'Reception', AppTheme.primary),
          _DeptData(85, 30, 'Emergency', AppTheme.emergency),
          _DeptData(85, 45, 'Trauma', AppTheme.emergency),
          _DeptData(15, 35, 'Pharmacy', const Color(0xFF7B1FA2)),
          _DeptData(15, 55, 'ATM / Cash', AppTheme.accent),
          _DeptData(85, 55, 'Cafeteria', const Color(0xFFF57C00)),
          _DeptData(15, 5, 'Security', const Color(0xFF546E7A)),
          _DeptData(85, 5, 'Ambulance', AppTheme.emergency),
        ];
      case 1:
        return [
          _DeptData(15, 15, 'Gen. Med', AppTheme.primary),
          _DeptData(50, 10, 'Pediatrics', const Color(0xFFE91E63)),
          _DeptData(85, 15, 'ENT', AppTheme.accent),
          _DeptData(15, 85, 'Ophthal.', const Color(0xFF1565C0)),
          _DeptData(50, 90, 'Dermatol.', const Color(0xFF4CAF50)),
          _DeptData(85, 85, 'Radiology', const Color(0xFF7B1FA2)),
          _DeptData(15, 50, 'Path. Lab', const Color(0xFFF57C00)),
          _DeptData(85, 50, 'Billing', const Color(0xFF546E7A)),
        ];
      case 2:
        return [
          _DeptData(15, 15, 'Ortho', const Color(0xFF33691E)),
          _DeptData(50, 10, 'Sports Med', const Color(0xFF558B2F)),
          _DeptData(85, 15, 'Rheumat.', const Color(0xFF827717)),
          _DeptData(15, 85, 'Physio', const Color(0xFF00838F)),
          _DeptData(50, 90, 'Occ. Ther.', const Color(0xFF00695C)),
          _DeptData(85, 85, 'Plaster Rm', const Color(0xFF5D4037)),
          _DeptData(85, 50, 'Med. Rec.', const Color(0xFF546E7A)),
        ];
      case 3:
        return [
          _DeptData(15, 15, 'Cardiology', AppTheme.emergency),
          _DeptData(50, 10, 'Cardiac ICU', const Color(0xFFC62828)),
          _DeptData(85, 15, 'Echo / ECG', const Color(0xFFD32F2F)),
          _DeptData(15, 85, 'Cath Lab', const Color(0xFFB71C1C)),
          _DeptData(50, 90, 'Pulmonol.', AppTheme.primary),
          _DeptData(85, 85, 'Resp. Ther.', const Color(0xFF1565C0)),
          _DeptData(85, 50, 'Sleep Lab', const Color(0xFF283593)),
        ];
      case 4:
        return [
          _DeptData(15, 15, 'Gynecology', const Color(0xFF880E4F)),
          _DeptData(50, 10, 'Obstetrics', const Color(0xFFAD1457)),
          _DeptData(85, 15, 'Fertility', const Color(0xFFC2185B)),
          _DeptData(15, 85, 'Neonatol.', const Color(0xFFE91E63)),
          _DeptData(50, 90, 'Ante-Natal', const Color(0xFFEC407A)),
          _DeptData(85, 85, 'Midwifery', const Color(0xFFF06292)),
          _DeptData(85, 50, 'Lactation', const Color(0xFFF48FB1)),
        ];
      case 5:
        return [
          _DeptData(15, 15, 'Neurology', AppTheme.primary),
          _DeptData(50, 10, 'Neuro ICU', const Color(0xFF0D47A1)),
          _DeptData(85, 15, 'Psychiatry', const Color(0xFF4527A0)),
          _DeptData(15, 85, 'Counseling', const Color(0xFF7E57C2)),
          _DeptData(50, 90, 'MH Ward', const Color(0xFF9575CD)),
          _DeptData(85, 85, 'EEG Lab', const Color(0xFF5E35B1)),
          _DeptData(85, 50, 'Memory Clinic', const Color(0xFF673AB7)),
        ];
      case 6:
        return [
          _DeptData(15, 15, 'OT – 1 & 2', const Color(0xFF01579B)),
          _DeptData(50, 10, 'OT – 3 & 4', const Color(0xFF0277BD)),
          _DeptData(85, 15, 'OT – 5 & 6', const Color(0xFF0288D1)),
          _DeptData(15, 85, 'Pre-Op', const Color(0xFF039BE5)),
          _DeptData(50, 90, 'Post-Op', const Color(0xFF03A9F4)),
          _DeptData(85, 85, 'CSSD', const Color(0xFF29B6F6)),
          _DeptData(85, 50, 'Anesthesia', const Color(0xFF4FC3F7)),
        ];
      case 7:
        return [
          _DeptData(15, 15, 'MICU', AppTheme.emergency),
          _DeptData(50, 10, 'CCU', const Color(0xFFB71C1C)),
          _DeptData(85, 15, 'NICU', const Color(0xFFC62828)),
          _DeptData(15, 85, 'SICU', const Color(0xFFD32F2F)),
          _DeptData(50, 90, 'Step-Down', const Color(0xFFEF5350)),
          _DeptData(85, 85, 'Burn Unit', const Color(0xFFE53935)),
          _DeptData(85, 50, 'Dialysis', const Color(0xFFC0392B)),
        ];
      case 8:
        return [
          _DeptData(15, 15, 'Private Rms', AppTheme.primary),
          _DeptData(50, 10, 'VIP Suites', const Color(0xFF0D47A1)),
          _DeptData(85, 15, 'Admin', const Color(0xFF546E7A)),
          _DeptData(15, 85, 'HR Dept', const Color(0xFF607D8B)),
          _DeptData(50, 90, 'Conf. Hall', const Color(0xFF78909C)),
          _DeptData(85, 85, 'Cafeteria', const Color(0xFFF57C00)),
          _DeptData(85, 50, 'Rooftop', const Color(0xFF2E7D32)),
        ];
      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(_HospitalFloorPainter old) =>
      old.floor != floor || old.steps != steps;
}

class _DeptData {
  final double x;
  final double y;
  final String shortLabel;
  final Color color;
  const _DeptData(this.x, this.y, this.shortLabel, this.color);
}
