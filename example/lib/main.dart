import 'package:flutter/material.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Tooltip Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Widget Tooltip Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TooltipController _tooltipController = TooltipController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section: Animation Types
            Text(
              'Animation Types',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.fade,
                  message: const Text('Fade Animation'),
                  child: _buildChip('Fade'),
                ),
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.scale,
                  message: const Text('Scale Animation'),
                  child: _buildChip('Scale'),
                ),
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.scaleAndFade,
                  message: const Text('Scale & Fade Animation'),
                  child: _buildChip('Scale & Fade'),
                ),
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.none,
                  message: const Text('No Animation'),
                  child: _buildChip('None'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section: Auto Dismiss
            Text(
              'Auto Dismiss',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.manual,
                  autoDismissDuration: const Duration(seconds: 2),
                  message: const Text('I will disappear in 2 seconds!'),
                  child: _buildChip('2 seconds'),
                ),
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.manual,
                  autoDismissDuration: const Duration(seconds: 5),
                  animation: WidgetTooltipAnimation.scaleAndFade,
                  message: const Text('I will disappear in 5 seconds!'),
                  child: _buildChip('5 seconds'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section: Custom Animation Duration
            Text(
              'Custom Animation Duration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.scaleAndFade,
                  animationDuration: const Duration(milliseconds: 100),
                  message: const Text('Fast animation (100ms)'),
                  child: _buildChip('Fast'),
                ),
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.scaleAndFade,
                  animationDuration: const Duration(milliseconds: 800),
                  message: const Text('Slow animation (800ms)'),
                  child: _buildChip('Slow'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section: Manual Control
            Text(
              'Manual Control',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                WidgetTooltip(
                  controller: _tooltipController,
                  triggerMode: WidgetTooltipTriggerMode.manual,
                  dismissMode: WidgetTooltipDismissMode.manual,
                  animation: WidgetTooltipAnimation.scaleAndFade,
                  message: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Manual tooltip'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _tooltipController.dismiss,
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  child: _buildChip('Target'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _tooltipController.show,
                  child: const Text('Show Tooltip'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section: Dismiss Modes
            Text(
              'Dismiss Modes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapAnyWhere,
                  message: const Text('Tap anywhere to dismiss'),
                  child: _buildChip('Tap Anywhere'),
                ),
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapOutside,
                  message: const Text('Tap outside to dismiss'),
                  child: _buildChip('Tap Outside'),
                ),
                WidgetTooltip(
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapInside,
                  message: const Text('Tap inside to dismiss'),
                  child: _buildChip('Tap Inside'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section: Styled Tooltip
            Text(
              'Styled Tooltip',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            WidgetTooltip(
              triggerMode: WidgetTooltipTriggerMode.tap,
              animation: WidgetTooltipAnimation.scaleAndFade,
              triangleColor: Colors.blue,
              messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              messageDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              message: const Text(
                'This is a beautifully styled tooltip with custom colors and shadows!',
                style: TextStyle(color: Colors.white),
              ),
              child: _buildChip('Styled'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

