import 'package:hive_ce/hive.dart';

import 'set_history.dart';

part 'exercise_history.g.dart';

@HiveType(typeId: 2)
class ExerciseHistory extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<SetHistory> sets;

  ExerciseHistory({
    required this.name,
    required this.sets,
  });
}