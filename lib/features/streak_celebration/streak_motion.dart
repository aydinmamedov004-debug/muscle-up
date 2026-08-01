/// Pure motion math for the streak celebration takeover — a line-for-line
/// port of the design handoff's reference `renderVals()`. Zero Flutter
/// imports so it can be unit-tested in isolation, the same way
/// [test/streak_calculation_test.dart] tests streak logic in isolation.
///
/// The reference implementation takes two clocks (`now` since mount, `el`
/// since trigger) because its interactive demo supports re-triggering for
/// design review. In this app the celebration screen is created fresh for
/// exactly one trigger, so mount time == trigger time — there is only one
/// clock here, [now], used for both the one-shot phases (which naturally
/// settle at their terminal value as `now` grows, since every phase window
/// is built from [seg], which clamps to [0,1]) and the ambient effects
/// (flicker/sway/embers), which never stop.
library;

import 'dart:math' as math;

const double _lineBox = 180;

double easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();

double easeOutBack(double t) {
  const c1 = 1.70158, c3 = c1 + 1;
  return 1 +
      c3 * math.pow(t - 1, 3).toDouble() +
      c1 * math.pow(t - 1, 2).toDouble();
}

double clamp01(double v) => v.clamp(0.0, 1.0);

/// Normalizes [v] into the window [a, b], clamped to [0, 1].
double seg(double v, double a, double b) => ((v - a) / (b - a)).clamp(0.0, 1.0);

/// Deterministic pseudo-random in [0, 1), seeded by (index, salt) — used so
/// spark/ember scatter is stable frame to frame instead of re-randomizing.
double rnd(int i, double s) {
  final v = math.sin(i * 12.9898 + s * 78.233) * 43758.5453;
  return v - v.floorToDouble();
}

class DigitColumnFrame {
  /// '' when this column is a blank padding glyph (e.g. the leading column
  /// when a 2-digit streak becomes 3-digit) — still animates like a real
  /// digit, just renders empty.
  final String outgoing;
  final String incoming;

  /// px, 0 to -[_lineBox]: translateY of the 2-glyph stack.
  final double translateY;

  /// px motion blur on the moving stack, 0 when not moving.
  final double blur;

  const DigitColumnFrame({
    required this.outgoing,
    required this.incoming,
    required this.translateY,
    required this.blur,
  });
}

class RingFrame {
  final double diameter;
  final double offset; // -diameter / 2, for centering
  final double strokeWidth;
  final double opacity;

  const RingFrame({
    required this.diameter,
    required this.offset,
    required this.strokeWidth,
    required this.opacity,
  });
}

class SparkFrame {
  final double length;
  final double width;

  /// True for the brighter of the two spark colors (every 3rd spark).
  final bool bright;
  final double opacity;
  final double angleRadians;
  final double distance;
  final double scaleX;

  const SparkFrame({
    required this.length,
    required this.width,
    required this.bright,
    required this.opacity,
    required this.angleRadians,
    required this.distance,
    required this.scaleX,
  });
}

class EmberFrame {
  final double x;
  final double y;
  final double diameter;
  final double blur;
  final double opacity;

  const EmberFrame({
    required this.x,
    required this.y,
    required this.diameter,
    required this.blur,
    required this.opacity,
  });
}

class PipFrame {
  /// 0 (empty) to 1 (fully filled) — already-done days are always 1,
  /// not-yet-done days are always 0, and the one day mid-transition
  /// (if any) is the live fill progress.
  final double filled;
  final double scale;

  /// 0 when no glow should render.
  final double glowRadius;
  final double checkOpacity;

  const PipFrame({
    required this.filled,
    required this.scale,
    required this.glowRadius,
    required this.checkOpacity,
  });
}

class StreakFrame {
  final List<DigitColumnFrame> cols;
  final double numScaleX;
  final double numScaleY;

  final double flameFlicker;
  final double flameSway;
  final double flameGlow; // g — the flame's own shadow-stack multiplier
  final double flameGrow; // scale multiplier

  /// Scale/opacity of the 340pt radial halo sitting behind the flame.
  final double haloScale;
  final double haloOpacity;

  /// Opacity pulse of the large background ground glow.
  final double groundOpacity;

  final List<RingFrame> rings;
  final List<SparkFrame> sparks;
  final List<EmberFrame> embers;
  final List<PipFrame> pips;

  /// The streak value that should currently be displayed (flips to [to]
  /// once the digit roll passes its halfway point).
  final int shown;

  final double captionOpacity;
  final double captionTranslateY;

  const StreakFrame({
    required this.cols,
    required this.numScaleX,
    required this.numScaleY,
    required this.flameFlicker,
    required this.flameSway,
    required this.flameGlow,
    required this.flameGrow,
    required this.haloScale,
    required this.haloOpacity,
    required this.groundOpacity,
    required this.rings,
    required this.sparks,
    required this.embers,
    required this.pips,
    required this.shown,
    required this.captionOpacity,
    required this.captionTranslateY,
  });
}

/// Computes every visual value for the celebration at elapsed time [now]
/// (seconds since the screen mounted, which is also seconds since trigger).
///
/// [weekDone] is only meaningful when it has exactly 7 entries (Monday
/// first); callers that don't care about the week strip (e.g.
/// [StreakCounter] used on its own) can pass an empty list and [pips] on
/// the result will simply come back empty.
StreakFrame computeStreakFrame({
  required double now,
  required int fromStreak,
  required int toStreak,
  required List<bool> weekDone,
  required int todayIndex,
  required bool animateToday,
  double milestoneMultiplier = 1.0,
}) {
  final el = now;

  final roll = easeOutBack(seg(el, 0.30, 0.86));
  final dip = math.sin(math.pi * seg(el, 0.02, 0.34));
  final leap = math.sin(math.pi * seg(el, 0.26, 1.10));
  final boost = leap - 0.22 * dip;
  final burst = seg(el, 0.28, 1.50);
  final fill = easeOutBack(seg(el, 0.34, 0.92));

  // Number squash/stretch through the swap.
  final rt = clamp01(seg(el, 0.30, 0.86));
  final sy = 1 +
      0.11 * math.sin(math.pi * clamp01(rt / 0.7)) * (rt < 0.7 ? 1 : 0) -
      0.05 * math.sin(math.pi * seg(rt, 0.6, 1));
  final sx = 1 -
      0.05 * math.sin(math.pi * clamp01(rt / 0.7)) * (rt < 0.7 ? 1 : 0) +
      0.05 * math.sin(math.pi * seg(rt, 0.6, 1));

  // Per-digit columns — rightmost digit leads (0.07s per position to the left).
  final a = fromStreak.toString();
  final b = toStreak.toString();
  final len = math.max(a.length, b.length);
  final pa = a.padLeft(len, ' ');
  final pb = b.padLeft(len, ' ');

  final cols = List<DigitColumnFrame>.generate(len, (i) {
    final lead = (len - 1 - i) * 0.07;
    final e = easeOutBack(seg(el, 0.30 + lead, 0.86 + lead));
    final chA = pa[i];
    final chB = pb[i];
    final still = chA == chB;
    final travel = still ? 0.0 : math.sin(math.pi * clamp01(e));
    return DigitColumnFrame(
      outgoing: chA == ' ' ? '' : chA,
      incoming: chB == ' ' ? '' : chB,
      translateY: still ? 0 : -e.clamp(0.0, 1.04) * _lineBox,
      blur: travel > 0.06 ? travel * 2.6 : 0,
    );
  });

  // Flame — continuous, off `now`, never gated by the trigger.
  final flick = 1 + 0.024 * math.sin(now * 6.1) + 0.015 * math.sin(now * 11.7 + 1.2);
  final sway = 0.5 * math.sin(now * 2.1);
  final g = (0.75 + 0.85 * boost).clamp(0.0, 1.7);
  final grow = flick * (1 + 0.3 * boost * milestoneMultiplier);
  final clampedBoost = clamp01(boost);
  final haloScale = 1 + 0.22 * clampedBoost;
  final haloOpacity = 0.8 + 0.2 * clampedBoost;
  final groundOpacity = 0.9 + 0.1 * clampedBoost;

  // Burst: 2 expanding rings.
  final rings = <RingFrame>[];
  for (var i = 0; i < 2; i++) {
    final delay = i == 0 ? 0.0 : 0.14;
    final t = seg(burst, delay, delay + 0.5);
    if (t <= 0 || t >= 1) continue;
    final e = easeOutCubic(t);
    final dia = 72 * (0.55 + 2.5 * e) * milestoneMultiplier;
    rings.add(
      RingFrame(
        diameter: dia,
        offset: -dia / 2,
        strokeWidth: (1 - e) * 3 + 1,
        opacity: (1 - e) * (i == 1 ? 0.32 : 0.55),
      ),
    );
  }

  // Burst: 16 sparks fired upward in a fan.
  final sparks = <SparkFrame>[];
  if (burst > 0 && burst < 1) {
    for (var i = 0; i < 16; i++) {
      final st = seg(burst, 0.02 + rnd(i, 3) * 0.12, 0.52 + rnd(i, 9) * 0.3);
      if (st <= 0 || st >= 1) continue;
      final e = easeOutCubic(st);
      final w = 3 + rnd(i, 7) * 3;
      sparks.add(
        SparkFrame(
          length: 5 + rnd(i, 5) * 12,
          width: w,
          bright: i % 3 == 0,
          opacity: (1 - e) * 0.95,
          angleRadians: -math.pi / 2 + (rnd(i, 1) - 0.5) * 2.5,
          distance: (26 + rnd(i, 2) * 82) * e * milestoneMultiplier,
          scaleX: 0.5 + (1 - e) * 1.4,
        ),
      );
    }
  }

  // Ambient embers — 12 particles, always running.
  final embers = <EmberFrame>[];
  for (var i = 0; i < 12; i++) {
    final speed = 0.16 + rnd(i, 4) * 0.13;
    final life = ((now * speed) + rnd(i, 6)) % 1;
    final o = math.sin(math.pi * life) * 0.5 * (0.8 + 0.6 * math.max(0, boost));
    final d = 2 + rnd(i, 2) * 4;
    embers.add(
      EmberFrame(
        x: 110 + rnd(i, 8) * 210 + math.sin(now * 0.9 + i) * 10,
        y: 440 - life * 260,
        diameter: d,
        blur: d * 2.2,
        opacity: o,
      ),
    );
  }

  // Week pips — driven by real completion data, not a clamped streak count.
  // Callers that don't need the week strip (e.g. StreakCounter on its own)
  // pass an empty list rather than a 7-entry one; skip pips entirely then.
  final pips = weekDone.length != 7
      ? const <PipFrame>[]
      : List<PipFrame>.generate(7, (i) {
          final isAnimating = animateToday && i == todayIndex;
          final filled =
              isAnimating ? clamp01(fill) : (weekDone[i] ? 1.0 : 0.0);
          final punch = math.sin(math.pi * clamp01(filled));
          return PipFrame(
            filled: filled,
            scale: 1 + 0.12 * punch,
            glowRadius: punch > 0.02 ? 18 * punch : 0,
            checkOpacity: clamp01((filled - 0.4) / 0.4),
          );
        });

  final shown = roll > 0.5 ? toStreak : fromStreak;
  final capT = easeOutCubic(seg(el, 0.75, 1.40));

  return StreakFrame(
    cols: cols,
    numScaleX: sx,
    numScaleY: sy,
    flameFlicker: flick,
    flameSway: sway,
    flameGlow: g,
    flameGrow: grow,
    haloScale: haloScale,
    haloOpacity: haloOpacity,
    groundOpacity: groundOpacity,
    rings: rings,
    sparks: sparks,
    embers: embers,
    pips: pips,
    shown: shown,
    captionOpacity: capT,
    captionTranslateY: (1 - capT) * 14,
  );
}
