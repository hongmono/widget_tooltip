import 'package:flutter/material.dart';

import 'packages/burst_icon_button/burst_icon_button_demo.dart';
import 'packages/floating_widget/floating_widget_demo.dart';
import 'packages/widget_tooltip/widget_tooltip_demo.dart';

void main() {
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Packages Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/widget_tooltip': (_) => const WidgetTooltipDemo(),
        '/burst_icon_button': (_) => const BurstIconButtonDemo(),
        '/floating_widget': (_) => const FloatingWidgetDemo(),
      },
    );
  }
}

/// Landing page listing all available package demos.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _packages = <_PackageInfo>[
    _PackageInfo(
      name: 'widget_tooltip',
      description: 'A highly customizable tooltip widget for Flutter',
      route: '/widget_tooltip',
      icon: Icons.chat_bubble_outline,
      color: Colors.indigo,
      version: '1.3.0',
    ),
    _PackageInfo(
      name: 'burst_icon_button',
      description: 'Icon button with burst animation on tap/long-press',
      route: '/burst_icon_button',
      icon: Icons.favorite,
      color: Colors.red,
      version: '0.2.0',
    ),
    _PackageInfo(
      name: 'floating_widget',
      description: 'A draggable floating widget with boundary constraints',
      route: '/floating_widget',
      icon: Icons.drag_indicator,
      color: Colors.teal,
      version: '0.1.0',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Flutter Packages'),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: _packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pkg = _packages[index];
                return _PackageCard(info: pkg);
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'by hongmono',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageInfo {
  const _PackageInfo({
    required this.name,
    required this.description,
    required this.route,
    required this.icon,
    required this.color,
    required this.version,
  });

  final String name;
  final String description;
  final String route;
  final IconData icon;
  final Color color;
  final String version;
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.info});

  final _PackageInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: info.color.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, info.route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(info.icon, color: info.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          info.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: info.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'v${info.version}',
                            style: TextStyle(
                              fontSize: 11,
                              color: info.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
