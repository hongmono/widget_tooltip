import 'package:flutter/material.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

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

/// Full demo page for the widget_tooltip package.
class WidgetTooltipDemo extends StatefulWidget {
  const WidgetTooltipDemo({super.key});

  @override
  State<WidgetTooltipDemo> createState() => _WidgetTooltipDemoState();
}

class _WidgetTooltipDemoState extends State<WidgetTooltipDemo>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
            Tab(text: 'ListView'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TriggerModesPage(),
          _DismissModesPage(),
          _DirectionsPage(),
          _AnimationsPage(),
          _FeaturesPage(),
          _ListViewPage(),
        ],
      ),
    );
  }
}

// ============================================================================
// Trigger Modes Page
// ============================================================================

class _TriggerModesPage extends StatefulWidget {
  const _TriggerModesPage();

  @override
  State<_TriggerModesPage> createState() => _TriggerModesPageState();
}

class _TriggerModesPageState extends State<_TriggerModesPage> {
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

class _DismissModesPage extends StatelessWidget {
  const _DismissModesPage();

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

class _DirectionsPage extends StatelessWidget {
  const _DirectionsPage();

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
        Center(
          child: Column(
            children: [
              Text('Vertical Axis',
                  style: Theme.of(context).textTheme.titleSmall),
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
                        icon: Icons.arrow_upward, label: 'Top'),
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
                        icon: Icons.arrow_downward, label: 'Bottom'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: Column(
            children: [
              Text('Horizontal Axis',
                  style: Theme.of(context).textTheme.titleSmall),
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
                        icon: Icons.arrow_back, label: 'Left'),
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
                        icon: Icons.arrow_forward, label: 'Right'),
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

class _AnimationsPage extends StatelessWidget {
  const _AnimationsPage();

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
                child:
                    _AnimationButton(icon: Icons.flash_on, label: 'Instant'),
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

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionTitle('Special Features'),
        const SizedBox(height: 32),

        // TooltipGroup Feature
        _FeatureSection(
          title: 'Tooltip Group (New in 1.3.0)',
          description:
              'Only one tooltip visible at a time within a group. Showing one auto-dismisses others.',
          child: const _TooltipGroupDemo(),
        ),

        const Divider(height: 48),

        // Auto-Flip Feature
        _FeatureSection(
          title: 'Auto-Flip (Default)',
          description:
              'Tooltip automatically positions based on screen center.',
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Auto',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    WidgetTooltip(
                      message: const Text('Position based on screen center'),
                      triggerMode: WidgetTooltipTriggerMode.tap,
                      autoFlip: true,
                      messageDecoration: _tooltipDecoration(Colors.teal),
                      triangleColor: Colors.teal,
                      child: _FeatureButton(
                        icon: Icons.swap_vert,
                        label: 'Auto',
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
                        label: 'Top',
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
                        label: 'Bottom',
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
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
                              Text('John Doe',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Software Engineer',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
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
                          Icon(Icons.email,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('john@example.com',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
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

/// Demo for the new TooltipGroup feature.
class _TooltipGroupDemo extends StatefulWidget {
  const _TooltipGroupDemo();

  @override
  State<_TooltipGroupDemo> createState() => _TooltipGroupDemoState();
}

class _TooltipGroupDemoState extends State<_TooltipGroupDemo> {
  final _group = TooltipGroup();
  late final _c1 = TooltipController(group: _group);
  late final _c2 = TooltipController(group: _group);
  late final _c3 = TooltipController(group: _group);

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        WidgetTooltip(
          message: const Text('Only one visible!'),
          controller: _c1,
          triggerMode: WidgetTooltipTriggerMode.tap,
          messageDecoration: _tooltipDecoration(Colors.blue),
          triangleColor: Colors.blue,
          child:
              _FeatureButton(icon: Icons.looks_one, label: 'A', color: Colors.blue),
        ),
        WidgetTooltip(
          message: const Text('Others auto-dismiss!'),
          controller: _c2,
          triggerMode: WidgetTooltipTriggerMode.tap,
          messageDecoration: _tooltipDecoration(Colors.green),
          triangleColor: Colors.green,
          child: _FeatureButton(
              icon: Icons.looks_two, label: 'B', color: Colors.green),
        ),
        WidgetTooltip(
          message: const Text('Try tapping each one!'),
          controller: _c3,
          triggerMode: WidgetTooltipTriggerMode.tap,
          messageDecoration: _tooltipDecoration(Colors.orange),
          triangleColor: Colors.orange,
          child: _FeatureButton(
              icon: Icons.looks_3, label: 'C', color: Colors.orange),
        ),
      ],
    );
  }
}

// ============================================================================
// ListView Page
// ============================================================================

class _ListViewPage extends StatelessWidget {
  const _ListViewPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionTitle('ListView Direction Test'),
        const SizedBox(height: 8),
        Text(
          'All tooltips appear above (direction: top). Scroll dismisses them automatically.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final colors = [
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.teal,
              Colors.pink,
              Colors.indigo,
              Colors.red,
              Colors.cyan,
              Colors.amber,
            ];
            final color = colors[index % colors.length];

            return WidgetTooltip(
              message: Text(
                'Tooltip for Item $index (above)',
                style: const TextStyle(color: Colors.white),
              ),
              triggerMode: WidgetTooltipTriggerMode.tap,
              direction: WidgetTooltipDirection.top,
              messageDecoration: _tooltipDecoration(color),
              triangleColor: color,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: color),
                    const SizedBox(width: 8),
                    Text(
                      'Item $index — Tap me',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: 15,
        ),
      ],
    );
  }
}

// ============================================================================
// Shared Helper Widgets
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
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(description!,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center),
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
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
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500)),
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
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
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description,
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
