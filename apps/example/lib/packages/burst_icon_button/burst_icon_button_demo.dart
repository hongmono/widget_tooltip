import 'package:burst_icon_button/burst_icon_button.dart';
import 'package:flutter/material.dart';

class BurstIconButtonDemo extends StatelessWidget {
  const BurstIconButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Burst Icon Button'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap or long-press any button below',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // --- Heart ---
            _DemoSection(
              title: '❤️ Heart — Basic',
              subtitle: 'Default icon with pressed & burst variants',
              child: BurstIconButton(
                icon: const Icon(Icons.favorite_border, size: 48),
                pressedIcon:
                    const Icon(Icons.favorite, size: 48, color: Colors.red),
                burstIcon: const Icon(Icons.heart_broken,
                    size: 48, color: Colors.red),
                onPressed: () {},
              ),
            ),

            // --- Star with custom amplitude ---
            _DemoSection(
              title: '⭐ Star — Wide Sway',
              subtitle: 'crossAmplitude: 40, burstDistance: 150',
              child: BurstIconButton(
                icon: const Icon(Icons.star_border, size: 48),
                pressedIcon:
                    const Icon(Icons.star, size: 48, color: Colors.amber),
                burstIcon:
                    const Icon(Icons.star, size: 48, color: Colors.orange),
                crossAmplitude: 40,
                burstDistance: 150,
                onPressed: () {},
              ),
            ),

            // --- Thumb up with fast burst ---
            _DemoSection(
              title: '👍 Thumb Up — Fast Burst',
              subtitle: 'throttleDuration: 50ms, duration: 800ms',
              child: BurstIconButton(
                icon: const Icon(Icons.thumb_up_off_alt, size: 48),
                pressedIcon:
                    const Icon(Icons.thumb_up, size: 48, color: Colors.blue),
                burstIcon:
                    const Icon(Icons.thumb_up, size: 48, color: Colors.blue),
                throttleDuration: const Duration(milliseconds: 50),
                duration: const Duration(milliseconds: 800),
                onPressed: () {},
              ),
            ),

            // --- Fire with multi-burst ---
            _DemoSection(
              title: '🔥 Fire — Multi-Burst',
              subtitle: 'burstCount: 3, Curves.easeOutCubic',
              child: BurstIconButton(
                icon: const Icon(Icons.local_fire_department,
                    size: 48, color: Colors.orange),
                burstIcon: const Icon(Icons.local_fire_department,
                    size: 48, color: Colors.deepOrange),
                burstCount: 3,
                crossAmplitude: 30,
                burstCurve: Curves.easeOutCubic,
                duration: const Duration(milliseconds: 1500),
                onPressed: () {},
              ),
            ),

            // --- Rocket with slow float ---
            _DemoSection(
              title: '🚀 Rocket — Slow Float',
              subtitle: 'duration: 2000ms, burstDistance: 200',
              child: BurstIconButton(
                icon: const Icon(Icons.rocket_launch_outlined, size: 48),
                pressedIcon: const Icon(Icons.rocket_launch,
                    size: 48, color: Colors.deepPurple),
                burstIcon: const Icon(Icons.rocket_launch,
                    size: 48, color: Colors.purple),
                duration: const Duration(milliseconds: 2000),
                burstDistance: 200,
                crossAmplitude: 5,
                onPressed: () {},
              ),
            ),

            // --- Small sparkle with custom curve ---
            _DemoSection(
              title: '✨ Sparkle — Small & Bouncy',
              subtitle: 'size: 24, burstCurve: Curves.bounceOut',
              child: BurstIconButton(
                icon:
                    const Icon(Icons.auto_awesome_outlined, size: 24),
                pressedIcon: const Icon(Icons.auto_awesome,
                    size: 24, color: Colors.yellow),
                burstIcon: const Icon(Icons.auto_awesome,
                    size: 24, color: Colors.amber),
                burstCurve: Curves.bounceOut,
                burstCount: 2,
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 48),
            Center(
              child: Text(
                'Long-press for continuous burst!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          child,
        ],
      ),
    );
  }
}
