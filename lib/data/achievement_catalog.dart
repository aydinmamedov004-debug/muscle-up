import 'package:flutter/material.dart';

import '../models/achievement.dart';

/// The full, fixed set of achievements the app tracks. Every one of these
/// is evaluated fresh from workout history each time — there's no
/// "unlocked" flag persisted anywhere, since the history itself is already
/// the source of truth and re-deriving from it is cheap.
const List<Achievement> achievementCatalog = [
  // --- Workout count ---
  Achievement(
    id: 'workouts_1',
    title: 'First Workout',
    description: 'You showed up — that\'s the hardest part.',
    icon: Icons.flag,
    metric: AchievementMetric.totalWorkouts,
    threshold: 1,
  ),
  Achievement(
    id: 'workouts_10',
    title: 'Getting Started',
    description: 'Complete 10 workouts.',
    icon: Icons.fitness_center,
    metric: AchievementMetric.totalWorkouts,
    threshold: 10,
  ),
  Achievement(
    id: 'workouts_25',
    title: 'Committed',
    description: 'Complete 25 workouts.',
    icon: Icons.fitness_center,
    metric: AchievementMetric.totalWorkouts,
    threshold: 25,
  ),
  Achievement(
    id: 'workouts_50',
    title: 'Dedicated',
    description: 'Complete 50 workouts.',
    icon: Icons.military_tech,
    metric: AchievementMetric.totalWorkouts,
    threshold: 50,
  ),
  Achievement(
    id: 'workouts_100',
    title: 'Century Club',
    description: 'Complete 100 workouts.',
    icon: Icons.emoji_events,
    metric: AchievementMetric.totalWorkouts,
    threshold: 100,
  ),

  // --- Consistency (accumulated days across an unbroken run of weeks
  // that hit the weekly goal — same value the streak counter shows) ---
  Achievement(
    id: 'streak_7',
    title: 'Week One',
    description: 'Reach a 7-day streak.',
    icon: Icons.local_fire_department,
    metric: AchievementMetric.currentStreak,
    threshold: 7,
  ),
  Achievement(
    id: 'streak_30',
    title: 'On a Roll',
    description: 'Reach a 30-day streak.',
    icon: Icons.local_fire_department,
    metric: AchievementMetric.currentStreak,
    threshold: 30,
  ),
  Achievement(
    id: 'streak_60',
    title: 'Unstoppable',
    description: 'Reach a 60-day streak.',
    icon: Icons.local_fire_department,
    metric: AchievementMetric.currentStreak,
    threshold: 60,
  ),
  Achievement(
    id: 'streak_100',
    title: 'Iron Habit',
    description: 'Reach a 100-day streak.',
    icon: Icons.local_fire_department,
    metric: AchievementMetric.currentStreak,
    threshold: 100,
  ),

  // --- Training time ---
  Achievement(
    id: 'time_60',
    title: 'First Hour',
    description: 'Log 1 hour of total training time.',
    icon: Icons.timer_outlined,
    metric: AchievementMetric.totalTrainingMinutes,
    threshold: 60,
  ),
  Achievement(
    id: 'time_600',
    title: 'Half Day',
    description: 'Log 10 hours of total training time.',
    icon: Icons.timer_outlined,
    metric: AchievementMetric.totalTrainingMinutes,
    threshold: 600,
  ),
  Achievement(
    id: 'time_1440',
    title: 'Full Day',
    description: 'Log 24 hours of total training time.',
    icon: Icons.timer,
    metric: AchievementMetric.totalTrainingMinutes,
    threshold: 1440,
  ),
  Achievement(
    id: 'time_6000',
    title: 'Marathon',
    description: 'Log 100 hours of total training time.',
    icon: Icons.timer,
    metric: AchievementMetric.totalTrainingMinutes,
    threshold: 6000,
  ),

  // --- Variety ---
  Achievement(
    id: 'variety_5',
    title: 'Explorer',
    description: 'Log 5 different exercises.',
    icon: Icons.explore_outlined,
    metric: AchievementMetric.distinctExercises,
    threshold: 5,
  ),
  Achievement(
    id: 'variety_15',
    title: 'Well-Rounded',
    description: 'Log 15 different exercises.',
    icon: Icons.explore,
    metric: AchievementMetric.distinctExercises,
    threshold: 15,
  ),
  Achievement(
    id: 'variety_30',
    title: 'Renaissance Lifter',
    description: 'Log 30 different exercises.',
    icon: Icons.explore,
    metric: AchievementMetric.distinctExercises,
    threshold: 30,
  ),

  // --- Single-session ---
  Achievement(
    id: 'session_60',
    title: 'Iron Will',
    description: 'Complete a single workout lasting 60+ minutes.',
    icon: Icons.bolt,
    metric: AchievementMetric.longestWorkoutMinutes,
    threshold: 60,
  ),
];
