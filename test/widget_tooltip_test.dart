import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

void main() {
  group('WidgetTooltip', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: WidgetTooltip(
                message: Text('Tooltip message'),
                child: Text('Target'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Tooltip message'), findsNothing);
    });

    group('TriggerMode', () {
      testWidgets('tap shows tooltip', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('longPress shows tooltip', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.longPress,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.longPress(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('doubleTap shows tooltip', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.doubleTap,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('manual mode does not show on tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.manual,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsNothing);
      });
    });

    group('TooltipController', () {
      testWidgets('show() displays tooltip', (WidgetTester tester) async {
        final controller = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  controller: controller,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Tooltip message'), findsNothing);

        controller.show();
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('dismiss() hides tooltip', (WidgetTester tester) async {
        final controller = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  controller: controller,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        controller.show();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        controller.dismiss();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsNothing);
      });

      testWidgets('toggle() toggles tooltip visibility',
          (WidgetTester tester) async {
        final controller = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  controller: controller,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        expect(controller.isShow, isFalse);

        controller.toggle();
        await tester.pumpAndSettle();
        expect(controller.isShow, isTrue);
        expect(find.text('Tooltip message'), findsOneWidget);

        controller.toggle();
        await tester.pumpAndSettle();
        expect(controller.isShow, isFalse);
        expect(find.text('Tooltip message'), findsNothing);
      });
    });

    group('DismissMode', () {
      testWidgets('tapAnyWhere dismisses on tap inside',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapAnyWhere,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        // Show tooltip
        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        // Tap on tooltip to dismiss
        await tester.tap(find.text('Tooltip message'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsNothing);
      });

      testWidgets('tapInside only dismisses on tap inside tooltip',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapInside,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        // Show tooltip
        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        // Tap inside tooltip to dismiss
        await tester.tap(find.text('Tooltip message'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsNothing);
      });

      testWidgets('manual mode does not dismiss on tap',
          (WidgetTester tester) async {
        final controller = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  controller: controller,
                  dismissMode: WidgetTooltipDismissMode.manual,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        controller.show();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        // Tap on tooltip - should NOT dismiss
        await tester.tap(find.text('Tooltip message'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        // Only controller can dismiss
        controller.dismiss();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsNothing);
      });
    });

    group('Direction', () {
      testWidgets('respects direction parameter', (WidgetTester tester) async {
        for (final direction in WidgetTooltipDirection.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: WidgetTooltip(
                    message: Text('Tooltip $direction'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    direction: direction,
                    child: const Text('Target'),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Target'));
          await tester.pumpAndSettle();

          expect(find.text('Tooltip $direction'), findsOneWidget);

          // Dismiss for next iteration
          await tester.tapAt(Offset.zero);
          await tester.pumpAndSettle();
        }
      });
    });

    group('Animation', () {
      testWidgets('fade animation works', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.fade,
                  animationDuration: Duration(milliseconds: 300),
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // Animation should be in progress
        expect(find.text('Tooltip message'), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('scale animation works', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.scale,
                  animationDuration: Duration(milliseconds: 300),
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('none animation shows immediately',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.none,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pump();

        expect(find.text('Tooltip message'), findsOneWidget);
      });
    });

    group('Callbacks', () {
      testWidgets('onShow is called when tooltip shows',
          (WidgetTester tester) async {
        bool showCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  onShow: () => showCalled = true,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(showCalled, isTrue);
      });

      testWidgets('onDismiss is called when tooltip hides',
          (WidgetTester tester) async {
        bool dismissCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapAnyWhere,
                  onDismiss: () => dismissCalled = true,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tooltip message'));
        await tester.pumpAndSettle();

        expect(dismissCalled, isTrue);
      });
    });

    group('AutoDismiss', () {
      testWidgets('auto dismisses after duration', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  autoDismissDuration: Duration(seconds: 2),
                  animation: WidgetTooltipAnimation.none,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pump();
        expect(find.text('Tooltip message'), findsOneWidget);

        // Wait for auto dismiss
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsNothing);
      });
    });

    group('Customization', () {
      testWidgets('applies custom decoration', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  messageDecoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('applies custom padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  messagePadding: EdgeInsets.all(32),
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });
    });

    group('Axis', () {
      testWidgets('vertical axis positions tooltip above/below',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  axis: Axis.vertical,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('horizontal axis positions tooltip left/right',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  axis: Axis.horizontal,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });
    });
  });
}
