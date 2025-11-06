import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_tooltip/src/triangles/down_triangle.dart';
import 'package:widget_tooltip/src/triangles/left_triangle.dart';
import 'package:widget_tooltip/src/triangles/right_triangle.dart';
import 'package:widget_tooltip/src/triangles/upper_triangle.dart';

/// Defines the direction where the tooltip should appear relative to the target widget.
enum WidgetTooltipDirection {
  /// Position tooltip above the target widget.
  top,

  /// Position tooltip below the target widget.
  bottom,

  /// Position tooltip to the left of the target widget.
  left,

  /// Position tooltip to the right of the target widget.
  right,
}

/// Defines how the tooltip is triggered to show.
enum WidgetTooltipTriggerMode {
  /// Show tooltip when the target widget is tapped.
  tap,

  /// Show tooltip when the target widget is long-pressed.
  longPress,

  /// Show tooltip when the target widget is double-tapped.
  doubleTap,

  /// Show tooltip only via controller. No automatic trigger from gestures.
  manual,
}

/// Defines how the tooltip is dismissed after being shown.
enum WidgetTooltipDismissMode {
  /// Dismiss tooltip when tapping outside of the tooltip area.
  tapOutside,

  /// Dismiss tooltip when tapping anywhere on the screen.
  tapAnyWhere,

  /// Dismiss tooltip when tapping inside the tooltip area.
  tapInside,

  /// Dismiss tooltip only via controller. No automatic dismiss from gestures.
  manual,
}

/// A controller for managing the visibility state of a tooltip.
///
/// Use this controller to programmatically show, hide, or toggle the tooltip
/// when [WidgetTooltip.triggerMode] or [WidgetTooltip.dismissMode] is set to
/// [WidgetTooltipTriggerMode.manual] or [WidgetTooltipDismissMode.manual].
///
/// Example:
/// ```dart
/// final controller = TooltipController();
///
/// WidgetTooltip(
///   controller: controller,
///   triggerMode: WidgetTooltipTriggerMode.manual,
///   message: Text('Hello'),
///   child: IconButton(
///     icon: Icon(Icons.info),
///     onPressed: controller.show,
///   ),
/// )
/// ```
class TooltipController extends ChangeNotifier {
  bool _isShow = false;

  /// Returns `true` if the tooltip is currently visible.
  bool get isShow => _isShow;

  /// Shows the tooltip if it's currently hidden.
  void show() {
    _isShow = true;
    notifyListeners();
  }

  /// Hides the tooltip if it's currently visible.
  ///
  /// The optional [event] parameter is provided for compatibility with
  /// gesture callbacks but is not used.
  void dismiss([PointerDownEvent? event]) {
    _isShow = false;
    notifyListeners();
  }

  /// Toggles the tooltip visibility.
  ///
  /// If the tooltip is currently shown, it will be dismissed.
  /// If the tooltip is currently hidden, it will be shown.
  void toggle() => _isShow ? dismiss() : show();
}

/// A highly customizable tooltip widget for Flutter.
///
/// [WidgetTooltip] provides a rich tooltip experience with configurable
/// trigger modes, dismiss behaviors, positioning, and styling options.
///
/// Example:
/// ```dart
/// WidgetTooltip(
///   message: Text('This is a tooltip'),
///   child: Icon(Icons.info),
///   triggerMode: WidgetTooltipTriggerMode.tap,
///   direction: WidgetTooltipDirection.top,
/// )
/// ```
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
  });

  /// The widget to display inside the tooltip.
  ///
  /// This can be any Flutter widget, not just text.
  final Widget message;

  /// The target widget that triggers the tooltip.
  final Widget child;

  /// The color of the tooltip's pointer triangle.
  final Color triangleColor;

  /// The size of the tooltip's pointer triangle.
  final Size triangleSize;

  /// The gap between the target widget and the tooltip.
  final double targetPadding;

  /// The radius of the rounded corners on the triangle's tip.
  final double triangleRadius;

  /// Callback invoked when the tooltip is shown.
  final VoidCallback? onShow;

  /// Callback invoked when the tooltip is dismissed.
  final VoidCallback? onDismiss;

  /// Optional controller for programmatic tooltip management.
  ///
  /// If provided, use this to show/hide the tooltip programmatically.
  final TooltipController? controller;

  /// Padding inside the tooltip message container.
  final EdgeInsetsGeometry messagePadding;

  /// Decoration for the tooltip message container.
  ///
  /// Use this to customize background color, border radius, shadows, etc.
  final BoxDecoration messageDecoration;

  /// Text style applied to text widgets inside the message.
  ///
  /// This is a convenience property and only affects [Text] widgets.
  final TextStyle? messageStyle;

  /// Padding around the screen edges to prevent tooltip overflow.
  ///
  /// The tooltip will stay within these bounds.
  final EdgeInsetsGeometry padding;

  /// The axis along which to position the tooltip.
  ///
  /// - [Axis.vertical]: Tooltip appears above or below the target.
  /// - [Axis.horizontal]: Tooltip appears left or right of the target.
  final Axis axis;

  /// How the tooltip is triggered to show.
  ///
  /// Defaults to [WidgetTooltipTriggerMode.longPress] when no controller is provided.
  /// When a controller is provided, defaults to [WidgetTooltipTriggerMode.manual].
  final WidgetTooltipTriggerMode? triggerMode;

  /// How the tooltip is dismissed after being shown.
  ///
  /// Defaults to [WidgetTooltipDismissMode.tapAnyWhere] when no controller is provided.
  /// When a controller is provided, defaults to [WidgetTooltipDismissMode.manual].
  final WidgetTooltipDismissMode? dismissMode;

  /// Whether to ignore automatic offset adjustment for edge detection.
  ///
  /// When `false` (default), the tooltip automatically adjusts its position
  /// to stay within screen bounds. When `true`, the tooltip uses fixed positioning.
  final bool offsetIgnore;

  /// The preferred direction to display the tooltip.
  ///
  /// When `null`, the direction is automatically determined based on available space.
  /// When specified, the tooltip will always appear in this direction.
  final WidgetTooltipDirection? direction;

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

  final key = GlobalKey();
  final messageBoxKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _controller = widget.controller ?? TooltipController();
    _controller.addListener(listener);

    initProperties();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant WidgetTooltip oldWidget) {
    initProperties();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    dismiss();
    _controller.removeListener(listener);
    if (widget.controller == null) {
      _controller.dispose();
    }

    _overlayEntry?.remove();
    _animationController.dispose();

    super.dispose();
  }

  void listener() {
    if (_controller.isShow == true) {
      show();
    } else {
      dismiss();
    }
  }

  void initProperties() {
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
        child: SizedBox(key: key, child: widget.child),
      ),
    );
  }

  void show() {
    if (_animationController.isAnimating) return;

    final Widget messageBox = Material(
      type: MaterialType.transparency,
      child: Container(
        key: messageBoxKey,
        padding: widget.messagePadding,
        decoration: widget.messageDecoration,
        child: widget.message,
      ),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            FadeTransition(
              opacity: _animation,
              child: messageBox,
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageBoxRenderBox =
          messageBoxKey.currentContext?.findRenderObject() as RenderBox?;
      final messageBoxSize = messageBoxRenderBox?.size;

      _overlayEntry?.remove();
      _overlayEntry = null;

      if (messageBoxSize == null) return;

      final builder = _builder(messageBoxSize);
      if (builder == null) return;

      final Widget triangle = switch (builder.targetAnchor) {
        Alignment.bottomCenter => UpperTriangle(
            backgroundColor: widget.triangleColor,
            triangleRadius: widget.triangleRadius,
          ),
        Alignment.topCenter => DownTriangle(
            backgroundColor: widget.triangleColor,
            triangleRadius: widget.triangleRadius,
          ),
        Alignment.centerLeft => RightTriangle(
            backgroundColor: widget.triangleColor,
            triangleRadius: widget.triangleRadius,
          ),
        Alignment.centerRight => LeftTriangle(
            backgroundColor: widget.triangleColor,
            triangleRadius: widget.triangleRadius,
          ),
        _ => const SizedBox.shrink(),
      };

      final Offset triangleOffset = switch (builder.targetAnchor) {
        Alignment.bottomCenter => Offset(0, widget.targetPadding),
        Alignment.topCenter => Offset(0, -(widget.targetPadding)),
        Alignment.centerLeft => Offset(-(widget.targetPadding), 0),
        Alignment.centerRight => Offset(widget.targetPadding, 0),
        _ => Offset.zero,
      };

      final Offset messageBoxOffset = switch (builder.targetAnchor) {
        Alignment.bottomCenter when widget.offsetIgnore =>
          Offset(0, widget.triangleSize.height + (widget.targetPadding) - 1),
        Alignment.topCenter when widget.offsetIgnore =>
          Offset(0, -widget.triangleSize.height - (widget.targetPadding) + 1),
        Alignment.centerLeft when widget.offsetIgnore =>
          Offset(-(widget.targetPadding) - widget.triangleSize.width + 1, 0),
        Alignment.centerRight when widget.offsetIgnore =>
          Offset((widget.targetPadding) + widget.triangleSize.width - 1, 0),
        Alignment.bottomCenter => Offset(builder.offset.dx,
            widget.triangleSize.height + (widget.targetPadding) - 1),
        Alignment.topCenter => Offset(builder.offset.dx,
            -widget.triangleSize.height - (widget.targetPadding) + 1),
        Alignment.centerLeft => Offset(
            -(widget.targetPadding) - widget.triangleSize.width + 1,
            builder.offset.dy),
        Alignment.centerRight => Offset(
            (widget.targetPadding) + widget.triangleSize.width - 1,
            builder.offset.dy),
        _ => Offset.zero,
      };

      _overlayEntry = OverlayEntry(
        builder: (context) {
          return FadeTransition(
            opacity: _animation,
            child: TapRegion(
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
                  const SizedBox.expand(),
                  CompositedTransformFollower(
                    link: _layerLink,
                    targetAnchor: builder.targetAnchor,
                    followerAnchor: builder.followerAnchor,
                    offset: messageBoxOffset,
                    child: messageBox,
                  ),
                  CompositedTransformFollower(
                    link: _layerLink,
                    targetAnchor: builder.targetAnchor,
                    followerAnchor: builder.followerAnchor,
                    offset: triangleOffset,
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

      _animationController.forward();
    });

    widget.onShow?.call();
  }

  void dismiss() async {
    if (_overlayEntry != null) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
      widget.onDismiss?.call();
    }
  }

  ({Alignment targetAnchor, Alignment followerAnchor, Offset offset})? _builder(
      Size messageBoxSize) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      debugPrint('WidgetTooltip: RenderBox is null, cannot calculate position');
      return null;
    }

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetCenterPosition = Offset(
        targetPosition.dx + targetSize.width / 2,
        targetPosition.dy + targetSize.height / 2);

    final bool isLeft = switch (widget.direction) {
      WidgetTooltipDirection.left => false,
      WidgetTooltipDirection.right => true,
      _ => targetCenterPosition.dx <= MediaQuery.of(context).size.width / 2,
    };

    final bool isRight = switch (widget.direction) {
      WidgetTooltipDirection.left => true,
      WidgetTooltipDirection.right => false,
      _ => targetCenterPosition.dx > MediaQuery.of(context).size.width / 2,
    };

    final bool isBottom = switch (widget.direction) {
      WidgetTooltipDirection.top => true,
      WidgetTooltipDirection.bottom => false,
      _ => targetCenterPosition.dy > MediaQuery.of(context).size.height / 2,
    };

    final bool isTop = switch (widget.direction) {
      WidgetTooltipDirection.top => false,
      WidgetTooltipDirection.bottom => true,
      _ => targetCenterPosition.dy <= MediaQuery.of(context).size.height / 2,
    };

    Alignment targetAnchor = switch (widget.axis) {
      Axis.horizontal when isRight => Alignment.centerLeft,
      Axis.horizontal when isLeft => Alignment.centerRight,
      Axis.vertical when isTop => Alignment.bottomCenter,
      Axis.vertical when isBottom => Alignment.topCenter,
      _ => Alignment.center,
    };

    Alignment followerAnchor = switch (widget.axis) {
      Axis.horizontal when isRight => Alignment.centerRight,
      Axis.horizontal when isLeft => Alignment.centerLeft,
      Axis.vertical when isTop => Alignment.topCenter,
      Axis.vertical when isBottom => Alignment.bottomCenter,
      _ => Alignment.center,
    };
    final double overflowWidth = (messageBoxSize.width - targetSize.width) / 2;

    final edgeFromLeft = targetPosition.dx - overflowWidth;
    final edgeFromRight = MediaQuery.of(context).size.width -
        (targetPosition.dx + targetSize.width + overflowWidth);
    final edgeFromHorizontal = min(edgeFromLeft, edgeFromRight);

    double dx = 0;

    if (edgeFromHorizontal < widget.padding.horizontal / 2) {
      if (isLeft) {
        dx = (widget.padding.horizontal / 2) - edgeFromHorizontal;
      } else if (isRight) {
        dx = -(widget.padding.horizontal / 2) + edgeFromHorizontal;
      }
    }

    final double overflowHeight =
        (messageBoxSize.height - targetSize.height) / 2;

    final edgeFromTop = targetPosition.dy - overflowHeight;
    final edgeFromBottom = MediaQuery.of(context).size.height -
        (targetPosition.dy + targetSize.height + overflowHeight);
    final edgeFromVertical = min(edgeFromTop, edgeFromBottom);

    double dy = 0;

    if (edgeFromVertical < widget.padding.vertical / 2) {
      if (isTop) {
        dy = MediaQuery.of(context).padding.top +
            (widget.padding.vertical / 2) -
            edgeFromVertical;
      } else if (isBottom) {
        dy = MediaQuery.of(context).padding.bottom -
            (widget.padding.vertical / 2) +
            edgeFromVertical;
      }
    }

    return (
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: Offset(dx, dy),
    );
  }
}
