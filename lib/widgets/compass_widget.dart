import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';

class CompassWidget extends StatelessWidget {
  const CompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PdrProvider>(
      builder: (context, pdrProvider, child) {
        final heading = pdrProvider.currentHeading;

        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // N indicator
              const Positioned(
                top: 4,
                child: Text(
                  'N',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              // Compass Needle
              Transform.rotate(
                angle: -heading,
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: _CompassNeedlePainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.height / 2 + 6;
    final needleWidth = 4.0;

    // North Needle (Red)
    final northPath = Path()
      ..moveTo(center.dx - needleWidth, center.dy)
      ..lineTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx + needleWidth, center.dy)
      ..close();

    canvas.drawPath(northPath, Paint()..color = Colors.red.shade600);

    // South Needle (Grey)
    final southPath = Path()
      ..moveTo(center.dx - needleWidth, center.dy)
      ..lineTo(center.dx, center.dy + needleLength)
      ..lineTo(center.dx + needleWidth, center.dy)
      ..close();

    canvas.drawPath(southPath, Paint()..color = Colors.grey.shade400);
    
    // Center pin
    canvas.drawCircle(center, 2.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
