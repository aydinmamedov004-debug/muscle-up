import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/exercise.dart';
import '../../../models/workout_day.dart';
import '../../../models/workout_session.dart';
import '../../../models/workout_set.dart';
import '../../programs/providers/active_program_provider.dart';

class WorkoutSessionNotifier extends Notifier<WorkoutSession> {
  @override
  WorkoutSession build() {
    final program = ref.watch(activeProgramProvider);

    // Fallback if the user has no programs yet
    if (program == null) {
      return WorkoutSession(
        workout: const WorkoutDay(
          name: "No Program Selected",
          exercises: [],
        ),
        exercises: [],
      );
    }

    final exercises = program.exercises.map((exercise) {
      return Exercise(
        name: exercise.name,
        sets: List.generate(
          exercise.targetSets,
          (index) => WorkoutSet(number: index + 1),
        ),
      );
    }).toList();

    return WorkoutSession(
      workout: WorkoutDay(
        name: program.name,
        exercises: exercises,
      ),
      exercises: exercises,
    );
  }

  void startWorkout() {
    if (!state.hasStarted) {
      state.start();
      state = state;
    }
  }

  void addSet(Exercise exercise) {
    exercise.sets.add(
      WorkoutSet(number: exercise.sets.length + 1),
    );
    state = state;
  }

  void removeSet(Exercise exercise, int index) {
    if (exercise.sets.length <= 1) return;

    exercise.sets.removeAt(index);

    // Renumber the remaining sets
    for (int i = 0; i < exercise.sets.length; i++) {
      exercise.sets[i].number = i + 1;
    }

    state = state;
  }

  void finishWorkout() {
    if (!state.hasFinished) {
      state.finish();
      state = state;
    }
  }
}

final workoutSessionProvider =
    NotifierProvider<WorkoutSessionNotifier, WorkoutSession>(
  WorkoutSessionNotifier.new,
);