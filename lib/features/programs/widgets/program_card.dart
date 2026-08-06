import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/storage/stored_workout_program.dart';

class ProgramCard extends StatelessWidget {
  final StoredWorkoutProgram program;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSetActive;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    this.isActive = false,
    this.onDelete,
    this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: isActive
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.primary, width: 2),
            )
          : null,
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
          isActive
              ? "${program.exercises.length} exercises · Active"
              : "${program.exercises.length} exercises",
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSetActive != null)
              IconButton(
                icon: Icon(isActive ? Icons.star : Icons.star_border),
                color: isActive ? AppTheme.primary : null,
                tooltip: isActive ? "Active program" : "Set as active",
                onPressed: onSetActive,
              ),

            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.primary,
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
