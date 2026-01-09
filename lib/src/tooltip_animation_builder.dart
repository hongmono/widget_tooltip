import 'package:flutter/material.dart';

import 'enums.dart';

/// Builds animated tooltip widgets based on the specified animation type.
///
/// This class encapsulates the animation wrapping logic for tooltips,
/// supporting fade, scale, combined, and no animation modes.
class TooltipAnimationBuilder {
  const TooltipAnimationBuilder({
    required this.animation,
    required this.animationValue,
  });

  final Animation<double> animationValue;
  final WidgetTooltipAnimation animation;

  /// Wraps the child widget with the appropriate animation.
  Widget build({
    required Widget child,
    required Alignment scaleAlignment,
  }) {
    return switch (animation) {
      WidgetTooltipAnimation.fade => FadeTransition(
          opacity: animationValue,
          child: child,
        ),
      WidgetTooltipAnimation.scale => ScaleTransition(
          scale: animationValue,
          alignment: scaleAlignment,
          child: child,
        ),
      WidgetTooltipAnimation.scaleAndFade => FadeTransition(
          opacity: animationValue,
          child: ScaleTransition(
            scale: animationValue,
            alignment: scaleAlignment,
            child: child,
          ),
        ),
      WidgetTooltipAnimation.none => child,
    };
  }
}
