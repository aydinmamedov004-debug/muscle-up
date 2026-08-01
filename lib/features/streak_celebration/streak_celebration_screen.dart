import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/primary_button.dart';
import 'streak_motion.dart';
import 'widgets/burst_effect.dart';
import 'widgets/embers_field.dart';
import 'widgets/flame_widget.dart';
import 'widgets/streak_counter.dart';
import 'widgets/week_pip_strip.dart';

const _milestoneDays = {7, 30, 100};

/// Pushes the full-screen streak celebration takeover and returns once the
/// user dismisses it. Uses a zero-duration route — this app's default
/// ~300ms push transition would otherwise visibly run concurrently with the
/// celebration's own `el=0` beat.
Future<void> showStreakCelebration(
  BuildContext context, {
  required int fromStreak,
  required int toStreak,
  required List<bool> weekDone,
  required int todayIndex,
  required bool animateToday,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StreakCelebrationScreen(
          fromStreak: fromStreak,
          toStreak: toStreak,
          weekDone: weekDone,
          todayIndex: todayIndex,
          animateToday: animateToday,
        );
      },
    ),
  );
}

class StreakCelebrationScreen extends StatefulWidget {
  final int fromStreak;
  final int toStreak;
  final List<bool> weekDone;
  final int todayIndex;
  final bool animateToday;

  const StreakCelebrationScreen({
    super.key,
    required this.fromStreak,
    required this.toStreak,
    required this.weekDone,
    required this.todayIndex,
    required this.animateToday,
  });

  @override
  State<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState extends State<StreakCelebrationScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _elapsed = ValueNotifier(0);
  Ticker? _ticker;
  bool? _reducedMotion;
  bool _hapticFired = false;

  double get _milestoneMultiplier =>
      _milestoneDays.contains(widget.toStreak) ? 1.3 : 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reducedMotion == null) {
      _reducedMotion = MediaQuery.of(context).disableAnimations;
      // Even in reduced motion, pip-fill and the caption still animate per
      // spec — only the digit roll/burst/embers are skipped in the tree
      // built below, so the ticker always runs.
      _ticker = createTicker(_onTick)..start();
    }
  }

  void _onTick(Duration elapsed) {
    final seconds = elapsed.inMicroseconds / 1e6;
    _elapsed.value = seconds;
    if (!_hapticFired && seconds >= 0.34) {
      _hapticFired = true;
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = _reducedMotion ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: _elapsed,
              builder: (context, elapsed, _) {
                final frame = computeStreakFrame(
                  now: elapsed,
                  fromStreak: widget.fromStreak,
                  toStreak: widget.toStreak,
                  weekDone: const [],
                  todayIndex: 0,
                  animateToday: false,
                );
                return _Ground(opacity: frame.groundOpacity);
              },
            ),
          ),
          if (!reducedMotion)
            Positioned.fill(
              child: RepaintBoundary(
                child: ValueListenableBuilder<double>(
                  valueListenable: _elapsed,
                  builder: (context, elapsed, _) => EmbersField(
                    elapsedSeconds: elapsed,
                    fromStreak: widget.fromStreak,
                    toStreak: widget.toStreak,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),
                  const _Kicker(),
                  const SizedBox(height: 148),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 106,
                        height: 118,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            RepaintBoundary(
                              child: ValueListenableBuilder<double>(
                                valueListenable: _elapsed,
                                builder: (context, elapsed, _) => FlameWidget(
                                  elapsedSeconds: elapsed,
                                  fromStreak: widget.fromStreak,
                                  toStreak: widget.toStreak,
                                  milestoneMultiplier: _milestoneMultiplier,
                                ),
                              ),
                            ),
                            if (!reducedMotion)
                              RepaintBoundary(
                                child: ValueListenableBuilder<double>(
                                  valueListenable: _elapsed,
                                  builder: (context, elapsed, _) =>
                                      BurstEffect(
                                    elapsedSeconds: elapsed,
                                    fromStreak: widget.fromStreak,
                                    toStreak: widget.toStreak,
                                    milestoneMultiplier: _milestoneMultiplier,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      RepaintBoundary(
                        child: reducedMotion
                            ? _ReducedMotionNumber(
                                from: widget.fromStreak,
                                to: widget.toStreak,
                              )
                            : ValueListenableBuilder<double>(
                                valueListenable: _elapsed,
                                builder: (context, elapsed, _) =>
                                    StreakCounter(
                                  from: widget.fromStreak,
                                  to: widget.toStreak,
                                  elapsedSeconds: elapsed,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'DAY STREAK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 16 * 0.30,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 58),
                  RepaintBoundary(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _elapsed,
                      builder: (context, elapsed, _) => WeekPipStrip(
                        elapsedSeconds: elapsed,
                        fromStreak: widget.fromStreak,
                        toStreak: widget.toStreak,
                        weekDone: widget.weekDone,
                        todayIndex: widget.todayIndex,
                        animateToday: widget.animateToday,
                      ),
                    ),
                  ),
                  const SizedBox(height: 78),
                  ValueListenableBuilder<double>(
                    valueListenable: _elapsed,
                    builder: (context, elapsed, _) {
                      final frame = computeStreakFrame(
                        now: elapsed,
                        fromStreak: widget.fromStreak,
                        toStreak: widget.toStreak,
                        weekDone: const [],
                        todayIndex: 0,
                        animateToday: false,
                      );
                      return Opacity(
                        opacity: frame.captionOpacity.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, frame.captionTranslateY),
                          child: Text(
                            "Day ${frame.shown} — keep it going!",
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.text,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: 'CONTINUE',
                    icon: Icons.arrow_forward,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORKOUT COMPLETE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 13 * 0.34,
            color: AppTheme.accentSoft,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 120,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0)],
            ),
          ),
        ),
      ],
    );
  }
}

class _Ground extends StatelessWidget {
  final double opacity;

  const _Ground({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 215 - 380,
          top: 330 - 380,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: 760,
              height: 760,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x8C5A1610),
                    Color(0x573A0F0B),
                    Color(0x00141414),
                  ],
                  stops: [0.0, 0.38, 0.70],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.1,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reduced-motion substitute for [StreakCounter] — a plain 200ms cross-fade
/// between the old and new number instead of the digit-roll animation.
class _ReducedMotionNumber extends StatelessWidget {
  final int from;
  final int to;

  const _ReducedMotionNumber({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        '$to',
        key: ValueKey(to),
        style: const TextStyle(
          fontSize: 172,
          fontWeight: FontWeight.w500,
          height: 1,
          letterSpacing: -0.03 * 172,
          color: AppTheme.text,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
