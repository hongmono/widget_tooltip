import 'dart:async';

import 'package:flutter/material.dart';

import 'enums.dart';
import 'tooltip_animation_builder.dart';
import 'tooltip_controller.dart';
import 'tooltip_overlay.dart';
import 'tooltip_position_calculator.dart';
import 'triangles/tooltip_triangle.dart';

export 'enums.dart';
export 'tooltip_controller.dart';

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
  /// - Target in top half -> tooltip appears below
  /// - Target in bottom half -> tooltip appears above
  /// - Target in left half -> tooltip appears to the right
  /// - Target in right half -> tooltip appears to the left
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

  final _targetKey = GlobalKey(debugLabel: 'WidgetTooltip_target');
  final _messageKey = GlobalKey(debugLabel: 'WidgetTooltip_message');
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

  void _scheduleDismiss() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.dismiss();
    });
  }

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

    final targetSize = renderObject.size;
    final targetPosition = renderObject.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final resolvedPadding = widget.padding.resolve(TextDirection.ltr);

    final targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    final calculator = TooltipPositionCalculator(
      axis: widget.axis,
      autoFlip: widget.autoFlip,
      direction: widget.direction,
      targetPadding: widget.targetPadding,
      triangleSize: widget.triangleSize,
    );

    final layout = calculator.calculate(
      targetCenter: targetCenter,
      screenSize: screenSize,
      padding: resolvedPadding,
      targetPosition: targetPosition,
      targetSize: targetSize,
    );

    _overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlayContent(
        targetSize: targetSize,
        screenSize: screenSize,
        resolvedPadding: resolvedPadding,
        layout: layout,
      ),
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

  Widget _buildOverlayContent({
    required Size targetSize,
    required Size screenSize,
    required EdgeInsets resolvedPadding,
    required TooltipLayoutData layout,
  }) {
    final renderObject = _targetKey.currentContext?.findRenderObject();

    if (renderObject == null ||
        renderObject is! RenderBox ||
        !renderObject.attached) {
      _scheduleDismiss();
      return const SizedBox.shrink();
    }

    final currentTargetPosition = renderObject.localToGlobal(Offset.zero);

    if (!_isTargetVisible(
      position: currentTargetPosition,
      targetSize: targetSize,
      screenSize: screenSize,
    )) {
      _scheduleDismiss();
      return const SizedBox.shrink();
    }

    final currentTargetCenter = currentTargetPosition.dx + targetSize.width / 2;

    final animationBuilder = TooltipAnimationBuilder(
      animation: widget.animation,
      animationValue: _animation,
    );

    return TapRegion(
      onTapInside: _shouldDismissOnTapInside() ? _controller.dismiss : null,
      onTapOutside: _shouldDismissOnTapOutside() ? _controller.dismiss : null,
      child: CompositedTransformFollower(
        link: _layerLink,
        targetAnchor: layout.targetAnchor,
        followerAnchor: layout.followerAnchor,
        offset: layout.tooltipOffset,
        child: animationBuilder.build(
          scaleAlignment: layout.scaleAlignment,
          child: Builder(
            builder: (_) => _buildTooltipContent(
              layout: layout,
              screenSize: screenSize,
              resolvedPadding: resolvedPadding,
              currentTargetCenter: currentTargetCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipContent({
    required TooltipLayoutData layout,
    required Size screenSize,
    required EdgeInsets resolvedPadding,
    required double currentTargetCenter,
  }) {
    final triangle = SizedBox.fromSize(
      size: widget.triangleSize,
      child: TooltipTriangle(
        direction: layout.triangleDirection,
        color: widget.triangleColor,
        radius: widget.triangleRadius,
      ),
    );

    final messageBox = TooltipOverlay(
      messageKey: _messageKey,
      maxWidth: layout.maxWidth,
      screenSize: screenSize,
      padding: resolvedPadding,
      targetCenterX: currentTargetCenter,
      axis: widget.axis,
      offsetIgnore: widget.offsetIgnore,
      messagePadding: widget.messagePadding,
      messageDecoration: widget.messageDecoration,
      message: widget.message,
    );

    if (widget.axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: layout.showAbove
            ? [messageBox, triangle]
            : [triangle, messageBox],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: layout.showLeft
            ? [messageBox, triangle]
            : [triangle, messageBox],
      );
    }
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
