import 'workout_set.dart';

class Exercise {
  final String name;
  final List<WorkoutSet> sets;

  Exercise({
    required this.name,
    List<WorkoutSet>? sets,
  }) : sets = sets ??
            [
              WorkoutSet(number: 1),
              WorkoutSet(number: 2),
              WorkoutSet(number: 3),
            ];
}