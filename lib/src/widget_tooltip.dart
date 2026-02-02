import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'enums.dart';
import 'tooltip_animation_builder.dart';
import 'tooltip_controller.dart';
import 'triangles/tooltip_triangle.dart';

export 'enums.dart';
export 'tooltip_controller.dart';

/// A highly customizable tooltip widget that displays a message when triggered.
///
/// Uses a two-phase positioning approach (from v1.1.4):
/// 1. Renders the tooltip invisibly to measure its actual size
/// 2. Uses the measured size to calculate overflow-adjusted offsets
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

  final Widget message;
  final Widget child;
  final Color triangleColor;
  final Size triangleSize;
  final double targetPadding;
  final double triangleRadius;
  final VoidCallback? onShow;
  final VoidCallback? onDismiss;
  final TooltipController? controller;
  final EdgeInsetsGeometry messagePadding;
  final BoxDecoration messageDecoration;
  final EdgeInsetsGeometry padding;
  final Axis axis;
  final WidgetTooltipTriggerMode? triggerMode;
  final WidgetTooltipDismissMode? dismissMode;
  final bool offsetIgnore;
  final WidgetTooltipDirection? direction;
  final WidgetTooltipAnimation animation;
  final Duration? autoDismissDuration;
  final Duration animationDuration;
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
  final _messageBoxKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _controller = widget.controller ?? TooltipController();
    _controller.addListener(_listener);

    _initProperties();
  }

  @override
  void didUpdateWidget(covariant WidgetTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initProperties();
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
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
    if (_controller.isShow) {
      _show();
    } else {
      _dismiss();
    }
  }

  void _initProperties() {
    _triggerMode = widget.controller == null
        ? widget.triggerMode ?? WidgetTooltipTriggerMode.longPress
        : widget.triggerMode;

    _dismissMode = widget.controller == null
        ? widget.dismissMode ?? WidgetTooltipDismissMode.tapAnywhere
        : widget.dismissMode;
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

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(key: _targetKey, child: widget.child);

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
        onTap: _triggerMode == WidgetTooltipTriggerMode.tap
            ? _controller.toggle
            : null,
        onLongPress: _triggerMode == WidgetTooltipTriggerMode.longPress
            ? _controller.toggle
            : null,
        onDoubleTap: _triggerMode == WidgetTooltipTriggerMode.doubleTap
            ? _controller.toggle
            : null,
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Show / Dismiss — v1.1.4 two-phase approach
  // ---------------------------------------------------------------------------

  void _show() {
    if (_animationController.isAnimating) return;
    if (_overlayEntry != null) return;

    final resolvedPadding = widget.padding.resolve(TextDirection.ltr);
    final horizontalPadding = resolvedPadding.left + resolvedPadding.right;

    final Widget messageBox = Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - horizontalPadding,
        ),
        child: Container(
          key: _messageBoxKey,
          padding: widget.messagePadding,
          decoration: widget.messageDecoration,
          child: widget.message,
        ),
      ),
    );

    // Phase 1: Insert invisible overlay to measure message box size.
    // Wrap in Stack to get loose constraints (same as the final overlay),
    // so the messageBox takes its intrinsic size rather than expanding.
    _overlayEntry = OverlayEntry(
      builder: (_) {
        return IgnorePointer(
          child: Opacity(
            opacity: 0,
            child: Stack(children: [messageBox]),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Phase 2: Measure → calculate position → build final overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageBoxRenderBox =
          _messageBoxKey.currentContext?.findRenderObject() as RenderBox?;
      final messageBoxSize = messageBoxRenderBox?.size;

      _overlayEntry?.remove();
      _overlayEntry = null;

      if (messageBoxSize == null) return;

      final layout = _calculateLayout(messageBoxSize);
      if (layout == null) return;

      final animationBuilder = TooltipAnimationBuilder(
        animation: widget.animation,
        animationValue: _animation,
      );

      final triangleDirection = switch (layout.targetAnchor) {
        Alignment.bottomCenter => AxisDirection.up,
        Alignment.topCenter => AxisDirection.down,
        Alignment.centerLeft => AxisDirection.right,
        Alignment.centerRight => AxisDirection.left,
        _ => AxisDirection.down,
      };

      final Widget triangle = SizedBox.fromSize(
        size: widget.triangleSize,
        child: TooltipTriangle(
          direction: triangleDirection,
          color: widget.triangleColor,
          radius: widget.triangleRadius,
        ),
      );

      _overlayEntry = OverlayEntry(
        builder: (_) {
          return animationBuilder.build(
            scaleAlignment: _scaleAlignment(layout.targetAnchor),
            child: TapRegion(
              onTapInside:
                  _shouldDismissOnTapInside() ? _controller.dismiss : null,
              onTapOutside:
                  _shouldDismissOnTapOutside() ? _controller.dismiss : null,
              child: Stack(
                children: [
                  const SizedBox.expand(),
                  CompositedTransformFollower(
                    link: _layerLink,
                    targetAnchor: layout.targetAnchor,
                    followerAnchor: layout.followerAnchor,
                    offset: layout.messageBoxOffset,
                    child: messageBox,
                  ),
                  CompositedTransformFollower(
                    link: _layerLink,
                    targetAnchor: layout.targetAnchor,
                    followerAnchor: layout.followerAnchor,
                    offset: layout.triangleOffset,
                    child: triangle,
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
    });

    _startAutoDismissTimer();
    widget.onShow?.call();
  }

  Future<void> _dismiss() async {
    _cancelAutoDismissTimer();
    if (_overlayEntry == null) return;

    try {
      if (widget.animation != WidgetTooltipAnimation.none) {
        await _animationController.reverse();
      }
    } catch (_) {
      // May fail if disposed during animation
    } finally {
      try {
        _overlayEntry?.remove();
      } catch (_) {
        // Overlay may already be removed
      }
      _overlayEntry = null;
      widget.onDismiss?.call();
    }
  }

  // ---------------------------------------------------------------------------
  // Layout calculation — v1.1.4 logic, unchanged
  // ---------------------------------------------------------------------------

  ({
    Alignment targetAnchor,
    Alignment followerAnchor,
    Offset messageBoxOffset,
    Offset triangleOffset,
  })? _calculateLayout(Size messageBoxSize) {
    final renderBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Direction flags — v1.1.4 logic: direction always takes precedence
    final bool isLeft = switch (widget.direction) {
      WidgetTooltipDirection.left => false,
      WidgetTooltipDirection.right => true,
      _ => targetCenter.dx <= MediaQuery.of(context).size.width / 2,
    };

    final bool isRight = switch (widget.direction) {
      WidgetTooltipDirection.left => true,
      WidgetTooltipDirection.right => false,
      _ => targetCenter.dx > MediaQuery.of(context).size.width / 2,
    };

    final bool isBottom = switch (widget.direction) {
      WidgetTooltipDirection.top => true,
      WidgetTooltipDirection.bottom => false,
      _ => targetCenter.dy > MediaQuery.of(context).size.height / 2,
    };

    final bool isTop = switch (widget.direction) {
      WidgetTooltipDirection.top => false,
      WidgetTooltipDirection.bottom => true,
      _ => targetCenter.dy <= MediaQuery.of(context).size.height / 2,
    };

    // Anchors
    final Alignment targetAnchor = switch (widget.axis) {
      Axis.horizontal when isRight => Alignment.centerLeft,
      Axis.horizontal when isLeft => Alignment.centerRight,
      Axis.vertical when isTop => Alignment.bottomCenter,
      Axis.vertical when isBottom => Alignment.topCenter,
      _ => Alignment.center,
    };

    final Alignment followerAnchor = switch (widget.axis) {
      Axis.horizontal when isRight => Alignment.centerRight,
      Axis.horizontal when isLeft => Alignment.centerLeft,
      Axis.vertical when isTop => Alignment.topCenter,
      Axis.vertical when isBottom => Alignment.bottomCenter,
      _ => Alignment.center,
    };

    // Overflow-adjusted offsets — v1.1.4 logic
    final double overflowWidth =
        (messageBoxSize.width - targetSize.width) / 2;
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

    // Triangle offset
    final Offset triangleOffset = switch (targetAnchor) {
      Alignment.bottomCenter => Offset(0, widget.targetPadding),
      Alignment.topCenter => Offset(0, -widget.targetPadding),
      Alignment.centerLeft => Offset(-widget.targetPadding, 0),
      Alignment.centerRight => Offset(widget.targetPadding, 0),
      _ => Offset.zero,
    };

    // Message box offset (includes triangle size + overflow adjustment)
    final Offset messageBoxOffset = switch (targetAnchor) {
      Alignment.bottomCenter when widget.offsetIgnore =>
        Offset(0, widget.triangleSize.height + widget.targetPadding - 1),
      Alignment.topCenter when widget.offsetIgnore =>
        Offset(0, -widget.triangleSize.height - widget.targetPadding + 1),
      Alignment.centerLeft when widget.offsetIgnore =>
        Offset(-widget.targetPadding - widget.triangleSize.width + 1, 0),
      Alignment.centerRight when widget.offsetIgnore =>
        Offset(widget.targetPadding + widget.triangleSize.width - 1, 0),
      Alignment.bottomCenter =>
        Offset(dx, widget.triangleSize.height + widget.targetPadding - 1),
      Alignment.topCenter =>
        Offset(dx, -widget.triangleSize.height - widget.targetPadding + 1),
      Alignment.centerLeft =>
        Offset(-widget.targetPadding - widget.triangleSize.width + 1, dy),
      Alignment.centerRight =>
        Offset(widget.targetPadding + widget.triangleSize.width - 1, dy),
      _ => Offset.zero,
    };

    return (
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      messageBoxOffset: messageBoxOffset,
      triangleOffset: triangleOffset,
    );
  }

  Alignment _scaleAlignment(Alignment targetAnchor) {
    return switch (targetAnchor) {
      Alignment.topCenter => Alignment.bottomCenter,
      Alignment.bottomCenter => Alignment.topCenter,
      Alignment.centerLeft => Alignment.centerRight,
      Alignment.centerRight => Alignment.centerLeft,
      _ => Alignment.center,
    };
  }

  bool _shouldDismissOnTapInside() {
    return _dismissMode == WidgetTooltipDismissMode.tapInside ||
        _dismissMode == WidgetTooltipDismissMode.tapAnywhere ||
        // ignore: deprecated_member_use_from_same_package
        _dismissMode == WidgetTooltipDismissMode.tapAnyWhere;
  }

  bool _shouldDismissOnTapOutside() {
    return _dismissMode == WidgetTooltipDismissMode.tapOutside ||
        _dismissMode == WidgetTooltipDismissMode.tapAnywhere ||
        // ignore: deprecated_member_use_from_same_package
        _dismissMode == WidgetTooltipDismissMode.tapAnyWhere;
  }
}
