import '../../models/progress/exercise_progress.dart';
import '../../models/storage/exercise_history.dart';
import '../../models/storage/workout_history.dart';
import '../local/workout_repository.dart';

class ProgressRepository {
  final WorkoutRepository repository =
      WorkoutRepository();

  List<WorkoutHistory> get history =>
      repository.getWorkouts();

  int get totalWorkouts =>
      history.length;

  Duration get totalTrainingTime {
    int seconds = 0;

    for (final workout in history) {
      seconds += workout.durationSeconds;
    }

    return Duration(seconds: seconds);
  }

  ExerciseProgress getExerciseProgress(
    String exerciseName,
  ) {
    ExerciseHistory? latestExercise;

    for (final workout in history) {
      for (final exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          latestExercise = exercise;
          break;
        }
      }

      if (latestExercise != null) break;
    }

    double? lastWeight;
    int? lastReps;

    if (latestExercise != null) {
      final completedSets = latestExercise.sets
          .where((set) => set.completed)
          .toList();

      if (completedSets.isNotEmpty) {
        final bestSet = completedSets.reduce(
          (a, b) =>
              (a.weight ?? 0) > (b.weight ?? 0)
                  ? a
                  : b,
        );

        lastWeight = bestSet.weight;
        lastReps = bestSet.reps;
      }
    }

    double? personalBestWeight;
    int? personalBestReps;

    for (final workout in history) {
      for (final exercise in workout.exercises) {
        if (exercise.name != exerciseName) continue;

        for (final set in exercise.sets) {
          if (!set.completed) continue;

          if ((set.weight ?? 0) >
              (personalBestWeight ?? 0)) {
            personalBestWeight = set.weight;
            personalBestReps = set.reps;
          }
        }
      }
    }

    return ExerciseProgress(
      lastWeight: lastWeight,
      lastReps: lastReps,
      personalBestWeight: personalBestWeight,
      personalBestReps: personalBestReps,
    );
  }
}