import 'package:hive_ce/hive.dart';

part 'stored_exercise_template.g.dart';

@HiveType(typeId: 4)
class StoredExerciseTemplate extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int targetSets;

  @HiveField(2)
  int minReps;

  @HiveField(3)
  int maxReps;

  @HiveField(4)
  int restSeconds;

  StoredExerciseTemplate({
    required this.name,
    this.targetSets = 3,
    this.minReps = 8,
    this.maxReps = 12,
    this.restSeconds = 90,
  });
}