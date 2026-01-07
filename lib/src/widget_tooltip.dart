import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_tooltip/src/triangles/tooltip_triangle.dart';

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

  final _targetKey = GlobalKey();
  final _messageKey = GlobalKey();
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

    final targetRenderBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) return;

    final targetSize = targetRenderBox.size;
    final targetPosition = targetRenderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final resolvedPadding = widget.padding.resolve(TextDirection.ltr);

    final targetCenterPosition = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Determine tooltip position relative to target
    // Simple rule: if target is in top half of screen, show tooltip below; otherwise above
    // autoFlip: true (default) = use screen center logic, ignore direction
    // autoFlip: false = use explicit direction setting
    final bool showTooltipAbove;
    final bool showTooltipLeft;

    if (widget.autoFlip) {
      // Auto position based on screen center
      showTooltipAbove = targetCenterPosition.dy > screenSize.height / 2;
      showTooltipLeft = targetCenterPosition.dx > screenSize.width / 2;
    } else {
      // Use explicit direction or fallback to screen center
      showTooltipAbove = switch (widget.direction) {
        WidgetTooltipDirection.top => true,
        WidgetTooltipDirection.bottom => false,
        _ => targetCenterPosition.dy > screenSize.height / 2,
      };
      showTooltipLeft = switch (widget.direction) {
        WidgetTooltipDirection.left => true,
        WidgetTooltipDirection.right => false,
        _ => targetCenterPosition.dx > screenSize.width / 2,
      };
    }

    final bool showTooltipBelow = !showTooltipAbove;
    final bool showTooltipRight = !showTooltipLeft;

    // Determine anchor alignments based on tooltip position
    final Alignment targetAnchor;
    final Alignment followerAnchor;

    if (widget.axis == Axis.vertical) {
      if (showTooltipAbove) {
        // Tooltip above target: connect target's top to follower's bottom
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
      } else {
        // Tooltip below target: connect target's bottom to follower's top
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
      }
    } else {
      if (showTooltipLeft) {
        // Tooltip left of target: connect target's left to follower's right
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
      } else {
        // Tooltip right of target: connect target's right to follower's left
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
      }
    }

    // Determine triangle direction (points toward the target)
    final AxisDirection? triangleDirection = switch (widget.axis) {
      Axis.vertical when showTooltipAbove => AxisDirection.down,
      Axis.vertical when showTooltipBelow => AxisDirection.up,
      Axis.horizontal when showTooltipLeft => AxisDirection.right,
      Axis.horizontal when showTooltipRight => AxisDirection.left,
      _ => null,
    };

    final Widget triangle = triangleDirection != null
        ? TooltipTriangle(
            direction: triangleDirection,
            color: widget.triangleColor,
            radius: widget.triangleRadius,
          )
        : const SizedBox.shrink();

    // Calculate offsets for tooltip and triangle
    final Offset tooltipOffset;
    final Offset triangleOffset;

    if (widget.axis == Axis.vertical) {
      final gap = widget.targetPadding + widget.triangleSize.height - 1;
      if (showTooltipAbove) {
        // Tooltip above target
        tooltipOffset = Offset(0, -gap);
        triangleOffset = Offset(0, -widget.targetPadding);
      } else {
        // Tooltip below target
        tooltipOffset = Offset(0, gap);
        triangleOffset = Offset(0, widget.targetPadding);
      }
    } else {
      final gap = widget.targetPadding + widget.triangleSize.width - 1;
      if (showTooltipLeft) {
        // Tooltip to the left of target
        tooltipOffset = Offset(-gap, 0);
        triangleOffset = Offset(-widget.targetPadding, 0);
      } else {
        // Tooltip to the right of target
        tooltipOffset = Offset(gap, 0);
        triangleOffset = Offset(widget.targetPadding, 0);
      }
    }

    // Calculate scale alignment based on tooltip position relative to target
    final Alignment scaleAlignment = switch (widget.axis) {
      Axis.vertical when showTooltipAbove => Alignment.bottomCenter,
      Axis.vertical when showTooltipBelow => Alignment.topCenter,
      Axis.horizontal when showTooltipLeft => Alignment.centerRight,
      Axis.horizontal when showTooltipRight => Alignment.centerLeft,
      _ => Alignment.center,
    };

    // Calculate maxWidth for tooltip
    double maxWidth = screenSize.width - resolvedPadding.horizontal;
    if (widget.axis == Axis.horizontal) {
      if (showTooltipLeft) {
        maxWidth = min(
            maxWidth,
            targetPosition.dx -
                widget.targetPadding -
                widget.triangleSize.width -
                resolvedPadding.left);
      } else {
        maxWidth = min(
            maxWidth,
            screenSize.width -
                targetPosition.dx -
                targetSize.width -
                widget.targetPadding -
                widget.triangleSize.width -
                resolvedPadding.right);
      }
    }
    maxWidth = max(100, maxWidth);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        // Get current target position for screen bounds calculation
        final currentTargetRenderBox =
            _targetKey.currentContext?.findRenderObject() as RenderBox?;
        if (currentTargetRenderBox == null ||
            !currentTargetRenderBox.attached) {
          // Target is no longer in the widget tree, dismiss tooltip
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller.dismiss();
          });
          return const SizedBox.shrink();
        }

        final currentTargetPosition =
            currentTargetRenderBox.localToGlobal(Offset.zero);

        // Check if target is visible on screen
        final isTargetVisible = currentTargetPosition.dy > -targetSize.height &&
            currentTargetPosition.dy < screenSize.height &&
            currentTargetPosition.dx > -targetSize.width &&
            currentTargetPosition.dx < screenSize.width;

        if (!isTargetVisible) {
          // Target is off-screen, dismiss tooltip
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller.dismiss();
          });
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
                targetAnchor: targetAnchor,
                followerAnchor: followerAnchor,
                offset: tooltipOffset,
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
                targetAnchor: targetAnchor,
                followerAnchor: followerAnchor,
                offset: triangleOffset,
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

  void _dismiss() async {
    _cancelAutoDismissTimer();
    if (_overlayEntry != null) {
      if (widget.animation != WidgetTooltipAnimation.none) {
        await _animationController.reverse();
      }
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

    final renderBox =
        widget.messageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

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
