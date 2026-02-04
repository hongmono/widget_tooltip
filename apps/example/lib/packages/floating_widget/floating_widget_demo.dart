import 'package:floating_widget/floating_widget.dart';
import 'package:flutter/material.dart';

class FloatingWidgetDemo extends StatefulWidget {
  const FloatingWidgetDemo({super.key});

  @override
  State<FloatingWidgetDemo> createState() => _FloatingWidgetDemoState();
}

class _FloatingWidgetDemoState extends State<FloatingWidgetDemo> {
  bool _snapToEdge = false;
  Offset _currentPosition = Offset.zero;
  int _selectedWidget = 0;

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      key: ValueKey('$_snapToEdge-$_selectedWidget'),
      padding: const EdgeInsets.all(16),
      initialAlignment: FloatingAlignment.bottomRight,
      snapToEdge: _snapToEdge,
      onPositionChanged: (offset) {
        setState(() {
          _currentPosition = offset;
        });
      },
      floatingWidget: _buildFloatingWidget(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Floating Widget'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildSnapToggle(),
            const SizedBox(height: 16),
            _buildWidgetSelector(),
            const SizedBox(height: 16),
            _buildPositionDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingWidget() {
    return switch (_selectedWidget) {
      0 => FloatingActionButton(
          onPressed: _showTapSnackbar,
          child: const Icon(Icons.add),
        ),
      1 => FloatingActionButton.small(
          onPressed: _showTapSnackbar,
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      2 => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.widgets, color: Colors.white, size: 32),
        ),
      _ => FloatingActionButton(
          onPressed: _showTapSnackbar,
          child: const Icon(Icons.add),
        ),
    };
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.drag_indicator, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Drag the floating button around!',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'It stays within the screen bounds with configurable padding. '
              'Toggle snap-to-edge below to see it stick to sides.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Snap to Edge'),
        subtitle: const Text('Animate to nearest side when released'),
        value: _snapToEdge,
        onChanged: (value) {
          setState(() {
            _snapToEdge = value;
          });
        },
      ),
    );
  }

  Widget _buildWidgetSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Floating Widget Style',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('FAB')),
                ButtonSegment(value: 1, label: Text('Small')),
                ButtonSegment(value: 2, label: Text('Custom')),
              ],
              selected: {_selectedWidget},
              onSelectionChanged: (value) {
                setState(() {
                  _selectedWidget = value.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Position',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'x: ${_currentPosition.dx.toStringAsFixed(1)}  '
              'y: ${_currentPosition.dy.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTapSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('FAB tapped! Try dragging it around.'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
