import 'package:flutter/material.dart';

import '../../data/exercise_catalog.dart';
import '../../data/local/custom_exercise_repository.dart';
import '../../models/storage/custom_exercise.dart';
import 'widgets/create_exercise_dialog.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final bool multiSelect;

  const ExerciseLibraryScreen({
    super.key,
    this.multiSelect = false,
  });

  @override
  State<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final Set<String> selected = {};

  Future<void> _createExercise() async {
    final exercise = await showDialog<CatalogExercise>(
      context: context,
      builder: (_) => const CreateExerciseDialog(),
    );

    if (exercise == null) return;

    await CustomExerciseRepository().add(
      CustomExercise(
        name: exercise.name,
        muscleGroupName: exercise.group.name,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final exercises = allExercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise Library"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Exercise",
            onPressed: _createExercise,
          ),

          if (widget.multiSelect)
            TextButton(
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context, selected.toList());
                    },
              child: Text("Done (${selected.length})"),
            ),
        ],
      ),
      body: ListView.separated(
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          final isSelected = selected.contains(exercise.name);

          final photo = exercisePhotoOf(exercise.name);

          return ListTile(
            leading: photo != null
                ? CircleAvatar(backgroundImage: AssetImage(photo))
                : CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      exercise.group.diagramAsset,
                      width: 32,
                      height: 32,
                    ),
                  ),
            title: Text(exercise.name),
            subtitle: Text(exercise.group.label),
            trailing: Icon(
              widget.multiSelect
                  ? (isSelected
                      ? Icons.check_circle
                      : Icons.circle_outlined)
                  : Icons.add,
            ),
            onTap: () {
              if (!widget.multiSelect) {
                Navigator.pop(context, exercise.name);
                return;
              }

              setState(() {
                if (isSelected) {
                  selected.remove(exercise.name);
                } else {
                  selected.add(exercise.name);
                }
              });
            },
          );
        },
      ),
    );
  }
}
