import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muscle_up/data/local/hive_service.dart';
import 'package:muscle_up/data/local/workout_repository.dart';
import 'package:muscle_up/models/storage/exercise_history.dart';
import 'package:muscle_up/models/storage/set_history.dart';
import 'package:muscle_up/models/storage/workout_history.dart';

/// Mirrors WorkoutRepository's private week-bucketing exactly, so tests can
/// deterministically place workouts within "this week", "last week", etc.
/// regardless of what day it actually is when the suite runs.
DateTime _startOfWeek(DateTime date) {
  final utcDate = DateTime.utc(date.year, date.month, date.day);
  return utcDate.subtract(Duration(days: utcDate.weekday - 1));
}

void main() {
  late Directory tempDir;
  final repo = WorkoutRepository();
  final thisWeekStart = _startOfWeek(DateTime.now());

  DateTime weekDay(int weeksAgo, int dayOffset) => thisWeekStart
      .subtract(Duration(days: 7 * weeksAgo))
      .add(Duration(days: dayOffset));

  WorkoutHistory workoutOn(DateTime day) => WorkoutHistory(
    workoutName: 'Test',
    completedAt: day,
    durationSeconds: 1800,
    exercises: const [],
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_streak_test_');
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

  test('no workouts => streak is 0', () {
    expect(repo.getDashboardStats(weeklyGoal: 3).currentStreak, 0);
  });

  test(
    'goal met last week plus partial current week accumulates',
    () async {
      // Goal 2/week. Last week hit the goal exactly (2 days). This week
      // only has 1 day logged so far, but it's still in progress.
      await HiveService.historyBox.add(workoutOn(weekDay(0, 0)));
      await HiveService.historyBox.add(workoutOn(weekDay(1, 0)));
      await HiveService.historyBox.add(workoutOn(weekDay(1, 1)));

      expect(repo.getDashboardStats(weeklyGoal: 2).currentStreak, 3);
    },
  );

  test('a shortfall week stops accumulation and is excluded', () async {
    // Goal 2/week. Last week only had 1 day (a shortfall), so it should
    // NOT be added, and the two-weeks-ago week (which would pass) should
    // never even be reached.
    await HiveService.historyBox.add(workoutOn(weekDay(0, 0)));
    await HiveService.historyBox.add(workoutOn(weekDay(1, 0)));
    await HiveService.historyBox.add(workoutOn(weekDay(2, 0)));
    await HiveService.historyBox.add(workoutOn(weekDay(2, 1)));

    expect(repo.getDashboardStats(weeklyGoal: 2).currentStreak, 1);
  });

  test('multiple consecutive passing weeks all accumulate', () async {
    // Goal 1/week, three weeks in a row (including the current one) each
    // have exactly one day logged.
    await HiveService.historyBox.add(workoutOn(weekDay(0, 0)));
    await HiveService.historyBox.add(workoutOn(weekDay(1, 0)));
    await HiveService.historyBox.add(workoutOn(weekDay(2, 0)));

    expect(repo.getDashboardStats(weeklyGoal: 1).currentStreak, 3);
  });

  test('a week exceeding the goal contributes its full count', () async {
    // Goal 2/week. Last week had 3 days logged (exceeds the goal) — the
    // full 3 should count, not be capped at 2.
    await HiveService.historyBox.add(workoutOn(weekDay(1, 0)));
    await HiveService.historyBox.add(workoutOn(weekDay(1, 1)));
    await HiveService.historyBox.add(workoutOn(weekDay(1, 2)));

    expect(repo.getDashboardStats(weeklyGoal: 2).currentStreak, 3);
  });

  test('two workouts on the same day count once', () async {
    await HiveService.historyBox.add(workoutOn(weekDay(0, 0)));
    await HiveService.historyBox.add(workoutOn(weekDay(0, 0)));

    expect(repo.getDashboardStats(weeklyGoal: 1).currentStreak, 1);
  });

  test(
    'the current in-progress week is never treated as a shortfall',
    () async {
      // Goal 5/week, but only 1 day logged this week so far. It should
      // still show 1, not reset to 0 just because the week isn't over.
      await HiveService.historyBox.add(workoutOn(weekDay(0, 0)));

      expect(repo.getDashboardStats(weeklyGoal: 5).currentStreak, 1);
    },
  );
}
