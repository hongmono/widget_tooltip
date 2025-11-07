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

    final resolvedPadding = widget.padding.resolve(TextDirection.ltr);
    final horizontalPadding = resolvedPadding.left + resolvedPadding.right;

    final Widget messageBox = Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - horizontalPadding,
        ),
        child: Container(
          key: messageBoxKey,
          padding: widget.messagePadding,
          decoration: widget.messageDecoration,
          child: widget.message,
        ),
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
      Exception('RenderBox is null');
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
