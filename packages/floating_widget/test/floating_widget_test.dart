import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_widget/floating_widget.dart';

Widget buildApp({
  Offset initialPosition = Offset.zero,
  FloatingAlignment? initialAlignment,
  EdgeInsets padding = EdgeInsets.zero,
  bool snapToEdge = false,
  ValueChanged<Offset>? onPositionChanged,
  Widget? floatingWidget,
}) {
  return MaterialApp(
    home: FloatingWidget(
      initialPosition: initialPosition,
      initialAlignment: initialAlignment,
      padding: padding,
      snapToEdge: snapToEdge,
      onPositionChanged: onPositionChanged,
      floatingWidget: floatingWidget ??
          Container(
            key: const Key('floating'),
            width: 56,
            height: 56,
            color: Colors.blue,
          ),
      child: Container(
        key: const Key('content'),
        color: Colors.white,
        child: const Center(child: Text('Content')),
      ),
    ),
  );
}

void main() {
  group('FloatingWidget', () {
    testWidgets('renders floating widget and child', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Content'), findsOneWidget);
      expect(find.byKey(const Key('floating')), findsOneWidget);
    });

    testWidgets('uses initialPosition', (tester) async {
      await tester.pumpWidget(buildApp(
        initialPosition: const Offset(100, 200),
      ));
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(
        find.byType(Positioned),
      ).last;
      expect(positioned.left, 100);
      expect(positioned.top, 200);
    });

    testWidgets('drag updates position', (tester) async {
      await tester.pumpWidget(buildApp(
        initialPosition: const Offset(100, 100),
      ));
      await tester.pumpAndSettle();

      // Use timedDragFrom to simulate the gesture at the exact position
      final center = tester.getCenter(find.byKey(const Key('floating')));
      await tester.timedDragFrom(
        center,
        const Offset(50, 30),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(
        find.byType(Positioned),
      ).last;
      expect(positioned.left, closeTo(150, 2));
      expect(positioned.top, closeTo(130, 2));
    });

    testWidgets('clamps position to screen bounds', (tester) async {
      await tester.pumpWidget(buildApp(
        initialPosition: const Offset(10, 10),
        padding: const EdgeInsets.all(20),
      ));
      await tester.pumpAndSettle();

      // Drag far to the left/top (beyond bounds)
      final center = tester.getCenter(find.byKey(const Key('floating')));
      await tester.timedDragFrom(
        center,
        const Offset(-500, -500),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(
        find.byType(Positioned),
      ).last;
      expect(positioned.left! >= 20, isTrue);
      expect(positioned.top! >= 20, isTrue);
    });

    testWidgets('snapToEdge snaps to nearest horizontal edge', (tester) async {
      // Screen is 800x600 in tests
      await tester.pumpWidget(buildApp(
        initialPosition: const Offset(300, 200),
        snapToEdge: true,
        padding: const EdgeInsets.all(16),
      ));
      await tester.pumpAndSettle();

      // Drag slightly right then release
      final center = tester.getCenter(find.byKey(const Key('floating')));
      await tester.timedDragFrom(
        center,
        const Offset(10, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(
        find.byType(Positioned),
      ).last;

      // Center of 800 is ~400, widget at ~310 should snap to left edge (16)
      // midpoint = (16 + 728) / 2 = 372, 310 < 372 => snaps left
      expect(positioned.left, closeTo(16, 2));
    });

    testWidgets('onPositionChanged is called after drag', (tester) async {
      Offset? lastPosition;
      await tester.pumpWidget(buildApp(
        initialPosition: const Offset(100, 100),
        onPositionChanged: (pos) => lastPosition = pos,
      ));
      await tester.pumpAndSettle();

      final center = tester.getCenter(find.byKey(const Key('floating')));
      await tester.timedDragFrom(
        center,
        const Offset(50, 50),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(lastPosition, isNotNull);
    });

    testWidgets('initialAlignment positions widget correctly', (tester) async {
      await tester.pumpWidget(buildApp(
        initialAlignment: FloatingAlignment.topLeft,
        padding: const EdgeInsets.all(10),
      ));
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(
        find.byType(Positioned),
      ).last;
      expect(positioned.left, closeTo(10, 1));
      expect(positioned.top, closeTo(10, 1));
    });

    testWidgets('disposes animation controller without error', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Replace with a different widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Text('Replaced')),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Replaced'), findsOneWidget);
    });

    testWidgets('snapToEdge false does not snap', (tester) async {
      await tester.pumpWidget(buildApp(
        initialPosition: const Offset(200, 200),
        snapToEdge: false,
      ));
      await tester.pumpAndSettle();

      final center = tester.getCenter(find.byKey(const Key('floating')));
      await tester.timedDragFrom(
        center,
        const Offset(30, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(
        find.byType(Positioned),
      ).last;
      // Should stay near 230, not snap to edge
      expect(positioned.left, closeTo(230, 5));
    });
  });
}
