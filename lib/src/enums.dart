/// Direction options for tooltip positioning.
enum WidgetTooltipDirection {
  /// Top
  top,

  /// Bottom
  bottom,

  /// Left
  left,

  /// Right
  right,
}

/// Trigger modes for showing the tooltip.
enum WidgetTooltipTriggerMode {
  /// Show tooltip when tap
  tap,

  /// Show tooltip when long press
  longPress,

  /// Show tooltip when double tap
  doubleTap,

  /// Show tooltip on mouse hover (Desktop/Web)
  hover,

  /// Show tooltip only controller
  manual,
}

/// Dismiss modes for hiding the tooltip.
enum WidgetTooltipDismissMode {
  /// Dismiss when tap outside of tooltip
  tapOutside,

  /// Dismiss when tap anywhere
  tapAnywhere,

  /// Dismiss when tap anywhere
  @Deprecated('Use tapAnywhere instead')
  tapAnyWhere,

  /// Dismiss when tap inside of tooltip
  tapInside,

  /// Dismiss only controller
  manual,
}

/// Animation types for showing/hiding the tooltip.
enum WidgetTooltipAnimation {
  /// Fade in/out animation (default)
  fade,

  /// Scale animation
  scale,

  /// Scale with fade animation
  scaleAndFade,

  /// No animation
  none,
}
