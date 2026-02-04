import 'package:floating_widget/floating_widget.dart';
import 'package:flutter/material.dart';

class FloatingWidgetDemo extends StatelessWidget {
  const FloatingWidgetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      padding: const EdgeInsets.all(16),
      floatingWidget: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('FAB tapped! Try dragging it around.'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Floating Widget'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.drag_indicator, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Drag the floating button around!',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'It stays within the screen bounds with configurable padding.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
