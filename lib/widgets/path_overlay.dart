import 'dart:math';
import 'package:flutter/material.dart';

class PathOverlay extends CustomPainter {
  final List<Offset> points;
  final List<Offset> turnPoints;
  final bool isSimulating;
  final Offset? currentPosition;
  final double heading;
  final double scale;

  PathOverlay({
    required this.points,
    this.turnPoints = const [],
    this.isSimulating = false,
    this.currentPosition,
    this.heading = 0.0,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
    }
    
    // 1. Draw Route Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 10.0 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(path, shadowPaint);

    // 2. Draw Route Outline (Border)
    final borderPaint = Paint()
      ..color = const Color(0xFF1565C0) // Darker blue
      ..strokeWidth = 10.0 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // 3. Draw Route Inner Core
    final corePaint = Paint()
      ..color = const Color(0xFF42A5F5) // Lighter blue
      ..strokeWidth = 6.0 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, corePaint);

    // 4. Draw Direction Arrows
    _drawDirectionArrows(canvas);

    // 5. Draw Turn Markers
    _drawTurnMarkers(canvas);

    // 6. Draw Start & End Markers (Premium Pin Style)
    _drawPin(canvas, points.first, Colors.green, "Start");
    _drawPin(canvas, points.last, Colors.red, "End");

    // 7. Draw Current Simulation/PDR position
    if (isSimulating && currentPosition != null) {
      _drawUserLocation(canvas);
    }
  }

  void _drawDirectionArrows(Canvas canvas) {
    final arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final segmentLen = sqrt(dx * dx + dy * dy);
      if (segmentLen < 50 * scale) continue;

      final ux = dx / segmentLen;
      final uy = dy / segmentLen;

      final spacing = 80.0 * scale;
      final arrowSize = 6.0 * scale;
      for (double d = spacing; d < segmentLen; d += spacing) {
        final px = a.dx + ux * d;
        final py = a.dy + uy * d;
        final tip = Offset(px + ux * arrowSize, py + uy * arrowSize);
        final left = Offset(
          px - ux * arrowSize + (-uy) * arrowSize * 1.0,
          py - uy * arrowSize + ux * arrowSize * 1.0,
        );
        final right = Offset(
          px - ux * arrowSize + uy * arrowSize * 1.0,
          py - uy * arrowSize - ux * arrowSize * 1.0,
        );

        final arrowPath = Path()
          ..moveTo(left.dx, left.dy)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(right.dx, right.dy);
          
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
  }

  void _drawTurnMarkers(Canvas canvas) {
    if (turnPoints.isEmpty) return;

    final markerFill = Paint()..color = Colors.white;
    final markerStroke = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale;

    for (final point in turnPoints) {
      canvas.drawCircle(point, 6 * scale, markerFill);
      canvas.drawCircle(point, 6 * scale, markerStroke);
    }
  }

  void _drawPin(Canvas canvas, Offset point, Color color, String label) {
    final pinSize = 14.0 * scale;
    
    // Oval Shadow at the tip
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(point.dx, point.dy + 2 * scale),
        width: pinSize * 1.5,
        height: pinSize * 0.6,
      ),
      Paint()..color = Colors.black38..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Pin Body
    final path = Path();
    path.moveTo(point.dx, point.dy); // Tip at exactly the point
    
    // Curve up to the left side
    path.quadraticBezierTo(
      point.dx - pinSize, point.dy - pinSize * 0.5, 
      point.dx - pinSize, point.dy - pinSize * 2.0
    );
    
    // Arc over the top
    path.arcToPoint(
      Offset(point.dx + pinSize, point.dy - pinSize * 2.0),
      radius: Radius.circular(pinSize),
      clockwise: true,
    );
    
    // Curve down from right side to tip
    path.quadraticBezierTo(
      point.dx + pinSize, point.dy - pinSize * 0.5, 
      point.dx, point.dy
    );
    
    canvas.drawPath(path, Paint()..color = color);
    
    // Inner Dot (center of the top arc is at point.dy - pinSize * 2.0)
    canvas.drawCircle(
      Offset(point.dx, point.dy - pinSize * 2.0), 
      pinSize * 0.35, 
      Paint()..color = Colors.white,
    );
  }

  void _drawUserLocation(Canvas canvas) {
    // Halo pulse effect
    canvas.drawCircle(
      currentPosition!, 
      16 * scale, 
      Paint()..color = Colors.blue.withValues(alpha: 0.2),
    );
    
    // Outer white border
    canvas.drawCircle(
      currentPosition!, 
      10 * scale, 
      Paint()..color = Colors.white,
    );
    
    // Inner blue core
    canvas.drawCircle(
      currentPosition!, 
      7 * scale, 
      Paint()..color = Colors.blue.shade600,
    );

    // Draw Heading Arrow
    if (heading != 0.0) {
      final path = Path();
      final length = 18.0 * scale;
      final width = 10.0 * scale;
      
      final tipX = currentPosition!.dx + length * cos(heading);
      final tipY = currentPosition!.dy + length * sin(heading);
      
      final leftX = currentPosition!.dx + width * cos(heading - pi/2);
      final leftY = currentPosition!.dy + width * sin(heading - pi/2);
      
      final rightX = currentPosition!.dx + width * cos(heading + pi/2);
      final rightY = currentPosition!.dy + width * sin(heading + pi/2);

      path.moveTo(tipX, tipY);
      path.lineTo(leftX, leftY);
      path.lineTo(currentPosition!.dx, currentPosition!.dy);
      path.lineTo(rightX, rightY);
      path.close();

      canvas.drawPath(
        path, 
        Paint()
          ..color = Colors.blue.shade600.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PathOverlay oldDelegate) {
    return oldDelegate.currentPosition != currentPosition
        || oldDelegate.heading != heading
        || oldDelegate.isSimulating != isSimulating
        || oldDelegate.scale != scale
        || oldDelegate.points.length != points.length
        || oldDelegate.turnPoints.length != turnPoints.length;
  }
}
