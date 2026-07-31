import '../../models/exercise.dart';
import '../../models/workout_day.dart';
import '../../models/workout_session.dart';
import '../../models/workout_set.dart';
import '../../models/storage/stored_workout_program.dart';

class WorkoutFactory {
  static WorkoutSession fromProgram(
    StoredWorkoutProgram program,
  ) {
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
}