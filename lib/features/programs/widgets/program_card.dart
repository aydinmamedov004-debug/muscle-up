import 'package:flutter/material.dart';

import '../../../models/storage/stored_workout_program.dart';

class ProgramCard extends StatelessWidget {
  final StoredWorkoutProgram program;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,

        leading: const CircleAvatar(
          child: Icon(Icons.fitness_center),
        ),

        title: Text(
          program.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          "${program.exercises.length} exercises",
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: onDelete,
              ),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}