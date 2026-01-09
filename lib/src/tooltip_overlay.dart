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

    final renderObject = widget.messageKey.currentContext?.findRenderObject();
    if (renderObject == null ||
        renderObject is! RenderBox ||
        !renderObject.hasSize) {
      return;
    }
    final renderBox = renderObject;

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
