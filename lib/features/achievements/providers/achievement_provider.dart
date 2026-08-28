import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/achievement_repository.dart';
import '../../../data/local/profile_provider.dart';
import '../../../data/local/workout_history_watch_provider.dart';
import '../../../models/achievement.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final achievementStatusesProvider = Provider<List<AchievementStatus>>((ref) {
  ref.watch(workoutHistoryChangesProvider);
  final profile = ref.watch(profileProvider);
  final repository = ref.watch(achievementRepositoryProvider);

  return repository.getStatuses(weeklyGoal: profile?.weeklyGoal ?? 3);
});
