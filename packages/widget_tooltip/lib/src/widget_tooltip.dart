import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

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
    this.dismissOnScroll = true,
    this.semanticLabel,
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

  /// Whether to automatically dismiss the tooltip when the nearest
  /// [Scrollable] ancestor scrolls.
  ///
  /// Defaults to `true`.
  final bool dismissOnScroll;

  /// An optional semantic label for the tooltip content.
  ///
  /// When provided, the tooltip overlay is wrapped in a [Semantics] widget
  /// and [SemanticsService.announce] is called when the tooltip appears,
  /// making the tooltip accessible to screen readers.
  final String? semanticLabel;

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

  ScrollPosition? _scrollPosition;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeScrollListener();
    if (widget.dismissOnScroll) {
      _scrollPosition = Scrollable.maybeOf(context)?.position;
      _scrollPosition?.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(covariant WidgetTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initProperties();
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
    if (oldWidget.dismissOnScroll != widget.dismissOnScroll) {
      _removeScrollListener();
      if (widget.dismissOnScroll) {
        _scrollPosition = Scrollable.maybeOf(context)?.position;
        _scrollPosition?.addListener(_onScroll);
      }
    }
  }

  @override
  void dispose() {
    _cancelAutoDismissTimer();
    _removeOverlay();
    _removeScrollListener();
    _controller.removeListener(_listener);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _removeScrollListener() {
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;
  }

  void _onScroll() {
    if (_overlayEntry != null) {
      _controller.dismiss();
    }
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

    // Wrap child with Semantics hints based on trigger mode
    if (widget.semanticLabel != null) {
      child = Semantics(
        label: widget.semanticLabel,
        hint: _triggerMode == WidgetTooltipTriggerMode.longPress
            ? 'Long press to show tooltip'
            : _triggerMode == WidgetTooltipTriggerMode.tap
                ? 'Double tap to show tooltip'
                : _triggerMode == WidgetTooltipTriggerMode.doubleTap
                    ? 'Double tap to show tooltip'
                    : null,
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
  // Show / Dismiss
  // ---------------------------------------------------------------------------

  void _show() {
    if (_animationController.isAnimating) return;
    if (_overlayEntry != null) return;

    final resolvedPadding = widget.padding.resolve(Directionality.of(context));
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
      if (!mounted) return;

      final messageBoxRenderBox =
          _messageBoxKey.currentContext?.findRenderObject() as RenderBox?;
      final messageBoxSize = messageBoxRenderBox?.size;

      _overlayEntry?.remove();
      _overlayEntry = null;

      if (messageBoxSize == null) return;

      final textDirection = Directionality.of(context);
      final layout = _calculateLayout(messageBoxSize, textDirection);
      if (layout == null) return;

      _insertFinalOverlay(
        messageBox: messageBox,
        messageBoxSize: messageBoxSize,
        layout: layout,
      );

      if (widget.animation != WidgetTooltipAnimation.none) {
        _animationController.forward();
      } else {
        _animationController.value = 1.0;
      }

      // Announce tooltip content for screen readers
      if (widget.semanticLabel != null) {
        SemanticsService.announce(
          widget.semanticLabel!,
          TextDirection.ltr,
        );
      }
    });

    _startAutoDismissTimer();
    widget.onShow?.call();
  }

  void _insertFinalOverlay({
    required Widget messageBox,
    required Size messageBoxSize,
    required _TooltipLayout layout,
  }) {
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

    final ts = widget.triangleSize;
    final combined = _buildCombinedTooltip(
      messageBox: messageBox,
      messageBoxSize: messageBoxSize,
      triangle: triangle,
      triangleSize: ts,
      layout: layout,
    );

    final scaleAlignment = _scaleAlignment(layout.targetAnchor);

    _overlayEntry = OverlayEntry(
      builder: (_) {
        return TapRegion(
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
                offset: combined.offset,
                child: animationBuilder.build(
                  scaleAlignment: scaleAlignment,
                  child: widget.semanticLabel != null
                      ? Semantics(
                          liveRegion: true,
                          label: widget.semanticLabel,
                          child: combined.widget,
                        )
                      : combined.widget,
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  ({Widget widget, Offset offset}) _buildCombinedTooltip({
    required Widget messageBox,
    required Size messageBoxSize,
    required Widget triangle,
    required Size triangleSize,
    required _TooltipLayout layout,
  }) {
    final dx = layout.dx;
    final dy = layout.dy;
    final ts = triangleSize;

    return switch (layout.targetAnchor) {
      Alignment.bottomCenter => (
          widget: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(top: ts.height - 1),
                child: messageBox,
              ),
              Positioned(
                top: 0,
                left: messageBoxSize.width / 2 - dx - ts.width / 2,
                child: triangle,
              ),
            ],
          ),
          offset: Offset(dx, widget.targetPadding),
        ),
      Alignment.topCenter => (
          widget: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: ts.height - 1),
                child: messageBox,
              ),
              Positioned(
                bottom: 0,
                left: messageBoxSize.width / 2 - dx - ts.width / 2,
                child: triangle,
              ),
            ],
          ),
          offset: Offset(dx, -widget.targetPadding),
        ),
      Alignment.centerRight => (
          widget: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(left: ts.width - 1),
                child: messageBox,
              ),
              Positioned(
                left: 0,
                top: messageBoxSize.height / 2 - dy - ts.height / 2,
                child: triangle,
              ),
            ],
          ),
          offset: Offset(widget.targetPadding, dy),
        ),
      Alignment.centerLeft => (
          widget: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(right: ts.width - 1),
                child: messageBox,
              ),
              Positioned(
                right: 0,
                top: messageBoxSize.height / 2 - dy - ts.height / 2,
                child: triangle,
              ),
            ],
          ),
          offset: Offset(-widget.targetPadding, dy),
        ),
      _ => (widget: messageBox, offset: Offset.zero),
    };
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
      _removeOverlay();
      widget.onDismiss?.call();
    }
  }

  /// Removes the overlay entry without animation. Safe to call multiple times.
  void _removeOverlay() {
    try {
      _overlayEntry?.remove();
    } catch (_) {
      // Overlay may already be removed
    }
    _overlayEntry = null;
  }

  // ---------------------------------------------------------------------------
  // Layout calculation
  // ---------------------------------------------------------------------------

  _TooltipLayout? _calculateLayout(
      Size messageBoxSize, TextDirection textDirection) {
    final renderBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    final anchors = _resolveAnchors(targetPosition, targetSize, textDirection);
    final offsets = _resolveOffsets(
      messageBoxSize: messageBoxSize,
      targetSize: targetSize,
      targetPosition: targetPosition,
      isTop: anchors.isTop,
      isBottom: anchors.isBottom,
      isLeft: anchors.isLeft,
      isRight: anchors.isRight,
    );

    return _TooltipLayout(
      targetAnchor: anchors.targetAnchor,
      followerAnchor: anchors.followerAnchor,
      dx: widget.offsetIgnore ? 0.0 : offsets.dx,
      dy: widget.offsetIgnore ? 0.0 : offsets.dy,
    );
  }

  ({
    Alignment targetAnchor,
    Alignment followerAnchor,
    bool isTop,
    bool isBottom,
    bool isLeft,
    bool isRight,
  }) _resolveAnchors(
    Offset targetPosition,
    Size targetSize,
    TextDirection textDirection,
  ) {
    final targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isRtl = textDirection == TextDirection.rtl;
    final bool inLeftHalf = targetCenter.dx <= screenWidth / 2;

    final bool isLeft = switch (widget.direction) {
      WidgetTooltipDirection.left => false,
      WidgetTooltipDirection.right => true,
      _ => widget.autoFlip ? (isRtl ? !inLeftHalf : inLeftHalf) : true,
    };

    final bool isRight = switch (widget.direction) {
      WidgetTooltipDirection.left => true,
      WidgetTooltipDirection.right => false,
      _ => widget.autoFlip ? (isRtl ? inLeftHalf : !inLeftHalf) : false,
    };

    final bool isBottom = switch (widget.direction) {
      WidgetTooltipDirection.top => true,
      WidgetTooltipDirection.bottom => false,
      _ => widget.autoFlip ? targetCenter.dy > screenHeight / 2 : false,
    };

    final bool isTop = switch (widget.direction) {
      WidgetTooltipDirection.top => false,
      WidgetTooltipDirection.bottom => true,
      _ => widget.autoFlip ? targetCenter.dy <= screenHeight / 2 : true,
    };

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

    return (
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      isTop: isTop,
      isBottom: isBottom,
      isLeft: isLeft,
      isRight: isRight,
    );
  }

  ({double dx, double dy}) _resolveOffsets({
    required Size messageBoxSize,
    required Size targetSize,
    required Offset targetPosition,
    required bool isTop,
    required bool isBottom,
    required bool isLeft,
    required bool isRight,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    // Horizontal overflow adjustment
    final double overflowWidth =
        (messageBoxSize.width - targetSize.width) / 2;
    final edgeFromLeft = targetPosition.dx - overflowWidth;
    final edgeFromRight = screenSize.width -
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

    // Vertical overflow adjustment
    final double overflowHeight =
        (messageBoxSize.height - targetSize.height) / 2;
    final edgeFromTop = targetPosition.dy - overflowHeight;
    final edgeFromBottom = screenSize.height -
        (targetPosition.dy + targetSize.height + overflowHeight);
    final edgeFromVertical = min(edgeFromTop, edgeFromBottom);

    double dy = 0;
    if (edgeFromVertical < widget.padding.vertical / 2) {
      if (isTop) {
        dy = safePadding.top +
            (widget.padding.vertical / 2) -
            edgeFromVertical;
      } else if (isBottom) {
        dy = safePadding.bottom -
            (widget.padding.vertical / 2) +
            edgeFromVertical;
      }
    }

    return (dx: dx, dy: dy);
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

/// Internal layout result for tooltip positioning.
class _TooltipLayout {
  const _TooltipLayout({
    required this.targetAnchor,
    required this.followerAnchor,
    required this.dx,
    required this.dy,
  });

  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final double dx;
  final double dy;
}
