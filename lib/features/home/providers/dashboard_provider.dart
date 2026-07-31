import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/workout_history_watch_provider.dart';
import '../../../data/local/workout_repository.dart';
import '../../../models/dashboard_stats.dart';
import '../../../models/storage/workout_history.dart';

class DashboardData {
  final DashboardStats stats;
  final List<WorkoutHistory> workouts;

  const DashboardData({
    required this.stats,
    required this.workouts,
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  ref.watch(workoutHistoryChangesProvider);

  final repository = WorkoutRepository();

  return DashboardData(
    stats: repository.getDashboardStats(),
    workouts: repository.getWorkouts(),
  );
});
