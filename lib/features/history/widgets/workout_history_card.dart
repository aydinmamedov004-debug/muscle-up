import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/storage/workout_history.dart';

class WorkoutHistoryCard extends StatelessWidget {
  final WorkoutHistory workout;
  final String formattedDate;
  final String formattedDuration;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const WorkoutHistoryCard({
    super.key,
    required this.workout,
    required this.formattedDate,
    required this.formattedDuration,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseCount = workout.exercises.length;

    final completedSets = workout.exercises
        .expand((exercise) => exercise.sets)
        .where((set) => set.completed)
        .length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      workout.workoutName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.primary,
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(formattedDate),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(formattedDuration),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.format_list_numbered,
                    size: 18,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$exerciseCount exercises • $completedSets completed sets",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}