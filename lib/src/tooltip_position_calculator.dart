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
    required this.messageBoxOffset,
    required this.triangleOffset,
    required this.scaleAlignment,
    required this.triangleDirection,
    required this.maxWidth,
  });

  final bool showAbove;
  final bool showLeft;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset messageBoxOffset;
  final Offset triangleOffset;
  final Alignment scaleAlignment;
  final AxisDirection triangleDirection;
  final double maxWidth;
}

/// Calculates tooltip positioning and layout parameters.
///
/// This class encapsulates all the complex positioning logic for tooltips,
/// including anchor points, offsets, overflow adjustment, and constraints.
///
/// Uses a two-phase approach: first the tooltip is measured, then this calculator
/// uses the measured size to compute overflow-adjusted offsets.
class TooltipPositionCalculator {
  const TooltipPositionCalculator({
    required this.axis,
    required this.autoFlip,
    required this.direction,
    required this.targetPadding,
    required this.triangleSize,
    required this.offsetIgnore,
  });

  final Axis axis;
  final bool autoFlip;
  final WidgetTooltipDirection? direction;
  final double targetPadding;
  final Size triangleSize;
  final bool offsetIgnore;

  /// Calculates position flags and maxWidth constraint before measurement.
  ///
  /// Call this before rendering the tooltip for measurement to get the
  /// correct maxWidth constraint.
  ({bool showAbove, bool showLeft, double maxWidth}) calculateConstraints({
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

    final maxWidth = _calculateMaxWidth(
      screenSize: screenSize,
      padding: padding,
      targetPosition: targetPosition,
      targetSize: targetSize,
      showLeft: position.showLeft,
    );

    return (
      showAbove: position.showAbove,
      showLeft: position.showLeft,
      maxWidth: maxWidth,
    );
  }

  /// Calculates all layout parameters for the tooltip using measured size.
  ///
  /// [messageBoxSize] must be the actual measured size of the tooltip message box.
  /// This enables precise overflow-adjusted positioning.
  TooltipLayoutData calculate({
    required Offset targetCenter,
    required Size screenSize,
    required EdgeInsets padding,
    required EdgeInsets safePadding,
    required Offset targetPosition,
    required Size targetSize,
    required Size messageBoxSize,
  }) {
    final position = _calculatePosition(
      targetCenter: targetCenter,
      screenSize: screenSize,
    );

    final anchors = _calculateAnchors(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    // Calculate overflow-adjusted offsets (ported from v1.1.4)
    final overflowOffset = _calculateOverflowOffset(
      targetPosition: targetPosition,
      targetSize: targetSize,
      messageBoxSize: messageBoxSize,
      screenSize: screenSize,
      padding: padding,
      safePadding: safePadding,
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    final triangleOffset = _calculateTriangleOffset(
      targetAnchor: anchors.targetAnchor,
    );

    final messageBoxOffset = _calculateMessageBoxOffset(
      targetAnchor: anchors.targetAnchor,
      overflowOffset: overflowOffset,
    );

    return TooltipLayoutData(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
      targetAnchor: anchors.targetAnchor,
      followerAnchor: anchors.followerAnchor,
      messageBoxOffset: messageBoxOffset,
      triangleOffset: triangleOffset,
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
  ///
  /// When [direction] is explicitly set, it always takes precedence.
  /// When [direction] is null and [autoFlip] is true, position is determined
  /// by the target's location relative to the screen center.
  ({bool showAbove, bool showLeft}) _calculatePosition({
    required Offset targetCenter,
    required Size screenSize,
  }) {
    return (
      showAbove: switch (direction) {
        WidgetTooltipDirection.top => true,
        WidgetTooltipDirection.bottom => false,
        _ when autoFlip => targetCenter.dy > screenSize.height / 2,
        _ => false,
      },
      showLeft: switch (direction) {
        WidgetTooltipDirection.left => true,
        WidgetTooltipDirection.right => false,
        _ when autoFlip => targetCenter.dx > screenSize.width / 2,
        _ => false,
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

  /// Calculates the triangle offset from the target.
  ///
  /// The triangle is positioned at [targetPadding] distance from the target edge.
  Offset _calculateTriangleOffset({
    required Alignment targetAnchor,
  }) {
    return switch (targetAnchor) {
      Alignment.bottomCenter => Offset(0, targetPadding),
      Alignment.topCenter => Offset(0, -targetPadding),
      Alignment.centerLeft => Offset(-targetPadding, 0),
      Alignment.centerRight => Offset(targetPadding, 0),
      _ => Offset.zero,
    };
  }

  /// Calculates the message box offset including triangle size and overflow adjustment.
  ///
  /// The message box is positioned beyond the triangle, with optional overflow
  /// adjustment to keep it within screen bounds.
  /// The ±1 pixel ensures seamless connection between triangle and message box.
  Offset _calculateMessageBoxOffset({
    required Alignment targetAnchor,
    required Offset overflowOffset,
  }) {
    final dx = offsetIgnore ? 0.0 : overflowOffset.dx;
    final dy = offsetIgnore ? 0.0 : overflowOffset.dy;

    return switch (targetAnchor) {
      Alignment.bottomCenter => Offset(
          dx, triangleSize.height + targetPadding - 1),
      Alignment.topCenter => Offset(
          dx, -triangleSize.height - targetPadding + 1),
      Alignment.centerLeft => Offset(
          -targetPadding - triangleSize.width + 1, dy),
      Alignment.centerRight => Offset(
          targetPadding + triangleSize.width - 1, dy),
      _ => Offset.zero,
    };
  }

  /// Calculates overflow adjustment offset based on measured tooltip size.
  ///
  /// This is the core of the v1.1.4 positioning approach: using the actual
  /// measured size of the message box to determine how much to shift the
  /// tooltip to prevent it from going off-screen.
  Offset _calculateOverflowOffset({
    required Offset targetPosition,
    required Size targetSize,
    required Size messageBoxSize,
    required Size screenSize,
    required EdgeInsets padding,
    required EdgeInsets safePadding,
    required bool showAbove,
    required bool showLeft,
  }) {
    // Horizontal overflow (for vertical axis tooltips)
    final double overflowWidth =
        (messageBoxSize.width - targetSize.width) / 2;
    final edgeFromLeft = targetPosition.dx - overflowWidth;
    final edgeFromRight = screenSize.width -
        (targetPosition.dx + targetSize.width + overflowWidth);
    final edgeFromHorizontal = min(edgeFromLeft, edgeFromRight);

    double dx = 0;
    if (edgeFromHorizontal < padding.horizontal / 2) {
      if (!showLeft) {
        // Target is on left side of screen - push tooltip right
        dx = (padding.horizontal / 2) - edgeFromHorizontal;
      } else {
        // Target is on right side of screen - push tooltip left
        dx = -(padding.horizontal / 2) + edgeFromHorizontal;
      }
    }

    // Vertical overflow (for horizontal axis tooltips)
    final double overflowHeight =
        (messageBoxSize.height - targetSize.height) / 2;
    final edgeFromTop = targetPosition.dy - overflowHeight;
    final edgeFromBottom = screenSize.height -
        (targetPosition.dy + targetSize.height + overflowHeight);
    final edgeFromVertical = min(edgeFromTop, edgeFromBottom);

    double dy = 0;
    if (edgeFromVertical < padding.vertical / 2) {
      if (!showAbove) {
        // Target is in top half - push tooltip down
        dy = safePadding.top +
            (padding.vertical / 2) -
            edgeFromVertical;
      } else {
        // Target is in bottom half - push tooltip up
        dy = safePadding.bottom -
            (padding.vertical / 2) +
            edgeFromVertical;
      }
    }

    return Offset(dx, dy);
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
