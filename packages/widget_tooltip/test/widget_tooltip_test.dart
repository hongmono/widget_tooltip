import 'package:flutter/gestures.dart';
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

      testWidgets('hover shows and hides tooltip on mouse enter/exit',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.hover,
                  animation: WidgetTooltipAnimation.none,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        // Create a mouse and hover over target
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        // Move mouse to target
        final targetCenter = tester.getCenter(find.text('Target'));
        await gesture.moveTo(targetCenter);
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);

        // Move mouse away from target
        await gesture.moveTo(Offset.zero);
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
      testWidgets('tapAnywhere dismisses on tap inside',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapAnywhere,
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

      testWidgets('scaleAndFade animation works', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  animation: WidgetTooltipAnimation.scaleAndFade,
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
                  dismissMode: WidgetTooltipDismissMode.tapAnywhere,
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

    group('AutoFlip', () {
      testWidgets('autoFlip positions tooltip based on screen position',
          (WidgetTester tester) async {
        // Test with target at top of screen - tooltip should appear below
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: WidgetTooltip(
                    message: Text('Tooltip message'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    autoFlip: true,
                    child: Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('autoFlip false respects explicit direction',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  autoFlip: false,
                  direction: WidgetTooltipDirection.bottom,
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

    group('autoFlip behavior', () {
      testWidgets(
          'autoFlip false without direction defaults to showing below',
          (WidgetTester tester) async {
        final controller = TooltipController();

        // Place target at bottom of screen — without autoFlip,
        // tooltip should still appear below (default), not flip to top.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: WidgetTooltip(
                    message: const Text('Tooltip message'),
                    controller: controller,
                    autoFlip: false,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        controller.show();
        await tester.pumpAndSettle();

        // Tooltip should be visible (rendered below target as default)
        expect(find.text('Tooltip message'), findsOneWidget);

        // Verify the tooltip is positioned below the target
        final targetBox =
            tester.renderObject(find.text('Target')) as RenderBox;
        final targetPos = targetBox.localToGlobal(Offset.zero);

        final tooltipBox =
            tester.renderObject(find.text('Tooltip message')) as RenderBox;
        final tooltipPos = tooltipBox.localToGlobal(Offset.zero);

        // Tooltip top should be at or below the target bottom
        expect(tooltipPos.dy, greaterThanOrEqualTo(targetPos.dy));
      });

      testWidgets(
          'autoFlip false with direction top always shows above regardless of position',
          (WidgetTester tester) async {
        final controller = TooltipController();

        // Place target near top of screen — with autoFlip: false + direction: top,
        // it should still show above, not flip.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: WidgetTooltip(
                    message: const Text('Tooltip message'),
                    controller: controller,
                    autoFlip: false,
                    direction: WidgetTooltipDirection.top,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        controller.show();
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);

        // Verify the tooltip is positioned above the target
        final targetBox =
            tester.renderObject(find.text('Target')) as RenderBox;
        final targetPos = targetBox.localToGlobal(Offset.zero);

        final tooltipBox =
            tester.renderObject(find.text('Tooltip message')) as RenderBox;
        final tooltipPos = tooltipBox.localToGlobal(Offset.zero);

        // Tooltip bottom should be at or above the target top
        expect(tooltipPos.dy + tooltipBox.size.height,
            lessThanOrEqualTo(targetPos.dy + 20)); // allow some padding
      });

      testWidgets(
          'autoFlip true (default) auto-positions based on screen center',
          (WidgetTester tester) async {
        final controller = TooltipController();

        // Place target at top of screen — with autoFlip: true (default),
        // it should auto-position below the target since it's in the top half.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: WidgetTooltip(
                    message: const Text('Tooltip message'),
                    controller: controller,
                    autoFlip: true,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        controller.show();
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);

        // Verify the tooltip is positioned below the target (auto-flipped to bottom)
        final targetBox =
            tester.renderObject(find.text('Target')) as RenderBox;
        final targetPos = targetBox.localToGlobal(Offset.zero);

        final tooltipBox =
            tester.renderObject(find.text('Tooltip message')) as RenderBox;
        final tooltipPos = tooltipBox.localToGlobal(Offset.zero);

        // Tooltip should be below the target
        expect(tooltipPos.dy, greaterThanOrEqualTo(targetPos.dy));
      });
    });

    group('Direction with autoFlip (Issue #7)', () {
      testWidgets(
          'direction top is respected with autoFlip true in top half of screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: WidgetTooltip(
                    message: Text('Tooltip message'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    direction: WidgetTooltipDirection.top,
                    autoFlip: true,
                    animation: WidgetTooltipAnimation.none,
                    child: Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets(
          'direction top is respected in ListView items',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  return WidgetTooltip(
                    message: Text('Tooltip $index'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    direction: WidgetTooltipDirection.top,
                    animation: WidgetTooltipAnimation.none,
                    child: Container(
                      height: 100.0,
                      width: double.infinity,
                      color: Colors.blue,
                      child: Text('Item $index'),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16.0);
                },
                itemCount: 20,
              ),
            ),
          ),
        );

        // Tap first item (top of screen)
        await tester.tap(find.text('Item 0'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip 0'), findsOneWidget);

        // Dismiss
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Tap second item
        await tester.tap(find.text('Item 1'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip 1'), findsOneWidget);
      });
    });

    group('DismissMode tapOutside', () {
      testWidgets('tapOutside dismisses only on tap outside tooltip',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  dismissMode: WidgetTooltipDismissMode.tapOutside,
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

        // Tap outside to dismiss
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsNothing);
      });
    });

    group('Triangle', () {
      testWidgets('triangle is rendered with tooltip',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  triangleColor: Colors.red,
                  triangleSize: Size(20, 20),
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsOneWidget);
        // Triangle is rendered as part of the overlay
      });
    });

    group('Controller reuse', () {
      testWidgets('controller can be reused after widget rebuild',
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

        controller.show();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        controller.dismiss();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsNothing);

        // Rebuild widget and reuse controller
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message updated'),
                  controller: controller,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        controller.show();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message updated'), findsOneWidget);
      });
    });

    group('RTL support', () {
      testWidgets('tooltip shows correctly in RTL layout',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: WidgetTooltip(
                    message: Text('RTL Tooltip'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    animation: WidgetTooltipAnimation.none,
                    child: Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('RTL Tooltip'), findsOneWidget);
      });

      testWidgets('tooltip shows correctly in RTL with horizontal axis',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: WidgetTooltip(
                    message: Text('RTL Horizontal Tooltip'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    axis: Axis.horizontal,
                    animation: WidgetTooltipAnimation.none,
                    child: Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('RTL Horizontal Tooltip'), findsOneWidget);
      });

      testWidgets('RTL with EdgeInsetsDirectional padding resolves correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: WidgetTooltip(
                    message: Text('RTL Padded Tooltip'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    padding: EdgeInsetsDirectional.only(start: 20, end: 10),
                    animation: WidgetTooltipAnimation.none,
                    child: Text('Target'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        expect(find.text('RTL Padded Tooltip'), findsOneWidget);
      });

      testWidgets('RTL with explicit direction is respected',
          (WidgetTester tester) async {
        for (final direction in WidgetTooltipDirection.values) {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: WidgetTooltip(
                      message: Text('RTL $direction'),
                      triggerMode: WidgetTooltipTriggerMode.tap,
                      direction: direction,
                      animation: WidgetTooltipAnimation.none,
                      child: const Text('Target'),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Target'));
          await tester.pumpAndSettle();

          expect(find.text('RTL $direction'), findsOneWidget);

          // Dismiss for next iteration
          await tester.tapAt(Offset.zero);
          await tester.pumpAndSettle();
        }
      });
    });


    group('Accessibility', () {
      testWidgets('child has Semantics with label when semanticLabel is set',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  semanticLabel: 'Help tooltip',
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        // Verify Semantics widget wraps the child with the label
        final semantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Help tooltip',
        );
        expect(semantics, findsOneWidget);
      });

      testWidgets(
          'child has long press hint when trigger mode is longPress',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  semanticLabel: 'Help tooltip',
                  triggerMode: WidgetTooltipTriggerMode.longPress,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        final semantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.hint == 'Long press to show tooltip',
        );
        expect(semantics, findsOneWidget);
      });

      testWidgets(
          'tooltip overlay has Semantics when semanticLabel is provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: Text('Tooltip message'),
                  semanticLabel: 'Help tooltip',
                  triggerMode: WidgetTooltipTriggerMode.tap,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        // The overlay should contain a Semantics widget with liveRegion
        final semantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.liveRegion == true &&
              widget.properties.label == 'Help tooltip',
        );
        expect(semantics, findsOneWidget);
      });

      testWidgets('no Semantics wrapper when semanticLabel is null',
          (WidgetTester tester) async {
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

        // No Semantics with liveRegion should exist before showing
        final semanticsWithLabel = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.liveRegion == true,
        );
        expect(semanticsWithLabel, findsNothing);

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

        // Still no liveRegion Semantics since no label was provided
        expect(semanticsWithLabel, findsNothing);
      });
    });

    group('Edge cases', () {
      testWidgets('rapid show/dismiss does not cause errors',
          (WidgetTester tester) async {
        final controller = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  controller: controller,
                  animation: WidgetTooltipAnimation.none,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        // Rapid toggling
        for (int i = 0; i < 5; i++) {
          controller.show();
          await tester.pump();
          controller.dismiss();
          await tester.pump();
        }

        await tester.pumpAndSettle();
        // Should end in dismissed state
        expect(find.text('Tooltip message'), findsNothing);
      });

      testWidgets('widget disposal during animation does not cause errors',
          (WidgetTester tester) async {
        final controller = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetTooltip(
                  message: const Text('Tooltip message'),
                  controller: controller,
                  animationDuration: const Duration(milliseconds: 500),
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        );

        controller.show();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Dispose widget during animation
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('No tooltip'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // No errors should occur
        expect(find.text('No tooltip'), findsOneWidget);
      });
    });

    group('TooltipGroup', () {
      testWidgets('showing one tooltip dismisses others in the same group',
          (WidgetTester tester) async {
        final group = TooltipGroup();
        final controller1 = TooltipController(group: group);
        final controller2 = TooltipController(group: group);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  WidgetTooltip(
                    message: const Text('Tooltip 1'),
                    controller: controller1,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target 1'),
                  ),
                  WidgetTooltip(
                    message: const Text('Tooltip 2'),
                    controller: controller2,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target 2'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Show first tooltip
        controller1.show();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip 1'), findsOneWidget);

        // Show second tooltip — first should be dismissed
        controller2.show();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip 2'), findsOneWidget);
        expect(find.text('Tooltip 1'), findsNothing);
        expect(controller1.isShow, isFalse);
      });

      testWidgets('dismissAll dismisses all tooltips in the group',
          (WidgetTester tester) async {
        final group = TooltipGroup();
        final controller1 = TooltipController(group: group);
        final controller2 = TooltipController(group: group);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  WidgetTooltip(
                    message: const Text('Tooltip 1'),
                    controller: controller1,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target 1'),
                  ),
                  WidgetTooltip(
                    message: const Text('Tooltip 2'),
                    controller: controller2,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target 2'),
                  ),
                ],
              ),
            ),
          ),
        );

        controller1.show();
        await tester.pumpAndSettle();

        group.dismissAll();
        await tester.pumpAndSettle();

        expect(find.text('Tooltip 1'), findsNothing);
        expect(controller1.isShow, isFalse);
      });

      testWidgets('controllers without group are independent',
          (WidgetTester tester) async {
        final controller1 = TooltipController();
        final controller2 = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  WidgetTooltip(
                    message: const Text('Tooltip 1'),
                    controller: controller1,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target 1'),
                  ),
                  WidgetTooltip(
                    message: const Text('Tooltip 2'),
                    controller: controller2,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target 2'),
                  ),
                ],
              ),
            ),
          ),
        );

        controller1.show();
        await tester.pumpAndSettle();
        controller2.show();
        await tester.pumpAndSettle();

        // Both should be visible — no group linking
        expect(find.text('Tooltip 1'), findsOneWidget);
        expect(find.text('Tooltip 2'), findsOneWidget);
      });
    });

    group('DismissOnScroll', () {
      testWidgets('tooltip dismisses when scrollable scrolls',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  const SizedBox(height: 200),
                  WidgetTooltip(
                    message: const Text('Tooltip message'),
                    triggerMode: WidgetTooltipTriggerMode.tap,
                    animation: WidgetTooltipAnimation.none,
                    child: const Text('Target'),
                  ),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        // Scroll
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pumpAndSettle();

        expect(find.text('Tooltip message'), findsNothing);
      });

      testWidgets('dismissOnScroll false keeps tooltip on scroll',
          (WidgetTester tester) async {
        final controller = TooltipController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  const SizedBox(height: 200),
                  WidgetTooltip(
                    message: const Text('Tooltip message'),
                    controller: controller,
                    dismissMode: WidgetTooltipDismissMode.manual,
                    animation: WidgetTooltipAnimation.none,
                    dismissOnScroll: false,
                    child: const Text('Target'),
                  ),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        );

        controller.show();
        await tester.pumpAndSettle();
        expect(find.text('Tooltip message'), findsOneWidget);

        // Scroll
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pumpAndSettle();

        // Should still be visible
        expect(find.text('Tooltip message'), findsOneWidget);
      });
    });
  });
}
