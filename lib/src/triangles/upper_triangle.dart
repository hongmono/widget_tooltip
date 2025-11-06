import 'dart:math';

import 'package:flutter/material.dart';

/// A widget that renders an upward-pointing triangle with rounded corners.
///
/// Used primarily as the pointer for tooltips positioned below their target.
class UpperTriangle extends StatelessWidget {
  const UpperTriangle({
    super.key,
    this.backgroundColor = Colors.white,
    required this.triangleRadius,
  });

  /// The fill color of the triangle.
  final Color backgroundColor;

  /// The radius of the rounded corners at the triangle's tip.
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

/// Custom painter for rendering an upward-pointing triangle with rounded tip.
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

    final double halfWidth = size.width / 2;
    final double height = size.height;
    final double radius = triangleRadius;

    // Calculate the offset for the rounded tip
    final double horizontalOffset = (height * radius) / sqrt(height * height + halfWidth * halfWidth);
    final double verticalOffset =
        -(height * height * sqrt(height * height + halfWidth * halfWidth) * radius -
          halfWidth * height * height * height -
          halfWidth * halfWidth * halfWidth * height) /
        (halfWidth * height * height + halfWidth * halfWidth * halfWidth);

    final path = Path();
    path.moveTo(size.width, size.height); // Bottom right corner
    path.lineTo(halfWidth + horizontalOffset, size.height - verticalOffset);
    path.arcToPoint(
      Offset(halfWidth - horizontalOffset, size.height - verticalOffset),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, size.height); // Bottom left corner
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant UpperTrianglePainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        triangleRadius != oldDelegate.triangleRadius;
  }
}
