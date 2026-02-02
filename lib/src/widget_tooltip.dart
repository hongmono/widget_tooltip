import 'dart:async';

import 'package:flutter/material.dart';

import 'enums.dart';
import 'tooltip_animation_builder.dart';
import 'tooltip_controller.dart';
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
/// Uses a two-phase positioning approach:
/// 1. First renders the tooltip to measure its actual size
/// 2. Then calculates precise overflow-adjusted offsets using the measured size
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
  /// When false and no [direction] is set, the tooltip defaults to below/right.
  /// When [direction] is explicitly set, it always takes precedence regardless
  /// of this value.
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
  bool _isDisposed = false;

  /// Holds the calculated layout data after measurement.
  /// null during measurement phase, set after measurement.
  TooltipLayoutData? _layout;

  /// Max width constraint for the message box.
  double _maxWidth = 0;

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
    _isDisposed = true;
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

  /// Shows the tooltip using a two-phase approach:
  /// 1. Phase 1 (Measure): Insert overlay with message box to measure its size
  /// 2. Phase 2 (Position): Use measured size to calculate precise offsets,
  ///    rebuild overlay with final positioned layout
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
    final safePadding = MediaQuery.of(context).padding;

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
      offsetIgnore: widget.offsetIgnore,
    );

    // Pre-calculate constraints for the measurement phase
    final constraints = calculator.calculateConstraints(
      targetCenter: targetCenter,
      screenSize: screenSize,
      padding: resolvedPadding,
      targetPosition: targetPosition,
      targetSize: targetSize,
    );

    _maxWidth = constraints.maxWidth;
    _layout = null; // Start in measurement phase

    _overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlayContent(),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Phase 1 → Phase 2 transition: measure then reposition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || _overlayEntry == null) return;

      final messageRenderBox =
          _messageKey.currentContext?.findRenderObject() as RenderBox?;
      if (messageRenderBox == null || !messageRenderBox.hasSize) return;

      final messageBoxSize = messageRenderBox.size;

      // Calculate final layout with measured size
      _layout = calculator.calculate(
        targetCenter: targetCenter,
        screenSize: screenSize,
        padding: resolvedPadding,
        safePadding: safePadding,
        targetPosition: targetPosition,
        targetSize: targetSize,
        messageBoxSize: messageBoxSize,
      );

      // Replace overlay with positioned layout
      _overlayEntry?.remove();
      _overlayEntry = OverlayEntry(
        builder: (_) => _buildOverlayContent(),
      );
      Overlay.of(context).insert(_overlayEntry!);

      // Start animation after positioning
      if (widget.animation != WidgetTooltipAnimation.none) {
        _animationController.forward();
      } else {
        _animationController.value = 1.0;
      }
    });

    _startAutoDismissTimer();
    widget.onShow?.call();
  }

  /// Builds the overlay content based on the current phase.
  ///
  /// During measurement phase ([_layout] is null): renders an invisible
  /// message box to measure its size.
  ///
  /// During positioned phase ([_layout] is set): renders the final tooltip
  /// with proper overflow-adjusted positioning.
  Widget _buildOverlayContent() {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    if (_layout == null) {
      // Phase 1: Measurement - render message invisibly to measure
      return _buildMeasurementOverlay();
    } else {
      // Phase 2: Final positioned overlay
      return _buildPositionedOverlay(_layout!);
    }
  }

  /// Builds the invisible measurement overlay.
  ///
  /// The message box is rendered with opacity 0 to get its actual size
  /// without visual artifacts. The widget tree contains the message text
  /// so finders can locate it (important for tests).
  Widget _buildMeasurementOverlay() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth),
            child: Container(
              key: _messageKey,
              padding: widget.messagePadding,
              decoration: widget.messageDecoration,
              child: widget.message,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the final positioned overlay using v1.1.4's proven structure:
  /// - Stack with SizedBox.expand() for full-screen tap detection
  /// - Separate CompositedTransformFollowers for message box and triangle
  /// - Each with independently calculated overflow-adjusted offsets
  Widget _buildPositionedOverlay(TooltipLayoutData layout) {
    final messageBox = Material(
      type: MaterialType.transparency,
      child: Semantics(
        container: true,
        liveRegion: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: layout.maxWidth),
          child: Container(
            padding: widget.messagePadding,
            decoration: widget.messageDecoration,
            child: widget.message,
          ),
        ),
      ),
    );

    final triangle = SizedBox.fromSize(
      size: widget.triangleSize,
      child: TooltipTriangle(
        direction: layout.triangleDirection,
        color: widget.triangleColor,
        radius: widget.triangleRadius,
      ),
    );

    final animationBuilder = TooltipAnimationBuilder(
      animation: widget.animation,
      animationValue: _animation,
    );

    return TapRegion(
      onTapInside: _shouldDismissOnTapInside() ? _controller.dismiss : null,
      onTapOutside: _shouldDismissOnTapOutside() ? _controller.dismiss : null,
      child: Stack(
        children: [
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: layout.targetAnchor,
            followerAnchor: layout.followerAnchor,
            offset: layout.messageBoxOffset,
            child: animationBuilder.build(
              scaleAlignment: layout.scaleAlignment,
              child: messageBox,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: layout.targetAnchor,
            followerAnchor: layout.followerAnchor,
            offset: layout.triangleOffset,
            child: animationBuilder.build(
              scaleAlignment: layout.scaleAlignment,
              child: triangle,
            ),
          ),
        ],
      ),
    );
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
      if (widget.animation != WidgetTooltipAnimation.none && !_isDisposed) {
        await _animationController.reverse();
      }
    } catch (_) {
      // Animation may fail if widget is disposed during animation
    } finally {
      _animationController.value = 0.0;
      try {
        _overlayEntry?.remove();
      } catch (_) {
        // Overlay may already be removed if widget tree was disposed
      }
      _overlayEntry = null;
      _layout = null;
      widget.onDismiss?.call();
    }
  }
}
