import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:widget_tooltip/src/triangles/upper_triangle.dart';

/// A widget that renders a left-pointing triangle with rounded corners.
///
/// Used primarily as the pointer for tooltips positioned to the right of their target.
/// Implemented as a 270-degree rotation of [UpperTriangle].
class LeftTriangle extends StatelessWidget {
  const LeftTriangle({
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
      angle: 3 * pi / 2, // 270 degrees
      child: CustomPaint(
        painter: UpperTrianglePainter(
          backgroundColor: backgroundColor,
          triangleRadius: triangleRadius,
        ),
      ),
    );
  }
}
