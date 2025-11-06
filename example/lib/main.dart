import 'package:flutter/material.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Tooltip Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TooltipExamplePage(),
    );
  }
}

class TooltipExamplePage extends StatefulWidget {
  const TooltipExamplePage({super.key});

  @override
  State<TooltipExamplePage> createState() => _TooltipExamplePageState();
}

class _TooltipExamplePageState extends State<TooltipExamplePage> {
  final TooltipController _manualController = TooltipController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Widget Tooltip Examples'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Manual control example
              _buildSection(
                title: 'Manual Control',
                children: [
                  WidgetTooltip(
                    controller: _manualController,
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    dismissMode: WidgetTooltipDismissMode.manual,
                    message: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Custom controlled tooltip',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _manualController.dismiss,
                            icon: const Icon(Icons.close, color: Colors.white),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),
                    axis: Axis.horizontal,
                    triangleColor: Colors.deepPurple,
                    child: const ElevatedButton(
                      onPressed: null,
                      child: Text('Click me (Manual Dismiss)'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Dismiss modes
              _buildSection(
                title: 'Dismiss Modes',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      WidgetTooltip(
                        triggerMode: WidgetTooltipTriggerMode.tap,
                        dismissMode: WidgetTooltipDismissMode.tapAnyWhere,
                        message: _buildTooltipMessage('Tap anywhere to dismiss'),
                        child: _buildButton('Tap Anywhere'),
                      ),
                      WidgetTooltip(
                        triggerMode: WidgetTooltipTriggerMode.tap,
                        dismissMode: WidgetTooltipDismissMode.tapInside,
                        message: _buildTooltipMessage('Tap inside to dismiss'),
                        child: _buildButton('Tap Inside'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WidgetTooltip(
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    dismissMode: WidgetTooltipDismissMode.tapOutside,
                    message: _buildTooltipMessage('Tap outside to dismiss'),
                    child: _buildButton('Tap Outside'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Trigger modes
              _buildSection(
                title: 'Trigger Modes',
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      WidgetTooltip(
                        triggerMode: WidgetTooltipTriggerMode.tap,
                        message: _buildTooltipMessage('Triggered by tap'),
                        child: _buildButton('Tap'),
                      ),
                      WidgetTooltip(
                        triggerMode: WidgetTooltipTriggerMode.longPress,
                        message: _buildTooltipMessage('Triggered by long press'),
                        child: _buildButton('Long Press'),
                      ),
                      WidgetTooltip(
                        triggerMode: WidgetTooltipTriggerMode.doubleTap,
                        message: _buildTooltipMessage('Triggered by double tap'),
                        child: _buildButton('Double Tap'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Directions
              _buildSection(
                title: 'Directions',
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      WidgetTooltip(
                        direction: WidgetTooltipDirection.top,
                        message: _buildTooltipMessage('Top'),
                        child: _buildButton('Top'),
                      ),
                      WidgetTooltip(
                        direction: WidgetTooltipDirection.bottom,
                        message: _buildTooltipMessage('Bottom'),
                        child: _buildButton('Bottom'),
                      ),
                      WidgetTooltip(
                        direction: WidgetTooltipDirection.left,
                        axis: Axis.horizontal,
                        message: _buildTooltipMessage('Left'),
                        child: _buildButton('Left'),
                      ),
                      WidgetTooltip(
                        direction: WidgetTooltipDirection.right,
                        axis: Axis.horizontal,
                        message: _buildTooltipMessage('Right'),
                        child: _buildButton('Right'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTooltipMessage(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildButton(String label) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(label),
    );
  }
}
