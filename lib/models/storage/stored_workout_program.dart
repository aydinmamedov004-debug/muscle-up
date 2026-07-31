import 'package:hive_ce/hive.dart';

import 'stored_exercise_template.dart';

part 'stored_workout_program.g.dart';

@HiveType(typeId: 5)
class StoredWorkoutProgram extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<StoredExerciseTemplate> exercises;

  StoredWorkoutProgram({
    required this.name,
    required this.exercises,
  });
}