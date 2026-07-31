import 'exercise.dart';
import 'workout_day.dart';

class WorkoutSession {
  final WorkoutDay workout;

  DateTime? startedAt;
  DateTime? finishedAt;

  final List<Exercise> exercises;
  String note;

  WorkoutSession({
    required this.workout,
    required this.exercises,
    this.note = '',
  });

  bool get hasStarted => startedAt != null;

  bool get hasFinished => finishedAt != null;

  void start() {
    startedAt = DateTime.now();
  }

  void finish() {
    finishedAt = DateTime.now();
  }

  Duration get duration {
    if (startedAt == null) {
      return Duration.zero;
    }

    return (finishedAt ?? DateTime.now())
        .difference(startedAt!);
  }
}