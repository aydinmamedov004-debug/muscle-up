import 'package:flutter/material.dart';

/// What an [Achievement]'s threshold is measured against. Deliberately a
/// small fixed set rather than an arbitrary predicate, so the whole catalog
/// can be evaluated from a handful of aggregates computed once per
/// [AchievementRepository.getStatuses] call instead of each achievement
/// re-scanning workout history independently.
enum AchievementMetric {
  totalWorkouts,
  currentStreak,
  totalTrainingMinutes,
  distinctExercises,
  longestWorkoutMinutes,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementMetric metric;
  final num threshold;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.metric,
    required this.threshold,
  });
}

/// An [Achievement] paired with the user's current progress toward it.
class AchievementStatus {
  final Achievement achievement;
  final num currentValue;

  const AchievementStatus({
    required this.achievement,
    required this.currentValue,
  });

  bool get isUnlocked => currentValue >= achievement.threshold;

  double get progress =>
      (currentValue / achievement.threshold).clamp(0, 1).toDouble();
}
