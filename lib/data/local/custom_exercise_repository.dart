import '../../models/storage/custom_exercise.dart';
import 'hive_service.dart';

class CustomExerciseRepository {
  List<CustomExercise> getAll() =>
      HiveService.customExercisesBoxRef.values.toList();

  Future<void> add(CustomExercise exercise) =>
      HiveService.customExercisesBoxRef.add(exercise);

  Future<void> delete(CustomExercise exercise) => exercise.delete();
}
