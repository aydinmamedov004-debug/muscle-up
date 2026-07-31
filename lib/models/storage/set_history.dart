import 'package:hive_ce/hive.dart';

part 'set_history.g.dart';

@HiveType(typeId: 1)
class SetHistory extends HiveObject {
  @HiveField(0)
  final double? weight;

  @HiveField(1)
  final int? reps;

  @HiveField(2)
  final bool completed;

  SetHistory({
    required this.weight,
    required this.reps,
    required this.completed,
  });
}