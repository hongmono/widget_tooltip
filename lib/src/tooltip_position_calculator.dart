import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'enums.dart';

/// Data class containing all calculated layout parameters for tooltip positioning.
class TooltipLayoutData {
  const TooltipLayoutData({
    required this.showAbove,
    required this.showLeft,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.tooltipOffset,
    required this.scaleAlignment,
    required this.triangleDirection,
    required this.maxWidth,
  });

  final bool showAbove;
  final bool showLeft;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset tooltipOffset;
  final Alignment scaleAlignment;
  final AxisDirection triangleDirection;
  final double maxWidth;
}

/// Calculates tooltip positioning and layout parameters.
///
/// This class encapsulates all the complex positioning logic for tooltips,
/// including anchor points, offsets, and constraints.
class TooltipPositionCalculator {
  const TooltipPositionCalculator({
    required this.axis,
    required this.autoFlip,
    required this.direction,
    required this.targetPadding,
    required this.triangleSize,
  });

  final Axis axis;
  final bool autoFlip;
  final WidgetTooltipDirection? direction;
  final double targetPadding;
  final Size triangleSize;

  /// Calculates all layout parameters for the tooltip.
  TooltipLayoutData calculate({
    required Offset targetCenter,
    required Size screenSize,
    required EdgeInsets padding,
    required Offset targetPosition,
    required Size targetSize,
  }) {
    final position = _calculatePosition(
      targetCenter: targetCenter,
      screenSize: screenSize,
    );

    final anchors = _calculateAnchors(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    final tooltipOffset = _calculateTooltipOffset(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    return TooltipLayoutData(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
      targetAnchor: anchors.targetAnchor,
      followerAnchor: anchors.followerAnchor,
      tooltipOffset: tooltipOffset,
      scaleAlignment: _calculateScaleAlignment(
        showAbove: position.showAbove,
        showLeft: position.showLeft,
      ),
      triangleDirection: _calculateTriangleDirection(
        showAbove: position.showAbove,
        showLeft: position.showLeft,
      ),
      maxWidth: _calculateMaxWidth(
        screenSize: screenSize,
        padding: padding,
        targetPosition: targetPosition,
        targetSize: targetSize,
        showLeft: position.showLeft,
      ),
    );
  }

  /// Calculates tooltip position flags based on target position and screen center.
  ({bool showAbove, bool showLeft}) _calculatePosition({
    required Offset targetCenter,
    required Size screenSize,
  }) {
    if (autoFlip) {
      return (
        showAbove: targetCenter.dy > screenSize.height / 2,
        showLeft: targetCenter.dx > screenSize.width / 2,
      );
    }

    return (
      showAbove: switch (direction) {
        WidgetTooltipDirection.top => true,
        WidgetTooltipDirection.bottom => false,
        _ => targetCenter.dy > screenSize.height / 2,
      },
      showLeft: switch (direction) {
        WidgetTooltipDirection.left => true,
        WidgetTooltipDirection.right => false,
        _ => targetCenter.dx > screenSize.width / 2,
      },
    );
  }

  /// Calculates anchor alignments based on tooltip position and axis.
  ({Alignment targetAnchor, Alignment followerAnchor}) _calculateAnchors({
    required bool showAbove,
    required bool showLeft,
  }) {
    if (axis == Axis.vertical) {
      if (showAbove) {
        return (
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
        );
      } else {
        return (
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
        );
      }
    } else {
      if (showLeft) {
        return (
          targetAnchor: Alignment.centerLeft,
          followerAnchor: Alignment.centerRight,
        );
      } else {
        return (
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
        );
      }
    }
  }

  /// Calculates offset for tooltip positioning.
  Offset _calculateTooltipOffset({
    required bool showAbove,
    required bool showLeft,
  }) {
    if (axis == Axis.vertical) {
      final gap = targetPadding;
      return showAbove ? Offset(0, -gap) : Offset(0, gap);
    } else {
      final gap = targetPadding;
      return showLeft ? Offset(-gap, 0) : Offset(gap, 0);
    }
  }

  /// Calculates scale alignment for animation based on tooltip position.
  Alignment _calculateScaleAlignment({
    required bool showAbove,
    required bool showLeft,
  }) {
    return switch (axis) {
      Axis.vertical when showAbove => Alignment.bottomCenter,
      Axis.vertical => Alignment.topCenter,
      Axis.horizontal when showLeft => Alignment.centerRight,
      Axis.horizontal => Alignment.centerLeft,
    };
  }

  /// Determines the triangle direction based on axis and position.
  AxisDirection _calculateTriangleDirection({
    required bool showAbove,
    required bool showLeft,
  }) {
    return switch (axis) {
      Axis.vertical when showAbove => AxisDirection.down,
      Axis.vertical => AxisDirection.up,
      Axis.horizontal when showLeft => AxisDirection.right,
      Axis.horizontal => AxisDirection.left,
    };
  }

  /// Calculates max width for tooltip based on screen constraints.
  double _calculateMaxWidth({
    required Size screenSize,
    required EdgeInsets padding,
    required Offset targetPosition,
    required Size targetSize,
    required bool showLeft,
  }) {
    double maxWidth = screenSize.width - padding.horizontal;

    if (axis == Axis.horizontal) {
      if (showLeft) {
        maxWidth = min(
          maxWidth,
          targetPosition.dx - targetPadding - triangleSize.width - padding.left,
        );
      } else {
        maxWidth = min(
          maxWidth,
          screenSize.width -
              targetPosition.dx -
              targetSize.width -
              targetPadding -
              triangleSize.width -
              padding.right,
        );
      }
    }

    return max(kMinTooltipWidth, maxWidth);
  }
}
