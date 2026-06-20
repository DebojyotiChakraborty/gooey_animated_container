// Regression tests for the draggable gooey context menu.
//
// The key guarantee here is that opening/closing plays the gooey *morph*
// (a spring animation spanning many frames) rather than snapping instantly
// between states.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

import 'package:gooey_animated_container/gooey_menu.dart';

void main() {
  Widget harness() => const MaterialApp(home: Scaffold(body: GooeyMenu()));

  testWidgets('opening the menu animates the morph instead of snapping', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    // The collapsed trigger is on screen and the menu starts closed.
    expect(find.byIcon(Iconsax.more), findsOneWidget);

    // Tap to open.
    await tester.tap(find.byIcon(Iconsax.more));
    await tester.pump(); // process setState + kick off the toggle

    // If the morph snapped (e.g. the Cue element was recreated), the controller
    // would jump straight to the end with no frame scheduled. A real spring
    // keeps scheduling frames.
    expect(
      tester.binding.hasScheduledFrame,
      isTrue,
      reason: 'opening should be animating, not snapped to the end state',
    );

    // Still animating a few frames later (didn't finish in one frame)...
    await tester.pump(const Duration(milliseconds: 32));
    expect(
      tester.binding.hasScheduledFrame,
      isTrue,
      reason: 'the open morph should progress across multiple frames',
    );

    // ...and it eventually settles.
    final settleFrames = await tester.pumpAndSettle();
    expect(settleFrames, greaterThan(2));
  });

  testWidgets('tapping outside animates the menu closed', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    await tester.tap(find.byIcon(Iconsax.more));
    await tester.pumpAndSettle();

    // Tap an empty corner, far from the centered menu, to dismiss.
    await tester.tapAt(const Offset(8, 8));
    await tester.pump();

    expect(
      tester.binding.hasScheduledFrame,
      isTrue,
      reason: 'closing should be animating, not snapped to the end state',
    );

    await tester.pumpAndSettle();
  });
}
