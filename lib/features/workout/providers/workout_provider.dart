import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/exercise.dart';
import '../../../models/workout_day.dart';
import '../../../models/workout_session.dart';
import '../../../models/workout_set.dart';
import '../../exercises/providers/exercise_guidance_service.dart';
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

    // The exercise list only populates once the user explicitly begins a
    // session (from Home's Start Workout button) — otherwise the Workout
    // tab would immediately refill with today's program right after the
    // user finishes and returns home.
    final active = ref.watch(workoutSessionActiveProvider);

    if (!active) {
      return WorkoutSession(
        workout: WorkoutDay(
          name: program.name,
          exercises: const [],
        ),
        exercises: const [],
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

  void beginSession() {
    ref.read(workoutSessionActiveProvider.notifier).state = true;
    _prewarmGuidance();
  }

  /// Best-effort background warm-up: quietly generates (or reuses cached)
  /// form guidance for every exercise in the session's program as soon as
  /// it starts, so by the time someone actually taps an exercise's info
  /// icon mid-workout it's usually already there — the AI call that used
  /// to only happen on that tap (and can take a while) mostly happens
  /// invisibly beforehand instead. Sequential rather than parallel to stay
  /// gentle on the API, and failures are swallowed since this is opportunistic
  /// — the detail screen still generates on demand if this hasn't finished.
  Future<void> _prewarmGuidance() async {
    final program = ref.read(activeProgramProvider);
    if (program == null) return;

    final service = ExerciseGuidanceService();
    for (final exercise in program.exercises) {
      try {
        await service.getGuidance(exercise.name);
      } catch (_) {
        // Opportunistic only — ignore and let the detail screen retry.
      }
    }
  }

  void endSession() {
    ref.read(workoutSessionActiveProvider.notifier).state = false;
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

final workoutSessionActiveProvider = StateProvider<bool>((ref) => false);