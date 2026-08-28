import '../models/achievement.dart';
import '../models/storage/workout_history.dart';
import 'achievement_catalog.dart';
import 'local/workout_repository.dart';

class AchievementRepository {
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  /// Evaluates the full catalog against current workout history.
  List<AchievementStatus> getStatuses({required int weeklyGoal}) {
    final workouts = _workoutRepository.getWorkouts();
    final aggregates = _Aggregates.from(_workoutRepository, workouts, weeklyGoal);

    return achievementCatalog
        .map(
          (achievement) => AchievementStatus(
            achievement: achievement,
            currentValue: aggregates.valueFor(achievement.metric),
          ),
        )
        .toList();
  }

  /// The achievements present in [after] but not unlocked in [before] —
  /// used right after saving a workout to detect what just changed, so the
  /// app can celebrate it instead of silently updating a progress bar
  /// nobody's looking at.
  List<Achievement> newlyUnlocked({
    required List<AchievementStatus> before,
    required List<AchievementStatus> after,
  }) {
    final unlockedBeforeIds = before
        .where((status) => status.isUnlocked)
        .map((status) => status.achievement.id)
        .toSet();

    return after
        .where(
          (status) =>
              status.isUnlocked &&
              !unlockedBeforeIds.contains(status.achievement.id),
        )
        .map((status) => status.achievement)
        .toList();
  }
}

class _Aggregates {
  final int totalWorkouts;
  final int currentStreak;
  final int totalTrainingMinutes;
  final int distinctExercises;
  final int longestWorkoutMinutes;

  const _Aggregates({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.totalTrainingMinutes,
    required this.distinctExercises,
    required this.longestWorkoutMinutes,
  });

  factory _Aggregates.from(
    WorkoutRepository repository,
    List<WorkoutHistory> workouts,
    int weeklyGoal,
  ) {
    final stats = repository.getDashboardStats(weeklyGoal: weeklyGoal);

    final distinctExercises = <String>{};
    var longestSeconds = 0;

    for (final workout in workouts) {
      if (workout.durationSeconds > longestSeconds) {
        longestSeconds = workout.durationSeconds;
      }
      for (final exercise in workout.exercises) {
        distinctExercises.add(exercise.name);
      }
    }

    return _Aggregates(
      totalWorkouts: stats.totalWorkouts,
      currentStreak: stats.currentStreak,
      totalTrainingMinutes: stats.totalTrainingTime.inMinutes,
      distinctExercises: distinctExercises.length,
      longestWorkoutMinutes: longestSeconds ~/ 60,
    );
  }

  num valueFor(AchievementMetric metric) {
    switch (metric) {
      case AchievementMetric.totalWorkouts:
        return totalWorkouts;
      case AchievementMetric.currentStreak:
        return currentStreak;
      case AchievementMetric.totalTrainingMinutes:
        return totalTrainingMinutes;
      case AchievementMetric.distinctExercises:
        return distinctExercises;
      case AchievementMetric.longestWorkoutMinutes:
        return longestWorkoutMinutes;
    }
  }
}
