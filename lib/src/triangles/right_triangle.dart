import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:widget_tooltip/src/triangles/upper_triangle.dart';

/// A widget that renders a right-pointing triangle with rounded corners.
///
/// Used primarily as the pointer for tooltips positioned to the left of their target.
/// Implemented as a 90-degree rotation of [UpperTriangle].
class RightTriangle extends StatelessWidget {
  const RightTriangle({
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
    return Transform.rotate(
      angle: pi / 2, // 90 degrees
      child: CustomPaint(
        painter: UpperTrianglePainter(
          backgroundColor: backgroundColor,
          triangleRadius: triangleRadius,
        ),
      ),
    );
  }
}
