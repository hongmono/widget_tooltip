import 'package:flutter/material.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

void main() {
  runApp(const MyApp());
}

/// Helper function to create consistent tooltip decoration
BoxDecoration _tooltipDecoration(Color color) {
  return BoxDecoration(
    color: color.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Tooltip Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TooltipShowcase(),
    );
  }
}

class TooltipShowcase extends StatefulWidget {
  const TooltipShowcase({super.key});

  @override
  State<TooltipShowcase> createState() => _TooltipShowcaseState();
}

class _TooltipShowcaseState extends State<TooltipShowcase>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Tooltip'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Triggers'),
            Tab(text: 'Dismiss'),
            Tab(text: 'Directions'),
            Tab(text: 'Animations'),
            Tab(text: 'Features'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TriggerModesPage(),
          DismissModesPage(),
          DirectionsPage(),
          AnimationsPage(),
          FeaturesPage(),
        ],
      ),
    );
  }
}

// ============================================================================
// Trigger Modes Page
// ============================================================================

class TriggerModesPage extends StatefulWidget {
  const TriggerModesPage({super.key});

  @override
  State<TriggerModesPage> createState() => _TriggerModesPageState();
}

class _TriggerModesPageState extends State<TriggerModesPage> {
  final TooltipController _manualController = TooltipController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionTitle('Trigger Modes'),
        const SizedBox(height: 8),
        Text(
          'Different ways to show tooltips',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _DemoCard(
              label: 'Tap',
              child: WidgetTooltip(
                message: const Text('Triggered by tap!'),
                triggerMode: WidgetTooltipTriggerMode.tap,
                messageDecoration: _tooltipDecoration(Colors.blue),
                triangleColor: Colors.blue[700]!,
                child: _DemoButton(
                  icon: Icons.touch_app,
                  label: 'Tap me',
                  color: Colors.blue,
                ),
              ),
            ),
            _DemoCard(
              label: 'Long Press',
              child: WidgetTooltip(
                message: const Text('Triggered by long press!'),
                triggerMode: WidgetTooltipTriggerMode.longPress,
                messageDecoration: _tooltipDecoration(Colors.orange),
                triangleColor: Colors.orange[700]!,
                child: _DemoButton(
                  icon: Icons.pan_tool,
                  label: 'Hold me',
                  color: Colors.orange,
                ),
              ),
            ),
            _DemoCard(
              label: 'Double Tap',
              child: WidgetTooltip(
                message: const Text('Triggered by double tap!'),
                triggerMode: WidgetTooltipTriggerMode.doubleTap,
                messageDecoration: _tooltipDecoration(Colors.purple),
                triangleColor: Colors.purple[700]!,
                child: _DemoButton(
                  icon: Icons.ads_click,
                  label: 'Double tap',
                  color: Colors.purple,
                ),
              ),
            ),
            _DemoCard(
              label: 'Hover (Desktop/Web)',
              child: WidgetTooltip(
                message: const Text('Triggered by mouse hover!'),
                triggerMode: WidgetTooltipTriggerMode.hover,
                messageDecoration: _tooltipDecoration(Colors.teal),
                triangleColor: Colors.teal[700]!,
                child: _DemoButton(
                  icon: Icons.mouse,
                  label: 'Hover me',
                  color: Colors.teal,
                ),
              ),
            ),
            _DemoCard(
              label: 'Manual Control',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WidgetTooltip(
                    message: const Text('Controlled programmatically!'),
                    controller: _manualController,
                    triggerMode: WidgetTooltipTriggerMode.manual,
                    dismissMode: WidgetTooltipDismissMode.manual,
                    messageDecoration: _tooltipDecoration(Colors.pink),
                    triangleColor: Colors.pink[700]!,
                    child: _DemoButton(
                      icon: Icons.smart_toy,
                      label: 'Target',
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: _manualController.show,
                        child: const Text('Show'),
                      ),
                      TextButton(
                        onPressed: _manualController.dismiss,
                        child: const Text('Hide'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// Dismiss Modes Page
// ============================================================================

class DismissModesPage extends StatelessWidget {
  const DismissModesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionTitle('Dismiss Modes'),
        const SizedBox(height: 8),
        Text(
          'Different ways to hide tooltips',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _DemoCard(
              label: 'Tap Anywhere',
              description: 'Dismiss by tapping anywhere',
              child: WidgetTooltip(
                message: const Text('Tap anywhere to dismiss'),
                triggerMode: WidgetTooltipTriggerMode.tap,
                dismissMode: WidgetTooltipDismissMode.tapAnywhere,
                messageDecoration: _tooltipDecoration(Colors.indigo),
                triangleColor: Colors.indigo,
                child: _DemoButton(
                  icon: Icons.blur_on,
                  label: 'Tap me',
                  color: Colors.indigo,
                ),
              ),
            ),
            _DemoCard(
              label: 'Tap Outside',
              description: 'Dismiss only when tapping outside',
              child: WidgetTooltip(
                message: const Text('Tap outside tooltip to dismiss'),
                triggerMode: WidgetTooltipTriggerMode.tap,
                dismissMode: WidgetTooltipDismissMode.tapOutside,
                messageDecoration: _tooltipDecoration(Colors.green),
                triangleColor: Colors.green,
                child: _DemoButton(
                  icon: Icons.blur_circular,
                  label: 'Tap me',
                  color: Colors.green,
                ),
              ),
            ),
            _DemoCard(
              label: 'Tap Inside',
              description: 'Dismiss only when tapping the tooltip',
              child: WidgetTooltip(
                message: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tap this tooltip to dismiss'),
                      SizedBox(height: 4),
                      Icon(Icons.touch_app, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
                triggerMode: WidgetTooltipTriggerMode.tap,
                dismissMode: WidgetTooltipDismissMode.tapInside,
                messageDecoration: _tooltipDecoration(Colors.amber),
                triangleColor: Colors.amber,
                child: _DemoButton(
                  icon: Icons.center_focus_strong,
                  label: 'Tap me',
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// Directions Page
// ============================================================================

class DirectionsPage extends StatelessWidget {
  const DirectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionTitle('Tooltip Directions'),
        const SizedBox(height: 8),
        Text(
          'Control tooltip placement',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 48),
        // Vertical axis directions
        Center(
          child: Column(
            children: [
              Text(
                'Vertical Axis',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WidgetTooltip(
                    message: const Text('I appear on top!'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    direction: WidgetTooltipDirection.top,
                    messageDecoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    triangleColor: Colors.blue[700]!,
                    child: _DirectionButton(
                      icon: Icons.arrow_upward,
                      label: 'Top',
                    ),
                  ),
                  const SizedBox(width: 24),
                  WidgetTooltip(
                    message: const Text('I appear on bottom!'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    direction: WidgetTooltipDirection.bottom,
                    messageDecoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    triangleColor: Colors.green[700]!,
                    child: _DirectionButton(
                      icon: Icons.arrow_downward,
                      label: 'Bottom',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        // Horizontal axis directions
        Center(
          child: Column(
            children: [
              Text(
                'Horizontal Axis',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WidgetTooltip(
                    message: const Text('I appear on left!'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    direction: WidgetTooltipDirection.left,
                    axis: Axis.horizontal,
                    messageDecoration: BoxDecoration(
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    triangleColor: Colors.orange[700]!,
                    child: _DirectionButton(
                      icon: Icons.arrow_back,
                      label: 'Left',
                    ),
                  ),
                  const SizedBox(width: 24),
                  WidgetTooltip(
                    message: const Text('I appear on right!'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    direction: WidgetTooltipDirection.right,
                    axis: Axis.horizontal,
                    messageDecoration: BoxDecoration(
                      color: Colors.purple[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    triangleColor: Colors.purple[700]!,
                    child: _DirectionButton(
                      icon: Icons.arrow_forward,
                      label: 'Right',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Animations Page
// ============================================================================

class AnimationsPage extends StatelessWidget {
  const AnimationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionTitle('Animations'),
        const SizedBox(height: 8),
        Text(
          'Different animation styles',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _DemoCard(
              label: 'Fade',
              description: 'Default animation',
              child: WidgetTooltip(
                message: const Text('Fade animation'),
                triggerMode: WidgetTooltipTriggerMode.tap,
                animation: WidgetTooltipAnimation.fade,
                animationDuration: const Duration(milliseconds: 300),
                child: _AnimationButton(icon: Icons.gradient, label: 'Fade'),
              ),
            ),
            _DemoCard(
              label: 'Scale',
              description: 'Grows from anchor point',
              child: WidgetTooltip(
                message: const Text('Scale animation'),
                triggerMode: WidgetTooltipTriggerMode.tap,
                animation: WidgetTooltipAnimation.scale,
                animationDuration: const Duration(milliseconds: 300),
                child: _AnimationButton(icon: Icons.zoom_in, label: 'Scale'),
              ),
            ),
            _DemoCard(
              label: 'Scale + Fade',
              description: 'Combined effect',
              child: WidgetTooltip(
                message: const Text('Scale and fade animation'),
                triggerMode: WidgetTooltipTriggerMode.tap,
                animation: WidgetTooltipAnimation.scaleAndFade,
                animationDuration: const Duration(milliseconds: 300),
                child:
                    _AnimationButton(icon: Icons.auto_awesome, label: 'Both'),
              ),
            ),
            _DemoCard(
              label: 'None',
              description: 'Instant show/hide',
              child: WidgetTooltip(
                message: const Text('No animation'),
                triggerMode: WidgetTooltipTriggerMode.tap,
                animation: WidgetTooltipAnimation.none,
                child: _AnimationButton(icon: Icons.flash_on, label: 'Instant'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// Features Page
// ============================================================================

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionTitle('Special Features'),
        const SizedBox(height: 32),

        // Auto-Flip Feature
        _FeatureSection(
          title: 'Auto-Flip (Default)',
          description:
              'Tooltip automatically positions based on screen center. Target in top half → tooltip below, target in bottom half → tooltip above.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Auto (default)',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        WidgetTooltip(
                          message:
                              const Text('Position based on screen center'),
                          triggerMode: WidgetTooltipTriggerMode.tap,
                          autoFlip: true,
                          messageDecoration: _tooltipDecoration(Colors.teal),
                          triangleColor: Colors.teal,
                          child: _FeatureButton(
                            icon: Icons.swap_vert,
                            label: 'Auto Position',
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Fixed: Top',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        WidgetTooltip(
                          message: const Text('Always on top'),
                          triggerMode: WidgetTooltipTriggerMode.tap,
                          direction: WidgetTooltipDirection.top,
                          autoFlip: false,
                          messageDecoration: _tooltipDecoration(Colors.orange),
                          triangleColor: Colors.orange,
                          child: _FeatureButton(
                            icon: Icons.arrow_upward,
                            label: 'Fixed Top',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Fixed: Bottom',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        WidgetTooltip(
                          message: const Text('Always on bottom'),
                          triggerMode: WidgetTooltipTriggerMode.tap,
                          direction: WidgetTooltipDirection.bottom,
                          autoFlip: false,
                          messageDecoration: _tooltipDecoration(Colors.indigo),
                          triangleColor: Colors.indigo,
                          child: _FeatureButton(
                            icon: Icons.arrow_downward,
                            label: 'Fixed Bottom',
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 48),

        // Custom Styling
        _FeatureSection(
          title: 'Custom Styling',
          description: 'Fully customizable appearance',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              WidgetTooltip(
                message: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Success!'),
                  ],
                ),
                triggerMode: WidgetTooltipTriggerMode.tap,
                messageDecoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                triangleColor: Colors.green[600]!,
                messagePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _StyledChip(label: 'Success', color: Colors.green),
              ),
              WidgetTooltip(
                message: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.black87, size: 18),
                    SizedBox(width: 8),
                    Text('Warning!', style: TextStyle(color: Colors.black87)),
                  ],
                ),
                triggerMode: WidgetTooltipTriggerMode.tap,
                messageDecoration: BoxDecoration(
                  color: Colors.amber[400],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                triangleColor: Colors.amber[400]!,
                child: _StyledChip(label: 'Warning', color: Colors.amber),
              ),
              WidgetTooltip(
                message: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Error!'),
                  ],
                ),
                triggerMode: WidgetTooltipTriggerMode.tap,
                messageDecoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                triangleColor: Colors.red[600]!,
                child: _StyledChip(label: 'Error', color: Colors.red),
              ),
            ],
          ),
        ),

        const Divider(height: 48),

        // Rich Content
        _FeatureSection(
          title: 'Rich Content',
          description: 'Tooltips can contain any widget',
          child: Center(
            child: WidgetTooltip(
              message: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.indigo[100],
                            child:
                                const Icon(Icons.person, color: Colors.indigo),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Doe',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Software Engineer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'john@example.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              triggerMode: WidgetTooltipTriggerMode.tap,
              dismissMode: WidgetTooltipDismissMode.tapOutside,
              messageDecoration: const BoxDecoration(),
              messagePadding: EdgeInsets.zero,
              triangleColor: Colors.white,
              triangleSize: const Size(12, 8),
              child: const Chip(
                avatar: Icon(Icons.person, size: 18),
                label: Text('View Profile'),
              ),
            ),
          ),
        ),

        const Divider(height: 48),

        // Auto Dismiss
        _FeatureSection(
          title: 'Auto Dismiss',
          description: 'Automatically hides after a duration',
          child: Center(
            child: WidgetTooltip(
              message: const Text('I will disappear in 2 seconds...'),
              triggerMode: WidgetTooltipTriggerMode.tap,
              autoDismissDuration: const Duration(seconds: 2),
              messageDecoration: BoxDecoration(
                color: Colors.deepPurple[600],
                borderRadius: BorderRadius.circular(8),
              ),
              triangleColor: Colors.deepPurple[600]!,
              child: FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.timer),
                label: const Text('2s Auto Dismiss'),
              ),
            ),
          ),
        ),

        const SizedBox(height: 48),
      ],
    );
  }
}

// ============================================================================
// Helper Widgets
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String label;
  final String? description;
  final Widget child;

  const _DemoCard({
    required this.label,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        children: [
          child,
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DemoButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DirectionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AnimationButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AnimationButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[400]!, Colors.purple[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _FeatureSection({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledChip extends StatelessWidget {
  final String label;
  final MaterialColor color;

  const _StyledChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      labelStyle: TextStyle(color: color[700]),
    );
  }
}
