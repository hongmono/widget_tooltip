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

        final semanticsWithLabel = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.liveRegion == true,
        );
        expect(semanticsWithLabel, findsNothing);

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();

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
  });
}
