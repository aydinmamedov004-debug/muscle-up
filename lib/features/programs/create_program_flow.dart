import 'package:flutter/material.dart';

import '../../data/local/program_repository.dart';
import '../../data/workout_name_suggester.dart';
import '../../models/storage/stored_exercise_template.dart';
import '../../models/storage/stored_workout_program.dart';
import '../exercises/exercise_library_screen.dart';
import 'widgets/create_program_dialog.dart';

/// Picking exercises first and letting the app suggest a name (e.g. mostly
/// squats -> "Leg Day") is faster than naming a program before you know
/// what's in it, so every "new program" entry point in the app should
/// go through this same flow.
///
/// Returns the created program, or null if the user backed out.
Future<StoredWorkoutProgram?> runCreateProgramFlow(
  BuildContext context,
) async {
  final selectedExercises = await Navigator.push<List<String>>(
    context,
    MaterialPageRoute(
      builder: (_) => const ExerciseLibraryScreen(multiSelect: true),
    ),
  );

  if (selectedExercises == null || selectedExercises.isEmpty) {
    return null;
  }

  if (!context.mounted) return null;

  final name = await showDialog<String>(
    context: context,
    builder: (_) => CreateProgramDialog(
      initialName: suggestWorkoutName(selectedExercises),
    ),
  );

  if (name == null) return null;

  final program = StoredWorkoutProgram(
    name: name,
    exercises: selectedExercises
        .map((exercise) => StoredExerciseTemplate(name: exercise))
        .toList(),
  );

  await ProgramRepository().addProgram(program);

  return program;
}
