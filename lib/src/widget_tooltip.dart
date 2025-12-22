import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_tooltip/src/triangles/down_triangle.dart';
import 'package:widget_tooltip/src/triangles/left_triangle.dart';
import 'package:widget_tooltip/src/triangles/right_triangle.dart';
import 'package:widget_tooltip/src/triangles/upper_triangle.dart';

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

/// Layout delegate for positioning the tooltip
class _TooltipPositionDelegate extends SingleChildLayoutDelegate {
  _TooltipPositionDelegate({
    required this.targetSize,
    required this.targetPosition,
    required this.screenSize,
    required this.padding,
    required this.axis,
    required this.direction,
    required this.triangleSize,
    required this.targetPadding,
    required this.offsetIgnore,
    required this.screenPadding,
  });

  final Size targetSize;
  final Offset targetPosition;
  final Size screenSize;
  final EdgeInsets padding;
  final Axis axis;
  final WidgetTooltipDirection? direction;
  final Size triangleSize;
  final double targetPadding;
  final bool offsetIgnore;
  final EdgeInsets screenPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: screenSize.width - padding.horizontal,
      maxHeight: screenSize.height - padding.vertical,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final targetCenterPosition = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    final bool isLeft = switch (direction) {
      WidgetTooltipDirection.left => false,
      WidgetTooltipDirection.right => true,
      _ => targetCenterPosition.dx <= screenSize.width / 2,
    };

    final bool isRight = switch (direction) {
      WidgetTooltipDirection.left => true,
      WidgetTooltipDirection.right => false,
      _ => targetCenterPosition.dx > screenSize.width / 2,
    };

    final bool isBottom = switch (direction) {
      WidgetTooltipDirection.top => true,
      WidgetTooltipDirection.bottom => false,
      _ => targetCenterPosition.dy > screenSize.height / 2,
    };

    final bool isTop = switch (direction) {
      WidgetTooltipDirection.top => false,
      WidgetTooltipDirection.bottom => true,
      _ => targetCenterPosition.dy <= screenSize.height / 2,
    };

    double x = 0;
    double y = 0;

    if (axis == Axis.vertical) {
      // Center horizontally relative to target
      x = targetPosition.dx + (targetSize.width - childSize.width) / 2;

      // Adjust for screen edges
      final double overflowWidth = (childSize.width - targetSize.width) / 2;
      final edgeFromLeft = targetPosition.dx - overflowWidth;
      final edgeFromRight = screenSize.width -
          (targetPosition.dx + targetSize.width + overflowWidth);
      final edgeFromHorizontal = min(edgeFromLeft, edgeFromRight);

      if (edgeFromHorizontal < padding.horizontal / 2) {
        if (isLeft) {
          x += (padding.horizontal / 2) - edgeFromHorizontal;
        } else if (isRight) {
          x -= (padding.horizontal / 2) - edgeFromHorizontal;
        }
      }

      // Clamp to screen bounds
      x = x.clamp(padding.left, screenSize.width - childSize.width - padding.right);

      if (isTop) {
        // Position below target
        y = targetPosition.dy + targetSize.height + targetPadding + triangleSize.height;
      } else {
        // Position above target
        y = targetPosition.dy - childSize.height - targetPadding - triangleSize.height;
      }
    } else {
      // Axis.horizontal
      // Center vertically relative to target
      y = targetPosition.dy + (targetSize.height - childSize.height) / 2;

      // Adjust for screen edges
      final double overflowHeight = (childSize.height - targetSize.height) / 2;
      final edgeFromTop = targetPosition.dy - overflowHeight;
      final edgeFromBottom = screenSize.height -
          (targetPosition.dy + targetSize.height + overflowHeight);
      final edgeFromVertical = min(edgeFromTop, edgeFromBottom);

      if (edgeFromVertical < padding.vertical / 2) {
        if (isTop) {
          y += screenPadding.top + (padding.vertical / 2) - edgeFromVertical;
        } else if (isBottom) {
          y -= screenPadding.bottom + (padding.vertical / 2) - edgeFromVertical;
        }
      }

      // Clamp to screen bounds
      y = y.clamp(padding.top, screenSize.height - childSize.height - padding.bottom);

      if (isLeft) {
        // Position to the right of target
        x = targetPosition.dx + targetSize.width + targetPadding + triangleSize.width;
      } else {
        // Position to the left of target
        x = targetPosition.dx - childSize.width - targetPadding - triangleSize.width;
      }
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _TooltipPositionDelegate oldDelegate) {
    return targetSize != oldDelegate.targetSize ||
        targetPosition != oldDelegate.targetPosition ||
        screenSize != oldDelegate.screenSize ||
        padding != oldDelegate.padding ||
        axis != oldDelegate.axis ||
        direction != oldDelegate.direction;
  }
}

/// Layout delegate for positioning the triangle
class _TrianglePositionDelegate extends SingleChildLayoutDelegate {
  _TrianglePositionDelegate({
    required this.targetSize,
    required this.targetPosition,
    required this.screenSize,
    required this.axis,
    required this.direction,
    required this.triangleSize,
    required this.targetPadding,
  });

  final Size targetSize;
  final Offset targetPosition;
  final Size screenSize;
  final Axis axis;
  final WidgetTooltipDirection? direction;
  final Size triangleSize;
  final double targetPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tight(triangleSize);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final targetCenterPosition = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    final bool isTop = switch (direction) {
      WidgetTooltipDirection.top => false,
      WidgetTooltipDirection.bottom => true,
      _ => targetCenterPosition.dy <= screenSize.height / 2,
    };

    final bool isLeft = switch (direction) {
      WidgetTooltipDirection.left => false,
      WidgetTooltipDirection.right => true,
      _ => targetCenterPosition.dx <= screenSize.width / 2,
    };

    double x = 0;
    double y = 0;

    if (axis == Axis.vertical) {
      // Center horizontally on target
      x = targetPosition.dx + (targetSize.width - triangleSize.width) / 2;

      if (isTop) {
        // Triangle above the message box (pointing up at target)
        y = targetPosition.dy + targetSize.height + targetPadding;
      } else {
        // Triangle below the message box (pointing down at target)
        y = targetPosition.dy - targetPadding - triangleSize.height;
      }
    } else {
      // Axis.horizontal
      // Center vertically on target
      y = targetPosition.dy + (targetSize.height - triangleSize.height) / 2;

      if (isLeft) {
        // Triangle to the left of message box (pointing left at target)
        x = targetPosition.dx + targetSize.width + targetPadding;
      } else {
        // Triangle to the right of message box (pointing right at target)
        x = targetPosition.dx - targetPadding - triangleSize.width;
      }
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _TrianglePositionDelegate oldDelegate) {
    return targetSize != oldDelegate.targetSize ||
        targetPosition != oldDelegate.targetPosition ||
        screenSize != oldDelegate.screenSize ||
        axis != oldDelegate.axis ||
        direction != oldDelegate.direction;
  }
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

  /// Message
  final Widget message;

  /// Target Widget
  final Widget child;

  /// Triangle color
  final Color triangleColor;

  /// Triangle size
  final Size triangleSize;

  /// Gap between target and tooltip
  final double targetPadding;

  /// Triangle radius
  final double triangleRadius;

  /// Show callback
  final VoidCallback? onShow;

  /// Dismiss callback
  final VoidCallback? onDismiss;

  /// Tooltip Controller
  final TooltipController? controller;

  /// Message Box padding
  final EdgeInsetsGeometry messagePadding;

  /// Message Box decoration
  final BoxDecoration messageDecoration;

  /// Message Box text style
  final TextStyle? messageStyle;

  /// Message Box padding
  final EdgeInsetsGeometry padding;

  /// Axis
  final Axis axis;

  /// Trigger mode
  final WidgetTooltipTriggerMode? triggerMode;

  /// dismiss mode
  final WidgetTooltipDismissMode? dismissMode;

  /// offset ignore
  final bool offsetIgnore;

  /// tooltip direction
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
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: widget.animationDuration);
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

  Widget _buildAnimatedTooltip(Widget child) {
    return switch (widget.animation) {
      WidgetTooltipAnimation.fade => FadeTransition(
          opacity: _animation,
          child: child,
        ),
      WidgetTooltipAnimation.scale => ScaleTransition(
          scale: _animation,
          child: child,
        ),
      WidgetTooltipAnimation.scaleAndFade => FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: child,
          ),
        ),
      WidgetTooltipAnimation.none => child,
    };
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    final screenPadding = MediaQuery.of(context).padding;
    final resolvedPadding = widget.padding.resolve(TextDirection.ltr);

    final targetCenterPosition = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

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

    // Determine triangle widget based on position
    final Widget triangle = switch (widget.axis) {
      Axis.vertical when isTop => UpperTriangle(
          backgroundColor: widget.triangleColor,
          triangleRadius: widget.triangleRadius,
        ),
      Axis.vertical when isBottom => DownTriangle(
          backgroundColor: widget.triangleColor,
          triangleRadius: widget.triangleRadius,
        ),
      Axis.horizontal when isLeft => LeftTriangle(
          backgroundColor: widget.triangleColor,
          triangleRadius: widget.triangleRadius,
        ),
      Axis.horizontal when isRight => RightTriangle(
          backgroundColor: widget.triangleColor,
          triangleRadius: widget.triangleRadius,
        ),
      _ => const SizedBox.shrink(),
    };

    final Widget messageBox = Material(
      type: MaterialType.transparency,
      child: Container(
        padding: widget.messagePadding,
        decoration: widget.messageDecoration,
        child: widget.message,
      ),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _buildAnimatedTooltip(
          TapRegion(
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
                // Message box
                CustomSingleChildLayout(
                  delegate: _TooltipPositionDelegate(
                    targetSize: targetSize,
                    targetPosition: targetPosition,
                    screenSize: screenSize,
                    padding: resolvedPadding,
                    axis: widget.axis,
                    direction: widget.direction,
                    triangleSize: widget.triangleSize,
                    targetPadding: widget.targetPadding,
                    offsetIgnore: widget.offsetIgnore,
                    screenPadding: screenPadding,
                  ),
                  child: messageBox,
                ),
                // Triangle
                CustomSingleChildLayout(
                  delegate: _TrianglePositionDelegate(
                    targetSize: targetSize,
                    targetPosition: targetPosition,
                    screenSize: screenSize,
                    axis: widget.axis,
                    direction: widget.direction,
                    triangleSize: widget.triangleSize,
                    targetPadding: widget.targetPadding,
                  ),
                  child: SizedBox.fromSize(
                    size: widget.triangleSize,
                    child: triangle,
                  ),
                ),
              ],
            ),
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
