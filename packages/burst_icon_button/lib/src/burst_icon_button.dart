import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class _IconData {
  final GlobalKey key;
  final AnimationController controller;
  final Animation<double> animation;
  final double shake;
  final double amplitude;

  const _IconData({
    required this.key,
    required this.controller,
    required this.animation,
    required this.shake,
    required this.amplitude,
  });
}

class BurstIconButton extends StatefulWidget {
  const BurstIconButton({
    super.key,
    required this.icon,
    this.pressedIcon,
    this.burstIcon,
    this.duration = const Duration(milliseconds: 1200),
    this.throttleDuration = const Duration(milliseconds: 100),
    required this.onPressed,
    this.crossAmplitude,
  });

  final Icon icon;
  final Icon? pressedIcon;
  final Icon? burstIcon;
  final Duration duration;
  final Duration throttleDuration;
  final VoidCallback? onPressed;
  final double? crossAmplitude;

  @override
  State<BurstIconButton> createState() => _BurstIconButtonState();
}

class _BurstIconButtonState extends State<BurstIconButton> with TickerProviderStateMixin {
  late final Duration _duration = widget.duration;

  Timer? _timer;
  late final Duration _throttleDuration = widget.throttleDuration;

  WidgetState? _state;

  final List<_IconData> _icons = [];

  late final _iconSizeFactor = (widget.icon.size ?? Theme.of(context).iconTheme.size ?? 24.0) / (Theme.of(context).iconTheme.size ?? 24.0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final icon in _icons)
          AnimatedBuilder(
            animation: icon.controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  icon.amplitude * sin(icon.animation.value * pi * icon.shake),
                  -100 * icon.animation.value * _iconSizeFactor,
                ),
                child: FadeTransition(
                  opacity: Tween(
                    begin: 1.0,
                    end: 0.0,
                  ).animate(icon.animation),
                  child: widget.burstIcon ?? widget.icon,
                ),
              );
            },
          ),
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          child: _state == WidgetState.pressed ? widget.pressedIcon ?? widget.icon : widget.icon,
        ),
      ],
    );
  }

  void _onTapDown(_) {
    setState(() {
      _state = WidgetState.pressed;
    });
  }

  void _onTapUp(_) {
    setState(() {
      _state = null;
      _createIcon();
    });

    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() {
      _state = null;
    });
  }

  void _onLongPressStart(_) {
    _timer?.cancel();
    _timer = Timer.periodic(_throttleDuration, (_) {
      _createIcon();
    });

    setState(() {
      _state = WidgetState.pressed;
    });
  }

  void _onLongPressEnd(_) {
    _timer?.cancel();
    setState(() {
      _state = null;
    });

    widget.onPressed?.call();
  }

  void _createIcon() {
    final key = GlobalKey();
    final controller = AnimationController(vsync: this, duration: _duration);
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final icon = _IconData(
      key: key,
      controller: controller,
      animation: animation,
      shake: Random().nextDouble() - 0.5,
      amplitude: widget.crossAmplitude ?? 10.0,
    );
    _icons.add(icon);
    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _icons.remove(icon);
        controller.dispose();
      }
    });

    setState(() {});
  }
}
