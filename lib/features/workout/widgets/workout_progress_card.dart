import 'package:flutter/material.dart';

class WorkoutProgressCard extends StatelessWidget {
  final int completedExercises;
  final int totalExercises;
  final double progress;

  const WorkoutProgressCard({
    super.key,
    required this.completedExercises,
    required this.totalExercises,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$completedExercises / $totalExercises exercises completed",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}