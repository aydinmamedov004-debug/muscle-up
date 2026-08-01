import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../streak_motion.dart';

/// 12 ambient floating embers, drifting upward on a continuous loop. Never
/// fully stops — a static frame here reads as a bug per the design spec.
/// Positioned using the same absolute reference-frame coordinates
/// (430×932pt) as the rest of the celebration layout.
class EmbersField extends StatelessWidget {
  final double elapsedSeconds;
  final int fromStreak;
  final int toStreak;

  const EmbersField({
    super.key,
    required this.elapsedSeconds,
    required this.fromStreak,
    required this.toStreak,
  });

  @override
  Widget build(BuildContext context) {
    final frame = computeStreakFrame(
      now: elapsedSeconds,
      fromStreak: fromStreak,
      toStreak: toStreak,
      weekDone: const [],
      todayIndex: 0,
      animateToday: false,
    );

    return IgnorePointer(
      child: CustomPaint(
        painter: _EmbersPainter(embers: frame.embers),
        size: Size.infinite,
      ),
    );
  }
}

class _EmbersPainter extends CustomPainter {
  final List<EmberFrame> embers;

  _EmbersPainter({required this.embers});

  @override
  void paint(Canvas canvas, Size size) {
    for (final ember in embers) {
      if (ember.opacity <= 0) continue;

      final paint = Paint()
        ..color = AppTheme.accentSoft.withValues(alpha: ember.opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, ember.blur / 2);

      canvas.drawCircle(
        Offset(ember.x, ember.y),
        ember.diameter / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EmbersPainter oldDelegate) => true;
}
