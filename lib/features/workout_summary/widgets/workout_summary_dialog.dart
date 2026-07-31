import 'package:flutter/material.dart';

class WorkoutSummaryDialog extends StatelessWidget {
  final String duration;
  final int totalExercises;
  final int completedSets;
  final int totalSets;

  const WorkoutSummaryDialog({
    super.key,
    required this.duration,
    required this.totalExercises,
    required this.completedSets,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Colors.grey,
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

    return AlertDialog(
      title: const Center(
        child: Text(
          "🎉 Workout Complete!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          stat("Duration", duration),
          stat("Exercises", "$totalExercises"),
          stat("Sets", "$completedSets / $totalSets"),
          stat("Completion", "$completion%"),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Done"),
          ),
        ),
      ],
    );
  }
}