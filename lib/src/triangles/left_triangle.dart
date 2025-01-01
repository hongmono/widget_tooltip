import 'package:flutter/material.dart';
import 'package:widget_tooltip/src/triangles/upper_triangle.dart';

class LeftTriangle extends StatelessWidget {
  const LeftTriangle({
    super.key,
    this.backgroundColor = Colors.white,
    required this.triangleRadius,
  });

  final Color backgroundColor;
  final double triangleRadius;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 270 * 3.14 / 180,
      child: CustomPaint(
        painter: UpperTrianglePainter(
          backgroundColor: backgroundColor,
          triangleRadius: triangleRadius,
        ),
      ),
    );
  }
}
