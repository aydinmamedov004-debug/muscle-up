import '../../models/exercise.dart';
import '../../models/workout_session.dart';
import '../../models/workout_set.dart';

import '../../models/storage/exercise_history.dart';
import '../../models/storage/set_history.dart';
import '../../models/storage/workout_history.dart';

class WorkoutMapper {
  static WorkoutHistory fromSession(WorkoutSession session) {
    return WorkoutHistory(
      workoutName: session.workout.name,
      completedAt: DateTime.now(),
      durationSeconds: session.duration.inSeconds,
      exercises: session.exercises.map(_mapExercise).toList(),
      note: session.note.trim().isEmpty ? null : session.note.trim(),
    );
  }

  static ExerciseHistory _mapExercise(Exercise exercise) {
    return ExerciseHistory(
      name: exercise.name,
      sets: exercise.sets.map(_mapSet).toList(),
    );
  }

  static SetHistory _mapSet(WorkoutSet set) {
    return SetHistory(
      weight: set.weight,
      reps: set.reps,
      completed: set.completed,
    );
  }
}