import 'package:flutter/material.dart';

import '../../models/storage/stored_exercise_template.dart';
import '../../models/storage/stored_workout_program.dart';
import '../exercises/exercise_library_screen.dart';

class EditProgramScreen extends StatefulWidget {
  final StoredWorkoutProgram program;

  const EditProgramScreen({
    super.key,
    required this.program,
  });

  @override
  State<EditProgramScreen> createState() =>
      _EditProgramScreenState();
}

class _EditProgramScreenState
    extends State<EditProgramScreen> {
  Future<void> addExercise() async {
    final String? exercise =
        await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ExerciseLibraryScreen(),
      ),
    );

    if (exercise == null) return;

    setState(() {
      widget.program.exercises.add(
        StoredExerciseTemplate(
          name: exercise,
        ),
      );
    });

    await widget.program.save();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Exercise added"),
      ),
    );
  }

  Future<void> renameProgram() async {
    final controller = TextEditingController(
      text: widget.program.name,
    );

    final String? newName =
        await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Rename Program"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Program name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newName == null || newName.isEmpty) {
      return;
    }

    setState(() {
      widget.program.name = newName;
    });

    await widget.program.save();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Program renamed"),
      ),
    );
  }

  Future<void> deleteExercise(int index) async {
    final exercise =
        widget.program.exercises[index];

    setState(() {
      widget.program.exercises.removeAt(index);
    });

    await widget.program.save();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${exercise.name} removed",
        ),
      ),
    );
  }

  Future<void> reorderExercises(
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) {
      newIndex--;
    }

    setState(() {
      final exercise =
          widget.program.exercises.removeAt(oldIndex);

      widget.program.exercises.insert(
        newIndex,
        exercise,
      );
    });

    await widget.program.save();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Exercise order updated"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: renameProgram,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addExercise,
        child: const Icon(Icons.add),
      ),
      body: widget.program.exercises.isEmpty
          ? const Center(
              child: Text(
                "No exercises yet.\nTap + to add one.",
                textAlign: TextAlign.center,
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount:
                  widget.program.exercises.length,
              onReorder: reorderExercises,
              itemBuilder: (_, index) {
                final exercise =
                    widget.program.exercises[index];

                return Dismissible(
                  key: ValueKey(
                    "${exercise.name}_$index",
                  ),
                  direction:
                      DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.only(right: 24),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    deleteExercise(index);
                  },
                  child: ListTile(
                    key: ValueKey(
                      "tile_$index",
                    ),
                    leading: const Icon(
                      Icons.drag_handle,
                    ),
                    title: Text(exercise.name),
                    subtitle: Text(
                      "${exercise.targetSets} sets • "
                      "${exercise.minReps}-${exercise.maxReps} reps",
                    ),
                    trailing: const Icon(
                      Icons.fitness_center,
                    ),
                  ),
                );
              },
            ),
    );
  }
}