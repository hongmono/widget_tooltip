import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_tooltip/src/triangles/tooltip_triangle.dart';

// Constants for tooltip configuration
const double _kMinTooltipWidth = 100.0;
const double _kTriangleOverlapOffset = 1.0;

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

/// A controller for programmatically showing and hiding a [WidgetTooltip].
///
/// This controller can be passed to [WidgetTooltip.controller] to enable
/// manual control over the tooltip's visibility.
///
/// Example:
/// ```dart
/// final controller = TooltipController();
///
/// WidgetTooltip(
///   controller: controller,
///   message: Text('Hello'),
///   child: Icon(Icons.info),
/// )
///
/// // Show tooltip programmatically
/// controller.show();
///
/// // Hide tooltip programmatically
/// controller.dismiss();
/// ```
class TooltipController extends ChangeNotifier {
  bool _isShow = false;

  /// Whether the tooltip is currently visible.
  bool get isShow => _isShow;

  /// Shows the tooltip.
  ///
  /// Notifies listeners when the visibility changes.
  void show() {
    _isShow = true;
    notifyListeners();
  }

  /// Dismisses the tooltip.
  ///
  /// The optional [event] parameter is ignored but allows this method
  /// to be used directly as a callback for tap events.
  ///
  /// Notifies listeners when the visibility changes.
  void dismiss([PointerDownEvent? event]) {
    _isShow = false;
    notifyListeners();
  }

  /// Toggles the tooltip visibility.
  ///
  /// Shows the tooltip if it's hidden, hides it if it's visible.
  void toggle() => _isShow ? dismiss() : show();
}

/// A highly customizable tooltip widget that displays a message when triggered.
///
/// [WidgetTooltip] provides rich customization options including:
/// - Multiple trigger modes (tap, long press, double tap, hover, manual)
/// - Various dismiss behaviors (tap outside, tap anywhere, tap inside, manual)
/// - Smart positioning with automatic direction flipping when space is limited
/// - Customizable animations (fade, scale, scaleAndFade, none)
/// - Triangle indicator with adjustable size, color, and corner radius
///
/// Example:
/// ```dart
/// WidgetTooltip(
///   message: Text('This is a tooltip'),
///   triggerMode: WidgetTooltipTriggerMode.tap,
///   child: Icon(Icons.info),
/// )
/// ```
///
/// For programmatic control, use [TooltipController]:
/// ```dart
/// final controller = TooltipController();
///
/// WidgetTooltip(
///   controller: controller,
///   triggerMode: WidgetTooltipTriggerMode.manual,
///   message: Text('Controlled tooltip'),
///   child: Icon(Icons.info),
/// )
/// ```
///
/// See also:
/// - [TooltipController] for programmatic control
/// - [WidgetTooltipTriggerMode] for trigger options
/// - [WidgetTooltipDismissMode] for dismiss behavior options
/// - [WidgetTooltipDirection] for positioning options
/// - [WidgetTooltipAnimation] for animation options
class WidgetTooltip extends StatefulWidget {
  const WidgetTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triangleColor = Colors.black,
    this.triangleSize = const Size(10, 10),
    this.targetPadding = 4,
    this.triangleRadius = 2,
    this.onShow,
    this.onDismiss,
    this.controller,
    this.messagePadding =
        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.messageDecoration = const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(8))),
    this.padding = const EdgeInsets.all(16),
    this.axis = Axis.vertical,
    this.triggerMode,
    this.dismissMode,
    this.offsetIgnore = false,
    this.direction,
    this.animation = WidgetTooltipAnimation.fade,
    this.autoDismissDuration,
    this.animationDuration = const Duration(milliseconds: 300),
    this.autoFlip = true,
  });

  /// Message widget displayed in tooltip
  final Widget message;

  /// Target widget that triggers the tooltip
  final Widget child;

  /// Triangle indicator color
  final Color triangleColor;

  /// Triangle indicator size
  final Size triangleSize;

  /// Gap between target widget and tooltip
  final double targetPadding;

  /// Triangle corner radius
  final double triangleRadius;

  /// Callback when tooltip is shown
  final VoidCallback? onShow;

  /// Callback when tooltip is dismissed
  final VoidCallback? onDismiss;

  /// Controller for manual tooltip control
  final TooltipController? controller;

  /// Padding inside the message box
  final EdgeInsetsGeometry messagePadding;

  /// Decoration for the message box
  final BoxDecoration messageDecoration;

  /// Screen edge padding for tooltip positioning
  final EdgeInsetsGeometry padding;

  /// Tooltip axis direction
  final Axis axis;

  /// Trigger mode for showing tooltip
  final WidgetTooltipTriggerMode? triggerMode;

  /// Dismiss mode for hiding tooltip
  final WidgetTooltipDismissMode? dismissMode;

  /// Whether to ignore offset adjustments for screen bounds
  final bool offsetIgnore;

  /// Forced tooltip direction
  final WidgetTooltipDirection? direction;

  /// Animation type for showing/hiding tooltip
  final WidgetTooltipAnimation animation;

  /// Duration before auto-dismiss (null = no auto-dismiss)
  final Duration? autoDismissDuration;

  /// Animation duration
  final Duration animationDuration;

  /// Whether to automatically position tooltip based on screen center.
  ///
  /// When true (default), the tooltip position is determined by where the target
  /// is on screen:
  /// - Target in top half → tooltip appears below
  /// - Target in bottom half → tooltip appears above
  /// - Target in left half → tooltip appears to the right
  /// - Target in right half → tooltip appears to the left
  ///
  /// When false, the [direction] property is used to fix the tooltip position.
  final bool autoFlip;

  @override
  State<WidgetTooltip> createState() => _WidgetTooltipState();
}

class _WidgetTooltipState extends State<WidgetTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final TooltipController _controller;
  WidgetTooltipTriggerMode? _triggerMode;
  WidgetTooltipDismissMode? _dismissMode;
  Timer? _autoDismissTimer;

  // GlobalKey is required here to get RenderBox for position calculations.
  // - _targetKey: Used to track target widget's position across frames
  // - _messageKey: Used to calculate message bounds for screen edge adjustment
  final _targetKey = GlobalKey(debugLabel: 'WidgetTooltip_target');
  final _messageKey = GlobalKey(debugLabel: 'WidgetTooltip_message');
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _controller = widget.controller ?? TooltipController();
    _controller.addListener(_listener);

    _initProperties();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant WidgetTooltip oldWidget) {
    _initProperties();
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _cancelAutoDismissTimer();
    _dismiss();
    _controller.removeListener(_listener);
    if (widget.controller == null) {
      _controller.dispose();
    }

    _overlayEntry?.remove();
    _animationController.dispose();

    super.dispose();
  }

  void _listener() {
    if (_controller.isShow == true) {
      _show();
    } else {
      _dismiss();
    }
  }

  void _initProperties() {
    _triggerMode = switch (widget.controller) {
      null => widget.triggerMode ?? WidgetTooltipTriggerMode.longPress,
      _ => widget.triggerMode,
    };

    _dismissMode = switch (widget.controller) {
      null => widget.dismissMode ?? WidgetTooltipDismissMode.tapAnywhere,
      _ => widget.dismissMode,
    };
  }

  /// Calculates tooltip position flags based on target position and screen center.
  ///
  /// Returns a record containing:
  /// - showAbove: whether tooltip should appear above the target
  /// - showLeft: whether tooltip should appear to the left of target
  ({bool showAbove, bool showLeft}) _calculateTooltipPosition({
    required Offset targetCenter,
    required Size screenSize,
  }) {
    if (widget.autoFlip) {
      return (
        showAbove: targetCenter.dy > screenSize.height / 2,
        showLeft: targetCenter.dx > screenSize.width / 2,
      );
    }

    return (
      showAbove: switch (widget.direction) {
        WidgetTooltipDirection.top => true,
        WidgetTooltipDirection.bottom => false,
        _ => targetCenter.dy > screenSize.height / 2,
      },
      showLeft: switch (widget.direction) {
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
    if (widget.axis == Axis.vertical) {
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

  /// Calculates offsets for tooltip and triangle positioning.
  ({Offset tooltipOffset, Offset triangleOffset}) _calculateOffsets({
    required bool showAbove,
    required bool showLeft,
  }) {
    if (widget.axis == Axis.vertical) {
      // Subtract overlap offset to seamlessly connect triangle with tooltip
      final gap =
          widget.targetPadding + widget.triangleSize.height - _kTriangleOverlapOffset;
      if (showAbove) {
        return (
          tooltipOffset: Offset(0, -gap),
          triangleOffset: Offset(0, -widget.targetPadding),
        );
      } else {
        return (
          tooltipOffset: Offset(0, gap),
          triangleOffset: Offset(0, widget.targetPadding),
        );
      }
    } else {
      // Subtract overlap offset to seamlessly connect triangle with tooltip
      final gap =
          widget.targetPadding + widget.triangleSize.width - _kTriangleOverlapOffset;
      if (showLeft) {
        return (
          tooltipOffset: Offset(-gap, 0),
          triangleOffset: Offset(-widget.targetPadding, 0),
        );
      } else {
        return (
          tooltipOffset: Offset(gap, 0),
          triangleOffset: Offset(widget.targetPadding, 0),
        );
      }
    }
  }

  /// Calculates scale alignment for animation based on tooltip position.
  Alignment _calculateScaleAlignment({
    required bool showAbove,
    required bool showLeft,
  }) {
    return switch (widget.axis) {
      Axis.vertical when showAbove => Alignment.bottomCenter,
      Axis.vertical => Alignment.topCenter,
      Axis.horizontal when showLeft => Alignment.centerRight,
      Axis.horizontal => Alignment.centerLeft,
    };
  }

  /// Determines the triangle direction based on axis and position.
  AxisDirection? _calculateTriangleDirection({
    required bool showAbove,
    required bool showLeft,
  }) {
    return switch (widget.axis) {
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

    if (widget.axis == Axis.horizontal) {
      if (showLeft) {
        maxWidth = min(
          maxWidth,
          targetPosition.dx -
              widget.targetPadding -
              widget.triangleSize.width -
              padding.left,
        );
      } else {
        maxWidth = min(
          maxWidth,
          screenSize.width -
              targetPosition.dx -
              targetSize.width -
              widget.targetPadding -
              widget.triangleSize.width -
              padding.right,
        );
      }
    }

    return max(_kMinTooltipWidth, maxWidth);
  }

  /// Builds the triangle widget based on direction.
  Widget _buildTriangle(AxisDirection? direction) {
    if (direction == null) return const SizedBox.shrink();

    return TooltipTriangle(
      direction: direction,
      color: widget.triangleColor,
      radius: widget.triangleRadius,
    );
  }

  /// Schedules tooltip dismissal in the next frame.
  void _scheduleDismiss() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.dismiss();
    });
  }

  /// Checks if target is visible on screen.
  bool _isTargetVisible({
    required Offset position,
    required Size targetSize,
    required Size screenSize,
  }) {
    return position.dy > -targetSize.height &&
        position.dy < screenSize.height &&
        position.dx > -targetSize.width &&
        position.dx < screenSize.width;
  }

  void _startAutoDismissTimer() {
    if (widget.autoDismissDuration != null) {
      _autoDismissTimer?.cancel();
      _autoDismissTimer = Timer(widget.autoDismissDuration!, () {
        _controller.dismiss();
      });
    }
  }

  void _cancelAutoDismissTimer() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
  }

  Widget _buildAnimatedTooltip(Widget child, Alignment scaleAlignment) {
    return switch (widget.animation) {
      WidgetTooltipAnimation.fade => FadeTransition(
          opacity: _animation,
          child: child,
        ),
      WidgetTooltipAnimation.scale => ScaleTransition(
          scale: _animation,
          alignment: scaleAlignment,
          child: child,
        ),
      WidgetTooltipAnimation.scaleAndFade => FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            alignment: scaleAlignment,
            child: child,
          ),
        ),
      WidgetTooltipAnimation.none => child,
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(key: _targetKey, child: widget.child);

    // Wrap with MouseRegion for hover support
    if (_triggerMode == WidgetTooltipTriggerMode.hover) {
      child = MouseRegion(
        onEnter: (_) => _controller.show(),
        onExit: (_) => _controller.dismiss(),
        child: child,
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: switch (_triggerMode) {
          WidgetTooltipTriggerMode.tap => _controller.toggle,
          _ => null,
        },
        onLongPress: switch (_triggerMode) {
          WidgetTooltipTriggerMode.longPress => _controller.toggle,
          _ => null,
        },
        onDoubleTap: switch (_triggerMode) {
          WidgetTooltipTriggerMode.doubleTap => _controller.toggle,
          _ => null,
        },
        child: child,
      ),
    );
  }

  void _show() {
    if (_animationController.isAnimating) return;
    if (_overlayEntry != null) return;

    final renderObject = _targetKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) {
      assert(() {
        if (renderObject != null && renderObject is! RenderBox) {
          debugPrint(
            'WidgetTooltip: Target render object is not a RenderBox. '
            'Got ${renderObject.runtimeType} instead.',
          );
        }
        return true;
      }());
      return;
    }
    final targetRenderBox = renderObject;

    final targetSize = targetRenderBox.size;
    final targetPosition = targetRenderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final resolvedPadding = widget.padding.resolve(TextDirection.ltr);

    final targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Calculate all layout parameters using helper methods
    final position = _calculateTooltipPosition(
      targetCenter: targetCenter,
      screenSize: screenSize,
    );

    final anchors = _calculateAnchors(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    final offsets = _calculateOffsets(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    final scaleAlignment = _calculateScaleAlignment(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    final triangleDirection = _calculateTriangleDirection(
      showAbove: position.showAbove,
      showLeft: position.showLeft,
    );

    final maxWidth = _calculateMaxWidth(
      screenSize: screenSize,
      padding: resolvedPadding,
      targetPosition: targetPosition,
      targetSize: targetSize,
      showLeft: position.showLeft,
    );

    final triangle = _buildTriangle(triangleDirection);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return _buildOverlayContent(
          targetSize: targetSize,
          screenSize: screenSize,
          resolvedPadding: resolvedPadding,
          anchors: anchors,
          offsets: offsets,
          scaleAlignment: scaleAlignment,
          maxWidth: maxWidth,
          triangle: triangle,
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    if (widget.animation != WidgetTooltipAnimation.none) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }

    _startAutoDismissTimer();
    widget.onShow?.call();
  }

  /// Builds the overlay content widget.
  Widget _buildOverlayContent({
    required Size targetSize,
    required Size screenSize,
    required EdgeInsets resolvedPadding,
    required ({Alignment targetAnchor, Alignment followerAnchor}) anchors,
    required ({Offset tooltipOffset, Offset triangleOffset}) offsets,
    required Alignment scaleAlignment,
    required double maxWidth,
    required Widget triangle,
  }) {
    // Get current target position for screen bounds calculation
    final renderObject = _targetKey.currentContext?.findRenderObject();

    if (renderObject == null ||
        renderObject is! RenderBox ||
        !renderObject.attached) {
      _scheduleDismiss();
      return const SizedBox.shrink();
    }

    final currentTargetRenderBox = renderObject;

    final currentTargetPosition =
        currentTargetRenderBox.localToGlobal(Offset.zero);

    if (!_isTargetVisible(
      position: currentTargetPosition,
      targetSize: targetSize,
      screenSize: screenSize,
    )) {
      _scheduleDismiss();
      return const SizedBox.shrink();
    }

    final currentTargetCenter =
        currentTargetPosition.dx + targetSize.width / 2;

    return TapRegion(
      onTapInside: switch (_dismissMode) {
        WidgetTooltipDismissMode.tapInside => _controller.dismiss,
        WidgetTooltipDismissMode.tapAnywhere => _controller.dismiss,
        // ignore: deprecated_member_use_from_same_package
        WidgetTooltipDismissMode.tapAnyWhere => _controller.dismiss,
        _ => null,
      },
      onTapOutside: switch (_dismissMode) {
        WidgetTooltipDismissMode.tapOutside => _controller.dismiss,
        WidgetTooltipDismissMode.tapAnywhere => _controller.dismiss,
        // ignore: deprecated_member_use_from_same_package
        WidgetTooltipDismissMode.tapAnyWhere => _controller.dismiss,
        _ => null,
      },
      child: Stack(
        children: [
          // Message box with screen bounds adjustment
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: anchors.targetAnchor,
            followerAnchor: anchors.followerAnchor,
            offset: offsets.tooltipOffset,
            child: _buildAnimatedTooltip(
              Builder(
                builder: (context) {
                  return _TooltipOverlay(
                    messageKey: _messageKey,
                    maxWidth: maxWidth,
                    screenSize: screenSize,
                    padding: resolvedPadding,
                    targetCenterX: currentTargetCenter,
                    axis: widget.axis,
                    offsetIgnore: widget.offsetIgnore,
                    messagePadding: widget.messagePadding,
                    messageDecoration: widget.messageDecoration,
                    message: widget.message,
                  );
                },
              ),
              scaleAlignment,
            ),
          ),
          // Triangle
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: anchors.targetAnchor,
            followerAnchor: anchors.followerAnchor,
            offset: offsets.triangleOffset,
            child: _buildAnimatedTooltip(
              SizedBox.fromSize(
                size: widget.triangleSize,
                child: triangle,
              ),
              scaleAlignment,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dismiss() async {
    _cancelAutoDismissTimer();
    if (_overlayEntry == null) return;

    try {
      if (widget.animation != WidgetTooltipAnimation.none) {
        await _animationController.reverse();
      }
    } finally {
      _overlayEntry?.remove();
      _overlayEntry = null;
      widget.onDismiss?.call();
    }
  }
}

/// A widget that positions the tooltip within screen bounds
class _TooltipOverlay extends StatefulWidget {
  const _TooltipOverlay({
    required this.messageKey,
    required this.maxWidth,
    required this.screenSize,
    required this.padding,
    required this.targetCenterX,
    required this.axis,
    required this.offsetIgnore,
    required this.messagePadding,
    required this.messageDecoration,
    required this.message,
  });

  final GlobalKey messageKey;
  final double maxWidth;
  final Size screenSize;
  final EdgeInsets padding;
  final double targetCenterX;
  final Axis axis;
  final bool offsetIgnore;
  final EdgeInsetsGeometry messagePadding;
  final BoxDecoration messageDecoration;
  final Widget message;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay> {
  double _horizontalOffset = 0;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateOffset();
    });
  }

  void _calculateOffset() {
    if (!mounted) return;
    if (widget.offsetIgnore) {
      setState(() => _measured = true);
      return;
    }

    final renderObject = widget.messageKey.currentContext?.findRenderObject();
    if (renderObject == null ||
        renderObject is! RenderBox ||
        !renderObject.hasSize) {
      return;
    }
    final renderBox = renderObject;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    double offset = 0;

    if (widget.axis == Axis.vertical) {
      // Check left edge
      if (position.dx < widget.padding.left) {
        offset = widget.padding.left - position.dx;
      }
      // Check right edge
      else if (position.dx + size.width >
          widget.screenSize.width - widget.padding.right) {
        offset = widget.screenSize.width -
            widget.padding.right -
            position.dx -
            size.width;
      }
    }

    if (offset != _horizontalOffset || !_measured) {
      setState(() {
        _horizontalOffset = offset;
        _measured = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _measured ? 1.0 : 0.0,
      child: Transform.translate(
        offset: Offset(_horizontalOffset, 0),
        child: Material(
          key: widget.messageKey,
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth,
            ),
            child: Semantics(
              container: true,
              liveRegion: true,
              child: Container(
                padding: widget.messagePadding,
                decoration: widget.messageDecoration,
                child: widget.message,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
