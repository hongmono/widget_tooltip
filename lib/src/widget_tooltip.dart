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

  /// Show tooltip only controller
  manual,
}

enum WidgetTooltipDismissMode {
  /// Dismiss when tap outside of tooltip
  tapOutside,

  /// Dismiss when tap anywhere
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

class TooltipController extends ChangeNotifier {
  bool _isShow = false;

  bool get isShow => _isShow;

  void show() {
    _isShow = true;
    notifyListeners();
  }

  void dismiss([PointerDownEvent? event]) {
    _isShow = false;
    notifyListeners();
  }

  void toggle() => _isShow ? dismiss() : show();
}

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
    this.messageStyle = const TextStyle(color: Colors.white, fontSize: 14),
    this.padding = const EdgeInsets.all(16),
    this.axis = Axis.vertical,
    this.triggerMode,
    this.dismissMode,
    this.offsetIgnore = false,
    this.direction,
    this.animation = WidgetTooltipAnimation.fade,
    this.autoDismissDuration,
    this.animationDuration = const Duration(milliseconds: 300),
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

  /// Text style for the message (used when message is Text widget)
  final TextStyle? messageStyle;

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
      null => widget.dismissMode ?? WidgetTooltipDismissMode.tapAnyWhere,
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
        child: SizedBox(key: _targetKey, child: widget.child),
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

    // Determine position flags based on direction or screen position
    final bool isBottom = switch (widget.direction) {
      WidgetTooltipDirection.top => true,
      WidgetTooltipDirection.bottom => false,
      _ => targetCenterPosition.dy > screenSize.height / 2,
    };

    final bool isTop = switch (widget.direction) {
      WidgetTooltipDirection.top => false,
      WidgetTooltipDirection.bottom => true,
      _ => targetCenterPosition.dy <= screenSize.height / 2,
    };

    final bool isLeft = switch (widget.direction) {
      WidgetTooltipDirection.left => false,
      WidgetTooltipDirection.right => true,
      _ => targetCenterPosition.dx <= screenSize.width / 2,
    };

    final bool isRight = switch (widget.direction) {
      WidgetTooltipDirection.left => true,
      WidgetTooltipDirection.right => false,
      _ => targetCenterPosition.dx > screenSize.width / 2,
    };

    // Determine anchor alignments based on position
    final Alignment targetAnchor;
    final Alignment followerAnchor;

    if (widget.axis == Axis.vertical) {
      if (isTop) {
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
      } else {
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
      }
    } else {
      if (isLeft) {
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
      } else {
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
      }
    }

    // Determine triangle direction based on position
    final AxisDirection? triangleDirection = switch (widget.axis) {
      Axis.vertical when isTop => AxisDirection.up,
      Axis.vertical when isBottom => AxisDirection.down,
      Axis.horizontal when isLeft => AxisDirection.left,
      Axis.horizontal when isRight => AxisDirection.right,
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
      if (isTop) {
        // Tooltip below target
        tooltipOffset = Offset(0, gap);
        triangleOffset = Offset(0, widget.targetPadding);
      } else {
        // Tooltip above target
        tooltipOffset = Offset(0, -gap);
        triangleOffset = Offset(
            0, -widget.targetPadding); // NOT including triangleSize.height
      }
    } else {
      final gap = widget.targetPadding + widget.triangleSize.width - 1;
      if (isLeft) {
        // Tooltip to the right of target
        tooltipOffset = Offset(gap, 0);
        triangleOffset = Offset(widget.targetPadding, 0);
      } else {
        // Tooltip to the left of target
        tooltipOffset = Offset(-gap, 0);
        triangleOffset = Offset(
            -widget.targetPadding, 0); // NOT including triangleSize.width
      }
    }

    // Calculate scale alignment based on tooltip position relative to target
    final Alignment scaleAlignment = switch (widget.axis) {
      Axis.vertical when isTop => Alignment.topCenter,
      Axis.vertical when isBottom => Alignment.bottomCenter,
      Axis.horizontal when isLeft => Alignment.centerLeft,
      Axis.horizontal when isRight => Alignment.centerRight,
      _ => Alignment.center,
    };

    // Calculate maxWidth for tooltip
    double maxWidth = screenSize.width - resolvedPadding.horizontal;
    if (widget.axis == Axis.horizontal) {
      if (isLeft) {
        maxWidth = min(
            maxWidth,
            screenSize.width -
                targetPosition.dx -
                targetSize.width -
                widget.targetPadding -
                widget.triangleSize.width -
                resolvedPadding.right);
      } else {
        maxWidth = min(
            maxWidth,
            targetPosition.dx -
                widget.targetPadding -
                widget.triangleSize.width -
                resolvedPadding.left);
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
          return const SizedBox.shrink();
        }

        final currentTargetPosition =
            currentTargetRenderBox.localToGlobal(Offset.zero);
        final currentTargetCenter =
            currentTargetPosition.dx + targetSize.width / 2;

        return TapRegion(
          onTapInside: switch (_dismissMode) {
            WidgetTooltipDismissMode.tapInside => _controller.dismiss,
            WidgetTooltipDismissMode.tapAnyWhere => _controller.dismiss,
            _ => null,
          },
          onTapOutside: switch (_dismissMode) {
            WidgetTooltipDismissMode.tapOutside => _controller.dismiss,
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
                        isLeft: isLeft,
                        isRight: isRight,
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
    required this.isLeft,
    required this.isRight,
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
  final bool isLeft;
  final bool isRight;
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
