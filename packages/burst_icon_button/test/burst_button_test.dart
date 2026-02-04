import 'package:burst_icon_button/burst_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

void main() {
  group('BurstIconButton', () {
    testWidgets('renders the default icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {},
        ),
      ));

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows pressedIcon on tap down', (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          pressedIcon: const Icon(Icons.favorite),
          burstIcon: const Icon(Icons.heart_broken),
          onPressed: () {},
        ),
      ));

      // Simulate tap down. We need to pump long enough for the gesture
      // arena to recognize the tap-down but not long enough for a long press.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GestureDetector)),
      );
      // Pump past kPressTimeout (100ms) so the tap-down is recognized
      // by the gesture arena (competing with long press recognizer).
      await tester.pump(const Duration(milliseconds: 150));

      // The pressed icon should be shown.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      // Release the tap.
      await gesture.up();
      await tester.pump();

      // Back to default icon (burst icon also spawned but different).
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () => pressed = true,
        ),
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('tap creates a burst icon that animates away',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          burstIcon: const Icon(Icons.favorite, color: Colors.red),
          duration: const Duration(milliseconds: 500),
          onPressed: () {},
        ),
      ));

      // Before tap, only default icon.
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap to trigger burst.
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Burst icon should now appear (default icon + burst icon).
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Advance past the animation duration.
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Burst icon should be gone after animation completes.
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('long press creates continuous burst icons', (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.star_border),
          burstIcon: const Icon(Icons.star, color: Colors.amber),
          throttleDuration: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 2000),
          onPressed: () {},
        ),
      ));

      // Long press start.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GestureDetector)),
      );
      // Wait for the long press to be recognized.
      await tester.pump(const Duration(milliseconds: 500));

      // Now we should see burst icons appearing.
      // Pump a few throttle intervals to spawn multiple bursts.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Multiple burst icons should exist.
      expect(find.byIcon(Icons.star).evaluate().length, greaterThan(0));

      // Release long press.
      await gesture.up();
      await tester.pumpAndSettle(const Duration(milliseconds: 2500));

      // All burst icons should animate away.
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('uses icon as burst icon when burstIcon is null',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.thumb_up),
          duration: const Duration(milliseconds: 500),
          onPressed: () {},
        ),
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // The default icon is used for burst, so we should find 2 instances
      // (one button + one burst).
      expect(find.byIcon(Icons.thumb_up), findsNWidgets(2));

      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('burstCount spawns multiple icons per tap', (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          burstIcon: const Icon(Icons.favorite, color: Colors.red),
          burstCount: 3,
          duration: const Duration(milliseconds: 500),
          onPressed: () {},
        ),
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Should have 3 burst icons.
      expect(find.byIcon(Icons.favorite), findsNWidgets(3));

      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('onTapCancel resets pressed state', (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          pressedIcon: const Icon(Icons.favorite),
          onPressed: () {},
        ),
      ));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GestureDetector)),
      );
      // Pump past kPressTimeout so tap-down is recognized.
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Cancel the gesture.
      await gesture.cancel();
      await tester.pump();
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('disposes cleanly without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          burstIcon: const Icon(Icons.favorite),
          duration: const Duration(milliseconds: 1000),
          onPressed: () {},
        ),
      ));

      // Trigger a burst so we have active controllers.
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Replace the widget tree (triggers dispose) while animation is in
      // progress.
      await tester.pumpWidget(buildTestApp(const SizedBox()));
      await tester.pumpAndSettle();

      // No errors should have occurred.
    });

    testWidgets('handles null onPressed gracefully', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const BurstIconButton(
          icon: Icon(Icons.favorite_border),
          onPressed: null,
        ),
      ));

      // Tap should not throw.
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();
    });

    testWidgets('custom crossAmplitude and burstDistance are applied',
        (tester) async {
      // This test mainly ensures custom values don't cause errors.
      await tester.pumpWidget(buildTestApp(
        BurstIconButton(
          icon: const Icon(Icons.favorite_border),
          burstIcon: const Icon(Icons.favorite),
          crossAmplitude: 50.0,
          burstDistance: 200.0,
          duration: const Duration(milliseconds: 300),
          onPressed: () {},
        ),
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.favorite), findsNothing);
    });
  });
}
