import 'package:flutter/material.dart';

class WorkoutTimerCard extends StatelessWidget {
  final String duration;
  final bool isRunning;

  const WorkoutTimerCard({
    super.key,
    required this.duration,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isRunning
                  ? Icons.timer
                  : Icons.timer_outlined,
              size: 40,
            ),

            const SizedBox(height: 16),

            Text(
              duration,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isRunning
                  ? "Workout in Progress"
                  : "Workout Not Started",
              style: TextStyle(
                color: isRunning
                    ? Colors.green
                    : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}