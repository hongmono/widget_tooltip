import 'package:flutter/material.dart';

/// A widget that positions the tooltip within screen bounds.
///
/// This is an internal widget used by [WidgetTooltip] to handle
/// the tooltip message positioning and screen edge adjustments.
class TooltipOverlay extends StatefulWidget {
  const TooltipOverlay({
    super.key,
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

  /// GlobalKey for the message container to calculate bounds.
  final GlobalKey messageKey;

  /// Maximum width constraint for the tooltip.
  final double maxWidth;

  /// Screen size for bounds calculation.
  final Size screenSize;

  /// Padding from screen edges.
  final EdgeInsets padding;

  /// X coordinate of the target widget's center.
  final double targetCenterX;

  /// Tooltip axis direction.
  final Axis axis;

  /// Whether to ignore offset adjustments for screen bounds.
  final bool offsetIgnore;

  /// Padding inside the message box.
  final EdgeInsetsGeometry messagePadding;

  /// Decoration for the message box.
  final BoxDecoration messageDecoration;

  /// The message widget to display.
  final Widget message;

  @override
  State<TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<TooltipOverlay> {
  double _horizontalOffset = 0;
  double _verticalOffset = 0;
  bool _measured = false;
  int _retryCount = 0;
  static const int _maxRetries = 5;

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

    final renderObject = widget.messageKey.currentContext?.findRenderObject();
    if (renderObject == null ||
        renderObject is! RenderBox ||
        !renderObject.hasSize) {
      // Retry: render object may not be ready yet on first frame
      if (_retryCount < _maxRetries) {
        _retryCount++;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _calculateOffset();
        });
      } else {
        // Give up waiting — show the tooltip anyway to avoid permanent invisibility
        if (mounted && !_measured) {
          setState(() => _measured = true);
        }
      }
      return;
    }
    final renderBox = renderObject;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    double horizontalOffset = 0;
    double verticalOffset = 0;

    if (widget.axis == Axis.vertical) {
      // Horizontal overflow handling
      // Check left edge
      if (position.dx < widget.padding.left) {
        horizontalOffset = widget.padding.left - position.dx;
      }
      // Check right edge
      else if (position.dx + size.width >
          widget.screenSize.width - widget.padding.right) {
        horizontalOffset = widget.screenSize.width -
            widget.padding.right -
            position.dx -
            size.width;
      }

      // Vertical overflow handling
      // Check top edge — tooltip goes above screen
      if (position.dy < widget.padding.top) {
        verticalOffset = widget.padding.top - position.dy;
      }
      // Check bottom edge — tooltip goes below screen
      else if (position.dy + size.height >
          widget.screenSize.height - widget.padding.bottom) {
        verticalOffset = widget.screenSize.height -
            widget.padding.bottom -
            position.dy -
            size.height;
      }
    } else {
      // Horizontal axis: check vertical overflow
      if (position.dy < widget.padding.top) {
        verticalOffset = widget.padding.top - position.dy;
      } else if (position.dy + size.height >
          widget.screenSize.height - widget.padding.bottom) {
        verticalOffset = widget.screenSize.height -
            widget.padding.bottom -
            position.dy -
            size.height;
      }
    }

    if (horizontalOffset != _horizontalOffset ||
        verticalOffset != _verticalOffset ||
        !_measured) {
      setState(() {
        _horizontalOffset = horizontalOffset;
        _verticalOffset = verticalOffset;
        _measured = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _measured ? 1.0 : 0.0,
      child: Transform.translate(
        offset: Offset(_horizontalOffset, _verticalOffset),
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
