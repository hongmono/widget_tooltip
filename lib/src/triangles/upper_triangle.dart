import 'dart:math';

import 'package:flutter/material.dart';

class UpperTriangle extends StatelessWidget {
  const UpperTriangle({
    super.key,
    this.backgroundColor = Colors.white,
    required this.triangleRadius,
  });

  final Color backgroundColor;
  final double triangleRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: UpperTrianglePainter(
        backgroundColor: backgroundColor,
        triangleRadius: triangleRadius,
      ),
    );
  }
}

class UpperTrianglePainter extends CustomPainter {
  const UpperTrianglePainter({
    required this.backgroundColor,
    required this.triangleRadius,
  });

  final Color backgroundColor;
  final double triangleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Calculate triangle dimensions
    // a: half-width of the triangle base
    // b: height of the triangle
    // r: corner radius for rounded edges
    double a = size.width / 2;
    double b = size.height;
    double r = triangleRadius;

    // Mathematical formulas for rounded triangle corners
    // p: horizontal offset for arc positioning
    // q: vertical offset for arc positioning
    double p = (b * r) / sqrt(b * b + a * a);
    double q =
        -(b * b * sqrt(b * b + a * a) * r - a * b * b * b - a * a * a * b) /
            (a * b * b + a * a * a);

    // Draw the triangle path with rounded tip
    final path = Path();
    path.moveTo(a + a, size.height); // Right corner (bottom-right)
    path.lineTo(a + p, size.height - q); // Right side to arc
    path.arcToPoint(Offset(a - p, size.height - q),
        radius: Radius.circular(r), clockwise: false); // Rounded tip
    path.lineTo(0, size.height); // Left side (bottom-left)
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
