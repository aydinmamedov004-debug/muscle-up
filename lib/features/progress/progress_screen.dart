import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/progress/exercise_record.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_tile.dart';
import '../achievements/achievements_screen.dart';
import '../achievements/providers/achievement_provider.dart';
import 'providers/progress_provider.dart';
import 'widgets/weight_chart.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String? selectedExercise;

  String _formatTrainingTime(Duration duration) {
    if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
    }

    return "${duration.inMinutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(progressDataProvider);
    final achievementStatuses = ref.watch(achievementStatusesProvider);
    final unlockedCount =
        achievementStatuses.where((status) => status.isUnlocked).length;
    final exerciseNames =
        data.exerciseRecords.map((record) => record.exerciseName).toList();

    if (selectedExercise == null || !exerciseNames.contains(selectedExercise)) {
      selectedExercise = exerciseNames.isEmpty ? null : exerciseNames.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                StatTile(
                  icon: Icons.fitness_center,
                  value: data.totalWorkouts.toString(),
                  label: "Workouts",
                ),

                const SizedBox(width: AppSpacing.sm),

                StatTile(
                  icon: Icons.timer_outlined,
                  value: _formatTrainingTime(data.totalTrainingTime),
                  label: "Training",
                ),

                const SizedBox(width: AppSpacing.sm),

                StatTile(
                  icon: Icons.emoji_events_outlined,
                  value: "$unlockedCount/${achievementStatuses.length}",
                  label: "Achievements",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: "Strength Progress"),

            if (selectedExercise == null)
              const EmptyState(
                icon: Icons.show_chart,
                title: "No Data Yet",
                subtitle:
                    "Complete a workout with logged weights to see your "
                    "progress here.",
              )
            else
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedExercise,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).cardColor,
                        items: exerciseNames
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: (name) {
                          setState(() => selectedExercise = name);
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    WeightChart(
                      points: ref.watch(
                        exerciseWeightHistoryProvider(selectedExercise!),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: "Personal Records"),

            if (data.exerciseRecords.isEmpty)
              const EmptyState(
                icon: Icons.show_chart,
                title: "No Records Yet",
                subtitle:
                    "Complete a workout to start tracking your personal records.",
              )
            else
              ...data.exerciseRecords.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.sm,
                  ),
                  child: _RecordCard(record: record),
                ),
              ),

            const SizedBox(height: AppSpacing.fabClearance),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final ExerciseRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exerciseName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 4),

                Text(
                  "${record.maxReps} reps • "
                  "${record.maxVolume.toStringAsFixed(0)} kg volume",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          Text(
            "${record.maxWeight.toStringAsFixed(1)} kg",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
