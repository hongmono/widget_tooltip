import 'package:flutter/material.dart';

class FloatingWidget extends StatefulWidget {
  const FloatingWidget({
    super.key,
    required this.floatingWidget,
    this.initialPosition = Offset.zero,
    this.padding = EdgeInsets.zero,
    required this.child,
  });

  final Widget floatingWidget;
  final Offset initialPosition;
  final Widget child;
  final EdgeInsets padding;

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> {
  late Offset _position;
  late Size _floatingWidgetSize;
  final GlobalKey _floatingWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _position = widget.initialPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _floatingWidgetKey.currentContext?.findRenderObject() as RenderBox;
      _floatingWidgetSize = renderBox.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: _position.dy,
          left: _position.dx,
          child: Draggable(
            feedback: widget.floatingWidget,
            childWhenDragging: const SizedBox.shrink(),
            child: SizedBox(
              key: _floatingWidgetKey,
              child: widget.floatingWidget,
            ),
            onDraggableCanceled: (velocity, offset) {
              _updatePosition(offset);
            },
          ),
        ),
      ],
    );
  }

  void _updatePosition(Offset position) {
    if (position.dx < 0 + widget.padding.left) {
      position = Offset(widget.padding.left, position.dy);
    }
    if (position.dy < 0 + widget.padding.top) {
      position = Offset(position.dx, widget.padding.top);
    }
    if (position.dx > MediaQuery.of(context).size.width - _floatingWidgetSize.width - widget.padding.right) {
      position = Offset(MediaQuery.of(context).size.width - _floatingWidgetSize.width - widget.padding.right, position.dy);
    }
    if (position.dy > MediaQuery.of(context).size.height - _floatingWidgetSize.height - widget.padding.bottom) {
      position = Offset(position.dx, MediaQuery.of(context).size.height - _floatingWidgetSize.height - widget.padding.bottom);
    }
    setState(() {
      _position = position;
    });
  }
}
