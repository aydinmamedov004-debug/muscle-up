import 'package:flutter/material.dart';

import '../../../data/exercise_catalog.dart';
import '../../../data/muscle_group.dart';

class CreateExerciseDialog extends StatefulWidget {
  const CreateExerciseDialog({super.key});

  @override
  State<CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<CreateExerciseDialog> {
  final nameController = TextEditingController();
  MuscleGroup selectedGroup = MuscleGroup.chest;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      setState(() => errorMessage = "Enter an exercise name.");
      return;
    }

    final alreadyExists = allExercises.any(
      (exercise) => exercise.name.toLowerCase() == name.toLowerCase(),
    );

    if (alreadyExists) {
      setState(() => errorMessage = "That exercise already exists.");
      return;
    }

    Navigator.pop(context, CatalogExercise(name, selectedGroup));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Exercise"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: "Exercise name"),
            ),

            const SizedBox(height: 16),

            const Text(
              "Muscle group",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleGroup.values.map((group) {
                return ChoiceChip(
                  label: Text(group.label),
                  selected: group == selectedGroup,
                  onSelected: (_) {
                    setState(() => selectedGroup = group);
                  },
                );
              }).toList(),
            ),

            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text("Create"),
        ),
      ],
    );
  }
}
