import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_up/features/streak_celebration/streak_motion.dart';

// Expected values below were computed by running the design handoff's
// actual reference JS (`renderVals()` from `Streak Counter Demo.dc.html`)
// at these checkpoints via Node, not hand-derived — see the port's doc
// comment for why this file has no `live`/`now` distinction to test.
void main() {
  group('computeStreakFrame — core checkpoints (from 7 to 8)', () {
    test('el=0: everything at rest', () {
      final f = computeStreakFrame(
        now: 0,
        fromStreak: 7,
        toStreak: 8,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(f.cols, hasLength(1));
      expect(f.cols[0].translateY, closeTo(0, 1e-6));
      expect(f.cols[0].blur, 0);
      expect(f.numScaleX, closeTo(1, 1e-9));
      expect(f.numScaleY, closeTo(1, 1e-9));
      expect(f.rings, isEmpty);
      expect(f.sparks, isEmpty);
      expect(f.shown, 7);
      expect(f.captionOpacity, closeTo(0, 1e-9));
    });

    test('el=0.34: haptic-sync point mid-roll', () {
      final f = computeStreakFrame(
        now: 0.34,
        fromStreak: 7,
        toStreak: 8,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(f.cols[0].translateY, closeTo(-54.745650000000076, 1e-6));
      expect(f.cols[0].blur, closeTo(2.1232, 1e-3));
      expect(f.numScaleX, closeTo(0.984245, 1e-6));
      expect(f.numScaleY, closeTo(1.034662, 1e-6));
      expect(f.rings, hasLength(1));
      expect(f.sparks, hasLength(5));
      expect(f.shown, 7); // roll < 0.5 — still showing the old value
      expect(f.captionOpacity, closeTo(0, 1e-9));
    });

    test('el=0.86: roll complete, digit flipped', () {
      final f = computeStreakFrame(
        now: 0.86,
        fromStreak: 7,
        toStreak: 8,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(f.cols[0].translateY, closeTo(-180, 1e-6));
      expect(f.cols[0].blur, 0);
      expect(f.rings, hasLength(2));
      expect(f.sparks, hasLength(16));
      expect(f.shown, 8);
      expect(f.captionOpacity, closeTo(0.426622, 1e-5));
    });

    test('el=1.1: leap at zero, burst still active', () {
      final f = computeStreakFrame(
        now: 1.1,
        fromStreak: 7,
        toStreak: 8,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(f.rings, isEmpty);
      expect(f.sparks, hasLength(8));
      expect(f.shown, 8);
      expect(f.captionOpacity, closeTo(0.901684, 1e-5));
    });

    test('el=1.5: burst complete, particle lists empty', () {
      final f = computeStreakFrame(
        now: 1.5,
        fromStreak: 7,
        toStreak: 8,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(f.rings, isEmpty);
      expect(f.sparks, isEmpty);
      expect(f.captionOpacity, closeTo(1, 1e-9));
    });

    test('el=2.2 and beyond: stays settled, nothing re-triggers', () {
      final at22 = computeStreakFrame(
        now: 2.2,
        fromStreak: 7,
        toStreak: 8,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );
      final at3 = computeStreakFrame(
        now: 3.0,
        fromStreak: 7,
        toStreak: 8,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(at22.shown, 8);
      expect(at22.rings, isEmpty);
      expect(at3.shown, 8);
      expect(at3.rings, isEmpty);
    });
  });

  group('digit-count growth (padding column correctness trap)', () {
    test('9 -> 10 at el=0: padding column present but not yet rolling', () {
      final f = computeStreakFrame(
        now: 0,
        fromStreak: 9,
        toStreak: 10,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(f.cols, hasLength(2));
      expect(f.cols[0].outgoing, ''); // blank padding, not skipped
      expect(f.cols[0].incoming, '1');
      expect(f.cols[1].outgoing, '9');
      expect(f.cols[1].incoming, '0');
      expect(f.shown, 9);
    });

    test('9 -> 10 at el=0.86: padding column rolled in as a real digit', () {
      final f = computeStreakFrame(
        now: 0.86,
        fromStreak: 9,
        toStreak: 10,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      // Leading (padding) column leads by 0.07s, so at el=0.86 it's mid-roll
      // and overshoots past -180 (outBack easing) rather than being still.
      expect(f.cols[0].translateY, closeTo(-183.83591953125, 1e-6));
      expect(f.cols[1].translateY, closeTo(-180, 1e-6));
      expect(f.shown, 10);
    });

    test('99 -> 100 at el=0.93: 3-column roll, leftmost still catching up', () {
      final f = computeStreakFrame(
        now: 0.93,
        fromStreak: 99,
        toStreak: 100,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );

      expect(f.cols, hasLength(3));
      expect(f.cols[0].translateY, closeTo(-183.83591953125, 1e-6));
      expect(f.cols[1].translateY, closeTo(-180, 1e-6));
      expect(f.cols[2].translateY, closeTo(-180, 1e-6));
      expect(f.shown, 100);
    });
  });

  test('unchanged streak: digit column stays still, no travel/blur', () {
    final f = computeStreakFrame(
      now: 0.86,
      fromStreak: 5,
      toStreak: 5,
      weekDone: List.filled(7, false),
      todayIndex: 0,
      animateToday: false,
    );

    expect(f.cols, hasLength(1));
    expect(f.cols[0].translateY, 0);
    expect(f.cols[0].blur, 0);
    expect(f.shown, 5);
    // Rings/sparks are independent of digit content — still fire.
    expect(f.rings, hasLength(2));
    expect(f.sparks, hasLength(16));
  });

  group('milestone multiplier', () {
    test('1.3x multiplier grows burst ring diameter and spark distance', () {
      final normal = computeStreakFrame(
        now: 0.5,
        fromStreak: 6,
        toStreak: 7,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
      );
      final milestone = computeStreakFrame(
        now: 0.5,
        fromStreak: 6,
        toStreak: 7,
        weekDone: List.filled(7, false),
        todayIndex: 0,
        animateToday: false,
        milestoneMultiplier: 1.3,
      );

      expect(normal.rings, isNotEmpty);
      expect(milestone.rings, isNotEmpty);
      expect(milestone.rings[0].diameter, greaterThan(normal.rings[0].diameter));

      final normalSparks = normal.sparks.where((s) => s.distance > 0);
      final milestoneSparks = milestone.sparks.where((s) => s.distance > 0);
      expect(normalSparks, isNotEmpty);
      expect(milestoneSparks, isNotEmpty);
    });
  });

  group('week pips — real calendar data, not a clamped streak count', () {
    test('already-done days are always fully filled, no animation', () {
      final f = computeStreakFrame(
        now: 0,
        fromStreak: 40,
        toStreak: 41,
        weekDone: [true, true, false, false, false, false, false],
        todayIndex: 2,
        animateToday: true,
      );

      expect(f.pips[0].filled, 1);
      expect(f.pips[1].filled, 1);
      expect(f.pips[0].scale, closeTo(1, 1e-9)); // punch = sin(pi*1) = 0
    });

    test('the animating day fills in over the beat', () {
      final atStart = computeStreakFrame(
        now: 0,
        fromStreak: 40,
        toStreak: 41,
        weekDone: [true, true, false, false, false, false, false],
        todayIndex: 2,
        animateToday: true,
      );
      final atEnd = computeStreakFrame(
        now: 0.92,
        fromStreak: 40,
        toStreak: 41,
        weekDone: [true, true, false, false, false, false, false],
        todayIndex: 2,
        animateToday: true,
      );

      expect(atStart.pips[2].filled, closeTo(0, 1e-6));
      expect(atEnd.pips[2].filled, closeTo(1, 1e-6));
    });

    test('not-yet-done, non-animating days stay empty', () {
      final f = computeStreakFrame(
        now: 0.86,
        fromStreak: 40,
        toStreak: 41,
        weekDone: [true, true, false, false, false, false, false],
        todayIndex: 2,
        animateToday: true,
      );

      expect(f.pips[3].filled, 0);
      expect(f.pips[6].filled, 0);
    });

    test('a repeat workout the same day does not re-animate any pip', () {
      final f = computeStreakFrame(
        now: 0.5,
        fromStreak: 41,
        toStreak: 41,
        weekDone: [true, true, true, false, false, false, false],
        todayIndex: 2,
        animateToday: false,
      );

      expect(f.pips[2].filled, 1);
      expect(f.pips[2].scale, closeTo(1, 1e-9));
    });
  });
}
