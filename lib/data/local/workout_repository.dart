import '../../models/dashboard_stats.dart';
import '../../models/progress/exercise_record.dart';
import '../../models/progress/exercise_weight_point.dart';
import '../../models/storage/workout_history.dart';
import 'hive_service.dart';

class WorkoutRepository {
  Future<void> saveWorkout(WorkoutHistory workout) async {
    await HiveService.historyBox.add(workout);
  }

  List<WorkoutHistory> getWorkouts() {
    return HiveService.historyBox.values.toList().reversed.toList();
  }

  Future<void> deleteWorkout(WorkoutHistory workout) async {
    await workout.delete();
  }

  Future<void> clearHistory() async {
    await HiveService.historyBox.clear();
  }

  DashboardStats getDashboardStats() {
    final workouts = getWorkouts();

    int totalSeconds = 0;

    for (final workout in workouts) {
      totalSeconds += workout.durationSeconds;
    }

    return DashboardStats(
      totalWorkouts: workouts.length,
      totalTrainingTime: Duration(seconds: totalSeconds),
    );
  }

  List<ExerciseRecord> getExerciseRecords() {
    final workouts = getWorkouts();

    final Map<String, ExerciseRecord> records = {};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        double maxWeight = 0;
        int maxReps = 0;
        double maxVolume = 0;

        for (final set in exercise.sets) {
          if (!set.completed) continue;

          final weight = set.weight ?? 0;
          final reps = set.reps ?? 0;

          final volume = weight * reps;

          if (weight > maxWeight) {
            maxWeight = weight;
          }

          if (reps > maxReps) {
            maxReps = reps;
          }

          if (volume > maxVolume) {
            maxVolume = volume;
          }
        }

        final existing = records[exercise.name];

        if (existing == null) {
          records[exercise.name] = ExerciseRecord(
            exerciseName: exercise.name,
            maxWeight: maxWeight,
            maxReps: maxReps,
            maxVolume: maxVolume,
          );
        } else {
          records[exercise.name] = ExerciseRecord(
            exerciseName: exercise.name,
            maxWeight:
                existing.maxWeight > maxWeight
                    ? existing.maxWeight
                    : maxWeight,
            maxReps:
                existing.maxReps > maxReps
                    ? existing.maxReps
                    : maxReps,
            maxVolume:
                existing.maxVolume > maxVolume
                    ? existing.maxVolume
                    : maxVolume,
          );
        }
      }
    }

    final result = records.values.toList();

    result.sort(
      (a, b) => a.exerciseName.compareTo(b.exerciseName),
    );

    return result;
  }

  /// The heaviest completed set for [exerciseName] in each workout that
  /// included it, oldest first — the data for a "weight over time" chart.
  List<ExerciseWeightPoint> getWeightHistory(String exerciseName) {
    final workouts = getWorkouts().reversed; // oldest first for a chart

    final points = <ExerciseWeightPoint>[];

    for (final workout in workouts) {
      double? maxWeight;

      for (final exercise in workout.exercises) {
        if (exercise.name != exerciseName) continue;

        for (final set in exercise.sets) {
          if (!set.completed || set.weight == null) continue;

          if (maxWeight == null || set.weight! > maxWeight) {
            maxWeight = set.weight;
          }
        }
      }

      if (maxWeight != null) {
        points.add(
          ExerciseWeightPoint(
            date: workout.completedAt,
            maxWeight: maxWeight,
          ),
        );
      }
    }

    return points;
  }
}
