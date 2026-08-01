import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../streak_motion.dart';

/// The spark burst — 2 expanding rings + 16 sparks fired upward in a fan,
/// centered on wherever the parent positions this widget (over the flame).
/// One [CustomPainter] for both effects since they share the same [burst]
/// input and are one visual moment, not two.
class BurstEffect extends StatelessWidget {
  final double elapsedSeconds;
  final int fromStreak;
  final int toStreak;
  final double milestoneMultiplier;

  const BurstEffect({
    super.key,
    required this.elapsedSeconds,
    required this.fromStreak,
    required this.toStreak,
    this.milestoneMultiplier = 1.0,
  });

  static const double _size = 260;

  @override
  Widget build(BuildContext context) {
    final frame = computeStreakFrame(
      now: elapsedSeconds,
      fromStreak: fromStreak,
      toStreak: toStreak,
      weekDone: const [],
      todayIndex: 0,
      animateToday: false,
      milestoneMultiplier: milestoneMultiplier,
    );

    if (frame.rings.isEmpty && frame.sparks.isEmpty) {
      return const SizedBox(width: _size, height: _size);
    }

    return IgnorePointer(
      child: CustomPaint(
        size: const Size(_size, _size),
        painter: _BurstPainter(rings: frame.rings, sparks: frame.sparks),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final List<RingFrame> rings;
  final List<SparkFrame> sparks;

  _BurstPainter({required this.rings, required this.sparks});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (final ring in rings) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth
        ..color = AppTheme.accentCoral.withValues(alpha: ring.opacity.clamp(0.0, 1.0));
      canvas.drawCircle(center, ring.diameter / 2, paint);
    }

    for (final spark in sparks) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(spark.angleRadians);
      canvas.translate(spark.distance, 0);
      canvas.scale(spark.scaleX, 1);

      final paint = Paint()
        ..color = (spark.bright ? AppTheme.accentLightest : AppTheme.accentCoral)
            .withValues(alpha: spark.opacity.clamp(0.0, 1.0));
      final rect = Rect.fromLTWH(0, -spark.width / 2, spark.length, spark.width);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(spark.width / 2)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => true;
}
