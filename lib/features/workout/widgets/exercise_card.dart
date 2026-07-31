import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/exercise_catalog.dart';
import '../../../models/exercise.dart';
import '../../../shared/widgets/app_card.dart';
import '../../progress/providers/progress_provider.dart';
import '../providers/workout_provider.dart';
import 'set_row.dart';

class ExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final int exerciseNumber;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutNotifier =
        ref.read(workoutSessionProvider.notifier);

    final progressRepository =
        ref.watch(progressRepositoryProvider);

    final progress =
        progressRepository.getExerciseProgress(
      exercise.name,
    );

    final completedSets =
        exercise.sets.where((set) => set.completed).length;

    final muscleGroup = muscleGroupOf(exercise.name);
    final photo = exercisePhotoOf(exercise.name);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                child: Text(
                  exerciseNumber.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              if (photo != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    photo,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
              ] else if (muscleGroup != null) ...[
                Image.asset(
                  muscleGroup.diagramAsset,
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 12),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (progress.hasHistory) ...[
                      Text(
                        "Last: ${progress.lastWeight ?? "-"} kg × ${progress.lastReps ?? "-"} reps",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "🏆 Best: ${progress.personalBestWeight ?? "-"} kg × ${progress.personalBestReps ?? "-"} reps",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),
                    ],

                    Text(
                      "$completedSets / ${exercise.sets.length} sets completed",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    "SET",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "KG",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "REPS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 80),
              ],
            ),
          ),

          const SizedBox(height: 8),

          ...List.generate(
            exercise.sets.length,
            (index) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 6),
              child: SetRow(
                setNumber: index + 1,
                workoutSet: exercise.sets[index],
                onDelete: () {
                  workoutNotifier.removeSet(
                    exercise,
                    index,
                  );
                },
                onCompletedChanged: (completed) {
                  if (completed) {
                    workoutNotifier.startWorkout();
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                workoutNotifier.addSet(exercise);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Set"),
            ),
          ),
        ],
      ),
    );
  }
}