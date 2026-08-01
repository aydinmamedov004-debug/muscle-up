import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_theme.dart';
import '../streak_motion.dart';

/// The 7-day week strip, driven by real workout history (Monday-first) —
/// not the reference spec's literal "clamp the streak number to 0-6" logic,
/// since this app's streak can exceed 7. Only the day that just transitioned
/// from not-done to done (if any) animates; everything else renders static.
class WeekPipStrip extends StatelessWidget {
  final double elapsedSeconds;
  final int fromStreak;
  final int toStreak;
  final List<bool> weekDone;
  final int todayIndex;
  final bool animateToday;

  const WeekPipStrip({
    super.key,
    required this.elapsedSeconds,
    required this.fromStreak,
    required this.toStreak,
    required this.weekDone,
    required this.todayIndex,
    required this.animateToday,
  });

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final frame = computeStreakFrame(
      now: elapsedSeconds,
      fromStreak: fromStreak,
      toStreak: toStreak,
      weekDone: weekDone,
      todayIndex: todayIndex,
      animateToday: animateToday,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          _Pip(day: _days[i], frame: frame.pips[i]),
        ],
      ],
    );
  }
}

class _Pip extends StatelessWidget {
  final String day;
  final PipFrame frame;

  const _Pip({required this.day, required this.frame});

  @override
  Widget build(BuildContext context) {
    final filled = frame.filled > 0.5;

    return Column(
      children: [
        Transform.scale(
          scale: frame.scale,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadius.medium,
              border: Border.all(
                color: filled ? AppTheme.primary : AppTheme.divider,
              ),
              color: AppTheme.accentTint.withValues(alpha: 0.9 * frame.filled),
              boxShadow: frame.glowRadius > 0
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.55),
                        blurRadius: frame.glowRadius,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.check,
              size: 19,
              color: AppTheme.accentLightest.withValues(
                alpha: frame.checkOpacity.clamp(0.0, 1.0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 12 * 0.12,
            color: filled ? AppTheme.accentSoft : AppTheme.textFaint,
          ),
        ),
      ],
    );
  }
}
