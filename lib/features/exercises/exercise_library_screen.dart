import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/exercise_catalog.dart';
import '../../data/local/custom_exercise_repository.dart';
import '../../data/muscle_group.dart';
import '../../models/storage/custom_exercise.dart';
import 'exercise_detail_screen.dart';
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
  final searchController = TextEditingController();
  String query = '';
  MuscleGroup? selectedGroup;
  bool popularOnly = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
    final normalizedQuery = query.trim().toLowerCase();

    final exercises = allExercises.where((exercise) {
      if (popularOnly && !exercise.isPopular) return false;
      if (selectedGroup != null && exercise.group != selectedGroup) {
        return false;
      }
      if (normalizedQuery.isNotEmpty &&
          !exercise.name.toLowerCase().contains(normalizedQuery)) {
        return false;
      }
      return true;
    }).toList();

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search exercises...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() => query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text("Popular"),
                avatar: const Icon(Icons.star, size: 18),
                selected: popularOnly,
                onSelected: (value) => setState(() => popularOnly = value),
              ),
            ),
          ),

          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: const Text("All"),
                    selected: selectedGroup == null,
                    onSelected: (_) => setState(() => selectedGroup = null),
                  ),
                ),
                for (final group in MuscleGroup.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(group.label),
                      selected: selectedGroup == group,
                      onSelected: (_) =>
                          setState(() => selectedGroup = group),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: exercises.isEmpty
                ? const Center(child: Text("No exercises found"))
                : ListView.separated(
                    itemCount: exercises.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              tooltip: "Exercise details",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExerciseDetailScreen(
                                      exerciseName: exercise.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Icon(
                              widget.multiSelect
                                  ? (isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined)
                                  : Icons.add,
                            ),
                          ],
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
          ),
        ],
      ),
    );
  }
}
