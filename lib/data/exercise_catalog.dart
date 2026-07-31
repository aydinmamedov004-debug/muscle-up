import 'local/custom_exercise_repository.dart';
import 'muscle_group.dart';

class CatalogExercise {
  final String name;
  final MuscleGroup group;

  const CatalogExercise(this.name, this.group);
}

const List<CatalogExercise> exerciseCatalog = [
  // Chest
  CatalogExercise("Bench Press", MuscleGroup.chest),
  CatalogExercise("Incline Bench Press", MuscleGroup.chest),
  CatalogExercise("Decline Bench Press", MuscleGroup.chest),
  CatalogExercise("Chest Fly", MuscleGroup.chest),
  CatalogExercise("Cable Fly", MuscleGroup.chest),
  CatalogExercise("Push-Up", MuscleGroup.chest),

  // Shoulders
  CatalogExercise("Overhead Press", MuscleGroup.shoulders),
  CatalogExercise("Arnold Press", MuscleGroup.shoulders),
  CatalogExercise("Lateral Raise", MuscleGroup.shoulders),
  CatalogExercise("Front Raise", MuscleGroup.shoulders),
  CatalogExercise("Rear Delt Fly", MuscleGroup.shoulders),

  // Back
  CatalogExercise("Pull-Up", MuscleGroup.back),
  CatalogExercise("Chin-Up", MuscleGroup.back),
  CatalogExercise("Lat Pulldown", MuscleGroup.back),
  CatalogExercise("Barbell Row", MuscleGroup.back),
  CatalogExercise("Seated Cable Row", MuscleGroup.back),
  CatalogExercise("T-Bar Row", MuscleGroup.back),
  CatalogExercise("Deadlift", MuscleGroup.back),

  // Arms (biceps + triceps)
  CatalogExercise("Barbell Curl", MuscleGroup.arms),
  CatalogExercise("Dumbbell Curl", MuscleGroup.arms),
  CatalogExercise("Hammer Curl", MuscleGroup.arms),
  CatalogExercise("Preacher Curl", MuscleGroup.arms),
  CatalogExercise("Triceps Pushdown", MuscleGroup.arms),
  CatalogExercise("Overhead Extension", MuscleGroup.arms),
  CatalogExercise("Skull Crusher", MuscleGroup.arms),
  CatalogExercise("Dips", MuscleGroup.arms),

  // Legs
  CatalogExercise("Squat", MuscleGroup.legs),
  CatalogExercise("Front Squat", MuscleGroup.legs),
  CatalogExercise("Bulgarian Split Squat", MuscleGroup.legs),
  CatalogExercise("Romanian Deadlift", MuscleGroup.legs),
  CatalogExercise("Leg Press", MuscleGroup.legs),
  CatalogExercise("Leg Extension", MuscleGroup.legs),
  CatalogExercise("Leg Curl", MuscleGroup.legs),
  CatalogExercise("Calf Raise", MuscleGroup.legs),

  // Core
  CatalogExercise("Crunch", MuscleGroup.core),
  CatalogExercise("Cable Crunch", MuscleGroup.core),
  CatalogExercise("Plank", MuscleGroup.core),
  CatalogExercise("Hanging Leg Raise", MuscleGroup.core),
];

/// Built-in exercises plus any the user has created themselves.
List<CatalogExercise> get allExercises => [
      ...exerciseCatalog,
      ...CustomExerciseRepository().getAll().map(
            (exercise) => CatalogExercise(
              exercise.name,
              MuscleGroup.values.byName(exercise.muscleGroupName),
            ),
          ),
    ];

MuscleGroup? muscleGroupOf(String exerciseName) {
  for (final exercise in allExercises) {
    if (exercise.name == exerciseName) return exercise.group;
  }

  return null;
}

final Set<String> _builtInExerciseNames =
    exerciseCatalog.map((exercise) => exercise.name).toSet();

/// A real demonstration photo for built-in exercises (sourced from
/// free-exercise-db, public domain). Custom exercises the user creates
/// don't have one — fall back to [MuscleGroup.diagramAsset] for those.
String? exercisePhotoOf(String exerciseName) {
  if (!_builtInExerciseNames.contains(exerciseName)) return null;

  final slug = exerciseName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  return "assets/exercises/$slug.jpg";
}
