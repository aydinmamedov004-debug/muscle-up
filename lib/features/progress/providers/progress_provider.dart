import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/workout_history_watch_provider.dart';
import '../../../data/local/workout_repository.dart';
import '../../../data/progress/progress_repository.dart';
import '../../../models/progress/exercise_record.dart';
import '../../../models/progress/exercise_weight_point.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

class ProgressData {
  final int totalWorkouts;
  final Duration totalTrainingTime;
  final List<ExerciseRecord> exerciseRecords;

  const ProgressData({
    required this.totalWorkouts,
    required this.totalTrainingTime,
    required this.exerciseRecords,
  });
}

final progressDataProvider = Provider<ProgressData>((ref) {
  ref.watch(workoutHistoryChangesProvider);

  final progressRepository = ref.watch(progressRepositoryProvider);
  final workoutRepository = WorkoutRepository();

  return ProgressData(
    totalWorkouts: progressRepository.totalWorkouts,
    totalTrainingTime: progressRepository.totalTrainingTime,
    exerciseRecords: workoutRepository.getExerciseRecords(),
  );
});

final exerciseWeightHistoryProvider =
    Provider.family<List<ExerciseWeightPoint>, String>((ref, exerciseName) {
  ref.watch(workoutHistoryChangesProvider);

  return WorkoutRepository().getWeightHistory(exerciseName);
});
