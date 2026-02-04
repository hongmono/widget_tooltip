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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap or long-press the button',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 48),
            BurstIconButton(
              icon: const Icon(Icons.favorite_border, size: 48),
              pressedIcon: const Icon(Icons.favorite, size: 48, color: Colors.red),
              burstIcon: const Icon(Icons.heart_broken, size: 48, color: Colors.red),
              onPressed: () {},
            ),
            const SizedBox(height: 48),
            Text(
              'Long-press for continuous burst!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
