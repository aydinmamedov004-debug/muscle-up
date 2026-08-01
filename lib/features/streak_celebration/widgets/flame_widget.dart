import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../streak_motion.dart';

/// The flame + its halo — leaps and brightens on the beat, flickers/sways
/// continuously. Controlled (pure function of [elapsedSeconds]), same
/// reasoning as [StreakCounter]: this needs to stay frame-synced with the
/// digit roll and burst, so it must share the parent's single clock rather
/// than run its own.
class FlameWidget extends StatelessWidget {
  final double elapsedSeconds;
  final int fromStreak;
  final int toStreak;
  final double milestoneMultiplier;

  const FlameWidget({
    super.key,
    required this.elapsedSeconds,
    required this.fromStreak,
    required this.toStreak,
    this.milestoneMultiplier = 1.0,
  });

  static const double _flameSize = 104;
  static const double _boxWidth = 106;
  static const double _boxHeight = 118;
  static const double _haloSize = 340;

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

    final g = frame.flameGlow.clamp(0.0, 1.7);

    return SizedBox(
      width: _boxWidth,
      height: _boxHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: frame.haloScale,
            child: Opacity(
              opacity: frame.haloOpacity.clamp(0.0, 1.0),
              child: Container(
                width: _haloSize,
                height: _haloSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x52FF3A2E),
                      Color(0x475A0F0B),
                      Color(0x005A0F0B),
                    ],
                    stops: [0.0, 0.34, 0.68],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(frame.flameSway, 0),
              child: Transform.scale(
                scaleX: frame.flameGrow,
                scaleY: frame.flameGrow * frame.flameFlicker,
                alignment: const Alignment(0, 0.84), // transform-origin 50% 92%
                child: Icon(
                  Icons.local_fire_department,
                  size: _flameSize,
                  color: AppTheme.accentSoft,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFD9D5).withValues(alpha: 0.8 * g.clamp(0.0, 1.0)),
                      blurRadius: 12 * g,
                    ),
                    Shadow(
                      color: AppTheme.primary.withValues(alpha: 0.85 * g.clamp(0.0, 1.0)),
                      blurRadius: 34 * g,
                    ),
                    Shadow(
                      color: AppTheme.glowDeep.withValues(alpha: 0.7 * g.clamp(0.0, 1.0)),
                      blurRadius: 52 * g,
                      offset: Offset(0, 6 * g),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
