import 'package:hive_ce/hive.dart';

import 'exercise_history.dart';

part 'workout_history.g.dart';

@HiveType(typeId: 0)
class WorkoutHistory extends HiveObject {
  @HiveField(0)
  final String workoutName;

  @HiveField(1)
  final DateTime completedAt;

  @HiveField(2)
  final int durationSeconds;

  @HiveField(3)
  final List<ExerciseHistory> exercises;

  @HiveField(4)
  final String? note;

  WorkoutHistory({
    required this.workoutName,
    required this.completedAt,
    required this.durationSeconds,
    required this.exercises,
    this.note,
  });
}