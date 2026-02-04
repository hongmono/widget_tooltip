import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Internal data class that holds state for each burst icon animation.
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

/// A button widget that creates a burst animation effect when tapped or
/// long-pressed.
///
/// When the user taps the button, a single burst icon floats upward with a
/// fade-out effect. When the user long-presses, burst icons are continuously
/// spawned at a configurable rate.
///
/// {@tool snippet}
/// ```dart
/// BurstIconButton(
///   icon: const Icon(Icons.favorite_border, size: 32),
///   pressedIcon: const Icon(Icons.favorite, size: 32, color: Colors.red),
///   burstIcon: const Icon(Icons.favorite, size: 32, color: Colors.pink),
///   onPressed: () => print('Pressed!'),
/// )
/// ```
/// {@end-tool}
class BurstIconButton extends StatefulWidget {
  /// Creates a [BurstIconButton].
  ///
  /// The [icon] and [onPressed] parameters are required.
  const BurstIconButton({
    super.key,
    required this.icon,
    this.pressedIcon,
    this.burstIcon,
    this.duration = const Duration(milliseconds: 1200),
    this.throttleDuration = const Duration(milliseconds: 100),
    required this.onPressed,
    this.crossAmplitude,
    this.burstDistance,
    this.burstCount,
    this.burstCurve,
  });

  /// The default icon displayed in the button.
  final Icon icon;

  /// The icon displayed while the button is pressed down.
  ///
  /// If null, [icon] is used instead.
  final Icon? pressedIcon;

  /// The icon used for the burst animation effect.
  ///
  /// If null, [icon] is used instead.
  final Icon? burstIcon;

  /// The duration of the burst animation.
  ///
  /// Defaults to 1200 milliseconds.
  final Duration duration;

  /// The interval between burst icon spawns during a long press.
  ///
  /// Defaults to 100 milliseconds.
  final Duration throttleDuration;

  /// Called when the button is tapped or when a long press ends.
  final VoidCallback? onPressed;

  /// The maximum horizontal displacement (in logical pixels) of burst icons
  /// as they float upward.
  ///
  /// Controls how much the burst icons sway left and right during the
  /// animation. Defaults to 10.0.
  final double? crossAmplitude;

  /// The vertical distance (in logical pixels) the burst icons travel upward.
  ///
  /// Defaults to 100.0.
  final double? burstDistance;

  /// The number of burst icons spawned per tap.
  ///
  /// Defaults to 1. Increase for a more dramatic effect.
  final int? burstCount;

  /// The animation curve used for the burst animation.
  ///
  /// Defaults to [Curves.easeOut].
  final Curve? burstCurve;

  @override
  State<BurstIconButton> createState() => _BurstIconButtonState();
}

class _BurstIconButtonState extends State<BurstIconButton>
    with TickerProviderStateMixin {
  Timer? _timer;
  bool _isPressed = false;
  final List<_IconData> _icons = [];
  double? _iconSizeFactor;

  double get iconSizeFactor {
    return _iconSizeFactor ??= (widget.icon.size ??
            Theme.of(context).iconTheme.size ??
            24.0) /
        (Theme.of(context).iconTheme.size ?? 24.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    // Dispose all remaining animation controllers.
    for (final icon in List.of(_icons)) {
      icon.controller.dispose();
    }
    _icons.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final icon in _icons)
          AnimatedBuilder(
            animation: icon.controller,
            builder: (context, child) {
              final distance = widget.burstDistance ?? 100.0;
              return Transform.translate(
                offset: Offset(
                  icon.amplitude *
                      sin(icon.animation.value * pi * icon.shake),
                  -distance * icon.animation.value * iconSizeFactor,
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
          child: _isPressed ? widget.pressedIcon ?? widget.icon : widget.icon,
        ),
      ],
    );
  }

  void _onTapDown(_) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(_) {
    setState(() {
      _isPressed = false;
      _spawnBurst();
    });

    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  void _onLongPressStart(_) {
    _timer?.cancel();
    _timer = Timer.periodic(widget.throttleDuration, (_) {
      _spawnBurst();
    });

    setState(() {
      _isPressed = true;
    });
  }

  void _onLongPressEnd(_) {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isPressed = false;
    });

    widget.onPressed?.call();
  }

  void _spawnBurst() {
    final count = widget.burstCount ?? 1;
    for (var i = 0; i < count; i++) {
      _createIcon();
    }
  }

  void _createIcon() {
    final key = GlobalKey();
    final controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: widget.burstCurve ?? Curves.easeOut,
    );
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
        if (mounted) {
          setState(() {
            _icons.remove(icon);
          });
        } else {
          _icons.remove(icon);
        }
        controller.dispose();
      }
    });

    setState(() {});
  }
}
