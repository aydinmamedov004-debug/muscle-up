import 'dart:ui' show FontFeature, ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../streak_motion.dart';

/// The digit-roll counter — a controlled widget with no internal clock of
/// its own. It's a pure function of [elapsedSeconds], so it stays in
/// lockstep with sibling widgets (flame, burst) that share the same driving
/// clock, and stays genuinely reusable by a future streak-loss animation
/// (which would just feed it its own [elapsedSeconds]).
class StreakCounter extends StatelessWidget {
  final int from;
  final int to;
  final double elapsedSeconds;

  const StreakCounter({
    super.key,
    required this.from,
    required this.to,
    required this.elapsedSeconds,
  });

  static const double _columnWidth = 104;
  static const double _lineBox = 180;
  static const double _fontSize = 172;

  @override
  Widget build(BuildContext context) {
    final frame = computeStreakFrame(
      now: elapsedSeconds,
      fromStreak: from,
      toStreak: to,
      weekDone: const [],
      todayIndex: 0,
      animateToday: false,
    );

    return Transform(
      alignment: const Alignment(-1, 0.64), // origin 0% 82%
      transform: Matrix4.diagonal3Values(frame.numScaleX, frame.numScaleY, 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final col in frame.cols) _DigitColumn(frame: col),
        ],
      ),
    );
  }
}

class _DigitColumn extends StatelessWidget {
  final DigitColumnFrame frame;

  const _DigitColumn({required this.frame});

  static const _style = TextStyle(
    fontSize: StreakCounter._fontSize,
    fontWeight: FontWeight.w500,
    height: 1,
    letterSpacing: -0.03 * StreakCounter._fontSize,
    color: AppTheme.text,
    fontFeatures: [FontFeature.tabularFigures()],
    shadows: [
      Shadow(color: Color(0x73FF3A2E), blurRadius: 18),
      Shadow(color: Color(0x805A1610), blurRadius: 46),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final stack = SizedBox(
      width: StreakCounter._columnWidth,
      child: Transform.translate(
        offset: Offset(0, frame.translateY),
        child: Column(
          children: [
            _glyph(frame.outgoing),
            _glyph(frame.incoming),
          ],
        ),
      ),
    );

    return SizedBox(
      width: StreakCounter._columnWidth,
      height: StreakCounter._lineBox,
      child: ClipRect(
        child: frame.blur > 0
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: frame.blur,
                  sigmaY: frame.blur,
                ),
                child: stack,
              )
            : stack,
      ),
    );
  }

  Widget _glyph(String ch) {
    return SizedBox(
      height: StreakCounter._lineBox,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(ch, style: _style),
      ),
    );
  }
}
