import 'dart:math';

import 'package:flutter/material.dart';

/// A triangle indicator widget for tooltips that supports all directions.
class TooltipTriangle extends StatelessWidget {
  const TooltipTriangle({
    super.key,
    required this.direction,
    this.color = Colors.white,
    required this.radius,
  });

  /// The direction the triangle points to.
  final AxisDirection direction;

  /// The color of the triangle.
  final Color color;

  /// The corner radius of the triangle tip.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final double rotationAngle = switch (direction) {
      AxisDirection.up => 0,
      AxisDirection.right => pi / 2,
      AxisDirection.down => pi,
      AxisDirection.left => 3 * pi / 2,
    };

    return Transform.rotate(
      angle: rotationAngle,
      child: CustomPaint(
        painter: _TooltipTrianglePainter(
          color: color,
          radius: radius,
        ),
      ),
    );
  }
}

class _TooltipTrianglePainter extends CustomPainter {
  const _TooltipTrianglePainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final double a = size.width / 2;
    final double b = size.height;
    final double r = radius;

    final double p = (b * r) / sqrt(b * b + a * a);
    final double q =
        -(b * b * sqrt(b * b + a * a) * r - a * b * b * b - a * a * a * b) /
            (a * b * b + a * a * a);

    final path = Path();
    path.moveTo(a + a, size.height); // Bottom right
    path.lineTo(a + p, size.height - q);
    path.arcToPoint(
      Offset(a - p, size.height - q),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(0, size.height); // Bottom left
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TooltipTrianglePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
