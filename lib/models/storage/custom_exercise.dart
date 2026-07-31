import 'package:hive_ce/hive.dart';

part 'custom_exercise.g.dart';

@HiveType(typeId: 6)
class CustomExercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String muscleGroupName;

  CustomExercise({
    required this.name,
    required this.muscleGroupName,
  });
}
