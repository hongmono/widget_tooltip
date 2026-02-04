import 'package:flutter/material.dart';

/// The alignment position for initial placement of the floating widget.
///
/// Used with [FloatingWidget.initialAlignment] to place the floating widget
/// at a predefined screen position without calculating raw offsets.
enum FloatingAlignment {
  /// Top-left corner of the available area.
  topLeft,

  /// Top-center of the available area.
  topCenter,

  /// Top-right corner of the available area.
  topRight,

  /// Center-left of the available area.
  centerLeft,

  /// Center of the available area.
  center,

  /// Center-right of the available area.
  centerRight,

  /// Bottom-left corner of the available area.
  bottomLeft,

  /// Bottom-center of the available area.
  bottomCenter,

  /// Bottom-right corner of the available area.
  bottomRight,
}

/// A widget that wraps its [child] and overlays a draggable [floatingWidget]
/// that can be repositioned anywhere on screen within configurable boundaries.
///
/// The floating widget is constrained to stay within the screen bounds minus
/// the specified [padding]. When [snapToEdge] is enabled, the widget
/// automatically animates to the nearest horizontal edge when released.
///
/// {@tool snippet}
/// Basic usage:
/// ```dart
/// FloatingWidget(
///   floatingWidget: FloatingActionButton(
///     onPressed: () {},
///     child: Icon(Icons.add),
///   ),
///   child: Scaffold(body: Center(child: Text('Hello'))),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// With snap-to-edge and position callback:
/// ```dart
/// FloatingWidget(
///   floatingWidget: FloatingActionButton(
///     onPressed: () {},
///     child: Icon(Icons.chat),
///   ),
///   initialAlignment: FloatingAlignment.bottomRight,
///   snapToEdge: true,
///   onPositionChanged: (offset) => print('Moved to $offset'),
///   padding: EdgeInsets.all(16),
///   child: Scaffold(body: YourContent()),
/// )
/// ```
/// {@end-tool}
class FloatingWidget extends StatefulWidget {
  /// Creates a [FloatingWidget].
  ///
  /// The [floatingWidget] and [child] arguments must not be null.
  /// If both [initialPosition] and [initialAlignment] are provided,
  /// [initialAlignment] takes precedence.
  const FloatingWidget({
    super.key,
    required this.floatingWidget,
    this.initialPosition = Offset.zero,
    this.initialAlignment,
    this.padding = EdgeInsets.zero,
    this.snapToEdge = false,
    this.snapAnimationDuration = const Duration(milliseconds: 300),
    this.snapAnimationCurve = Curves.easeOut,
    this.onPositionChanged,
    required this.child,
  });

  /// The widget that floats above [child] and can be dragged around.
  final Widget floatingWidget;

  /// The initial position of the floating widget as a raw offset.
  ///
  /// Ignored when [initialAlignment] is provided.
  /// Defaults to [Offset.zero].
  final Offset initialPosition;

  /// The initial alignment of the floating widget.
  ///
  /// When provided, this takes precedence over [initialPosition].
  /// The actual offset is calculated after layout based on the screen size
  /// and the floating widget's measured size.
  final FloatingAlignment? initialAlignment;

  /// The main content widget displayed beneath the floating widget.
  final Widget child;

  /// Padding inset from the screen edges that constrains the floating widget.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsets padding;

  /// Whether the floating widget should snap to the nearest horizontal edge
  /// when released.
  ///
  /// When `true`, after a drag ends the widget animates to either the left
  /// or right edge (respecting [padding]). Defaults to `false`.
  final bool snapToEdge;

  /// Duration of the snap/clamp animation.
  ///
  /// Defaults to 300 milliseconds.
  final Duration snapAnimationDuration;

  /// Curve used for the snap/clamp animation.
  ///
  /// Defaults to [Curves.easeOut].
  final Curve snapAnimationCurve;

  /// Called whenever the floating widget's position changes.
  ///
  /// The callback receives the new [Offset] after clamping and snapping.
  final ValueChanged<Offset>? onPositionChanged;

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  Size? _floatingWidgetSize;
  final GlobalKey _floatingWidgetKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  late final AnimationController _animationController;
  Animation<Offset>? _animation;
  bool _initialAlignmentApplied = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.snapAnimationDuration,
    );
    _animationController.addListener(_onAnimationTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureFloatingWidget();
      _applyInitialAlignment();
    });
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    if (!mounted) return;
    final anim = _animation;
    if (anim != null) {
      setState(() {
        _position = anim.value;
      });
    }
  }

  void _measureFloatingWidget() {
    final renderObject = _floatingWidgetKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _floatingWidgetSize = renderObject.size;
    }
  }

  void _applyInitialAlignment() {
    if (_initialAlignmentApplied) return;
    final alignment = widget.initialAlignment;
    if (alignment == null) return;

    final size = _floatingWidgetSize;
    if (size == null || !mounted) return;

    final screenSize = MediaQuery.of(context).size;
    final offset = _alignmentToOffset(alignment, screenSize, size);
    _initialAlignmentApplied = true;

    setState(() {
      _position = offset;
    });
    widget.onPositionChanged?.call(offset);
  }

  Offset _alignmentToOffset(
    FloatingAlignment alignment,
    Size screenSize,
    Size widgetSize,
  ) {
    final left = widget.padding.left;
    final top = widget.padding.top;
    final right = screenSize.width - widgetSize.width - widget.padding.right;
    final bottom = screenSize.height - widgetSize.height - widget.padding.bottom;
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;

    return switch (alignment) {
      FloatingAlignment.topLeft => Offset(left, top),
      FloatingAlignment.topCenter => Offset(centerX, top),
      FloatingAlignment.topRight => Offset(right, top),
      FloatingAlignment.centerLeft => Offset(left, centerY),
      FloatingAlignment.center => Offset(centerX, centerY),
      FloatingAlignment.centerRight => Offset(right, centerY),
      FloatingAlignment.bottomLeft => Offset(left, bottom),
      FloatingAlignment.bottomCenter => Offset(centerX, bottom),
      FloatingAlignment.bottomRight => Offset(right, bottom),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _stackKey,
      children: [
        widget.child,
        Positioned(
          top: _position.dy,
          left: _position.dx,
          child: GestureDetector(
            onPanUpdate: (details) {
              _animationController.stop();
              _measureFloatingWidget();
              setState(() {
                _position = Offset(
                  _position.dx + details.delta.dx,
                  _position.dy + details.delta.dy,
                );
              });
            },
            onPanEnd: (_) {
              _onDragEnd();
            },
            child: SizedBox(
              key: _floatingWidgetKey,
              child: widget.floatingWidget,
            ),
          ),
        ),
      ],
    );
  }

  void _onDragEnd() {
    if (!mounted) return;
    _measureFloatingWidget();

    final size = _floatingWidgetSize;
    if (size == null) {
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final target = _clampPosition(_position, screenSize, size);
    final snapped = widget.snapToEdge
        ? _snapToNearestEdge(target, screenSize, size)
        : target;

    _animateTo(snapped);
  }

  Offset _clampPosition(Offset position, Size screenSize, Size widgetSize) {
    final minX = widget.padding.left;
    final minY = widget.padding.top;
    final maxX = screenSize.width - widgetSize.width - widget.padding.right;
    final maxY = screenSize.height - widgetSize.height - widget.padding.bottom;

    return Offset(
      position.dx.clamp(minX, maxX),
      position.dy.clamp(minY, maxY),
    );
  }

  Offset _snapToNearestEdge(Offset position, Size screenSize, Size widgetSize) {
    final minX = widget.padding.left;
    final maxX = screenSize.width - widgetSize.width - widget.padding.right;
    final midX = (minX + maxX) / 2;

    final snappedX = position.dx < midX ? minX : maxX;
    return Offset(snappedX, position.dy);
  }

  void _animateTo(Offset target) {
    if (_position == target) {
      widget.onPositionChanged?.call(target);
      return;
    }

    _animation = Tween<Offset>(
      begin: _position,
      end: target,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.snapAnimationCurve,
    ));

    _animationController.duration = widget.snapAnimationDuration;
    _animationController.forward(from: 0).then((_) {
      if (mounted) {
        widget.onPositionChanged?.call(target);
      }
    });
  }
}
