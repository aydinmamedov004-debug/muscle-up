import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/storage/workout_history.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final WorkoutHistory workout;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.workoutName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            workout.workoutName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            formatDuration(workout.durationSeconds),
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 18,
            ),
          ),

          if (workout.note != null && workout.note!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(workout.note!),
              ),
            ),
          ],

          const SizedBox(height: 30),

          ...workout.exercises.map((exercise) {
            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ...exercise.sets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final set = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                "#${index + 1}",
                              ),
                            ),

                            Expanded(
                              child: Text(
                                "${set.weight ?? "-"} kg",
                              ),
                            ),

                            Expanded(
                              child: Text(
                                "${set.reps ?? "-"} reps",
                              ),
                            ),

                            Icon(
                              set.completed
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: set.completed
                                  ? AppTheme.success
                                  : AppTheme.secondaryText,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}