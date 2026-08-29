import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/local/hive_service.dart';
import '../../models/storage/workout_history.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/workout_history_card.dart';
import 'workout_details_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);

    if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
    }

    return "${duration.inMinutes}m";
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(workoutDay).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference < 7) return DateFormat("EEEE").format(date);

    return DateFormat("d MMM yyyy").format(date);
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WorkoutHistory workout,
  ) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete workout?"),
          content: const Text(
            "This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (delete == true) {
      await workout.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.historyBox.listenable(),
      builder: (context, box, _) {
        final workouts = box.values.toList().reversed.toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Workout History"),
          ),
          body: workouts.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: "No Workouts Yet",
                  subtitle: "Complete a workout to see it here.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    20 + AppSpacing.fabClearance,
                  ),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: WorkoutHistoryCard(
                        workout: workout,
                        formattedDate: formatDate(workout.completedAt),
                        formattedDuration:
                            formatDuration(workout.durationSeconds),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutDetailsScreen(
                                workout: workout,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(
                            context,
                            workout,
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}