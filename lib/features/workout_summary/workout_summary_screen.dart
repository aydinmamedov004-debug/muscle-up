import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/achievement.dart';
import '../../shared/widgets/primary_button.dart';

/// Bundles the stats a finished workout hands off to [WorkoutSummaryScreen]
/// so callers (the workout screen, the streak celebration screen) can pass
/// it through the chain without repeating four separate parameters.
class WorkoutSummaryData {
  final String duration;
  final int totalExercises;
  final int completedSets;
  final int totalSets;
  final List<Achievement> newlyUnlocked;

  const WorkoutSummaryData({
    required this.duration,
    required this.totalExercises,
    required this.completedSets,
    required this.totalSets,
    this.newlyUnlocked = const [],
  });
}

/// Full-screen takeover shown after a workout is saved — replaces the old
/// modal dialog so it can slide in/out alongside the streak celebration
/// screen as one continuous motion instead of a dialog popping over it.
class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSummaryData summary;

  const WorkoutSummaryScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final totalSets = summary.totalSets;
    final completedSets = summary.completedSets;
    final completion =
        totalSets == 0 ? 0 : (completedSets / totalSets * 100).round();

    Widget stat(String title, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.secondaryText,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Workout Complete!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              stat("Duration", summary.duration),
              stat("Exercises", "${summary.totalExercises}"),
              stat("Sets", "$completedSets / $totalSets"),
              stat("Completion", "$completion%"),

              if (summary.newlyUnlocked.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 18,
                            color: AppTheme.accentSoft,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Achievement Unlocked",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentSoft,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final achievement in summary.newlyUnlocked)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                achievement.icon,
                                size: 18,
                                color: AppTheme.accentSoft,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  achievement.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const Spacer(),
              PrimaryButton(
                text: "Done",
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
