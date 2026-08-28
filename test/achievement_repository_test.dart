import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muscle_up/data/achievement_repository.dart';
import 'package:muscle_up/data/local/hive_service.dart';
import 'package:muscle_up/models/achievement.dart';
import 'package:muscle_up/models/storage/exercise_history.dart';
import 'package:muscle_up/models/storage/set_history.dart';
import 'package:muscle_up/models/storage/workout_history.dart';

void main() {
  late Directory tempDir;
  final repository = AchievementRepository();

  WorkoutHistory workoutOn(
    DateTime day, {
    int durationSeconds = 1800,
    List<ExerciseHistory> exercises = const [],
  }) => WorkoutHistory(
    workoutName: 'Test',
    completedAt: day,
    durationSeconds: durationSeconds,
    exercises: exercises,
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_achievement_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(SetHistoryAdapter().typeId)) {
      Hive.registerAdapter(SetHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(ExerciseHistoryAdapter().typeId)) {
      Hive.registerAdapter(ExerciseHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutHistoryAdapter().typeId)) {
      Hive.registerAdapter(WorkoutHistoryAdapter());
    }
    await Hive.openBox<WorkoutHistory>(HiveService.workoutHistoryBox);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('no workouts => nothing is unlocked', () {
    final statuses = repository.getStatuses(weeklyGoal: 3);

    expect(statuses, isNotEmpty);
    expect(statuses.every((s) => !s.isUnlocked), isTrue);
    expect(statuses.every((s) => s.currentValue == 0), isTrue);
  });

  test('first workout unlocks the workout-count-1 achievement', () async {
    await HiveService.historyBox.add(workoutOn(DateTime.now()));

    final statuses = repository.getStatuses(weeklyGoal: 3);
    final first = statuses.firstWhere((s) => s.achievement.id == 'workouts_1');
    final ten = statuses.firstWhere((s) => s.achievement.id == 'workouts_10');

    expect(first.isUnlocked, isTrue);
    expect(ten.isUnlocked, isFalse);
    expect(ten.currentValue, 1);
    expect(ten.progress, closeTo(0.1, 0.001));
  });

  test('training-time achievement tracks summed duration in minutes', () async {
    await HiveService.historyBox.add(
      workoutOn(DateTime.now(), durationSeconds: 1800), // 30 min
    );
    await HiveService.historyBox.add(
      workoutOn(
        DateTime.now().subtract(const Duration(days: 1)),
        durationSeconds: 1800, // 30 min
      ),
    );

    final statuses = repository.getStatuses(weeklyGoal: 3);
    final firstHour = statuses.firstWhere((s) => s.achievement.id == 'time_60');

    expect(firstHour.currentValue, 60);
    expect(firstHour.isUnlocked, isTrue);
  });

  test('variety achievement counts distinct exercise names across workouts', () async {
    await HiveService.historyBox.add(
      workoutOn(
        DateTime.now(),
        exercises: [
          ExerciseHistory(name: 'Bench Press', sets: const []),
          ExerciseHistory(name: 'Squat', sets: const []),
        ],
      ),
    );
    await HiveService.historyBox.add(
      workoutOn(
        DateTime.now().subtract(const Duration(days: 1)),
        exercises: [
          ExerciseHistory(name: 'Bench Press', sets: const []), // repeat
          ExerciseHistory(name: 'Deadlift', sets: const []),
        ],
      ),
    );

    final statuses = repository.getStatuses(weeklyGoal: 3);
    final explorer = statuses.firstWhere(
      (s) => s.achievement.id == 'variety_5',
    );

    // 3 distinct: Bench Press, Squat, Deadlift
    expect(explorer.currentValue, 3);
  });

  test('single-session achievement tracks the longest workout, not the sum', () async {
    await HiveService.historyBox.add(
      workoutOn(DateTime.now(), durationSeconds: 3600), // 60 min
    );
    await HiveService.historyBox.add(
      workoutOn(
        DateTime.now().subtract(const Duration(days: 1)),
        durationSeconds: 600, // 10 min
      ),
    );

    final statuses = repository.getStatuses(weeklyGoal: 3);
    final ironWill = statuses.firstWhere(
      (s) => s.achievement.id == 'session_60',
    );

    expect(ironWill.currentValue, 60);
    expect(ironWill.isUnlocked, isTrue);
  });

  test('newlyUnlocked only returns achievements that just crossed the line', () async {
    final before = repository.getStatuses(weeklyGoal: 3);

    await HiveService.historyBox.add(workoutOn(DateTime.now()));

    final after = repository.getStatuses(weeklyGoal: 3);
    final newly = repository.newlyUnlocked(before: before, after: after);

    expect(newly.map((a) => a.id), ['workouts_1']);
  });

  test('newlyUnlocked is empty when nothing changed', () {
    final before = repository.getStatuses(weeklyGoal: 3);
    final after = repository.getStatuses(weeklyGoal: 3);

    expect(repository.newlyUnlocked(before: before, after: after), isEmpty);
  });

  test('AchievementStatus.progress is clamped to 1.0 past the threshold', () {
    const achievement = Achievement(
      id: 'test',
      title: 'Test',
      description: 'Test',
      icon: Icons.star,
      metric: AchievementMetric.totalWorkouts,
      threshold: 10,
    );

    const status = AchievementStatus(achievement: achievement, currentValue: 50);

    expect(status.progress, 1.0);
    expect(status.isUnlocked, isTrue);
  });
}
