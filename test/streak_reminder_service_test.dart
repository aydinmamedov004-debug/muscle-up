import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_up/services/streak_reminder_service.dart';

void main() {
  // A Wednesday at 3pm — well inside the reminder window, mid-week.
  final wednesdayAfternoon = DateTime(2026, 8, 26, 15, 0);

  test('warns when goal not met and nothing done today', () {
    final result = StreakReminderService.decideReminder(
      weeklyGoal: 3,
      weekCompletionFlags: [true, false, false, false, false, false, false],
      now: wednesdayAfternoon,
    );

    expect(result, isNotNull);
    expect(result, contains('2'));
  });

  test('says "one more" when exactly one workout remains', () {
    final result = StreakReminderService.decideReminder(
      weeklyGoal: 3,
      weekCompletionFlags: [true, true, false, false, false, false, false],
      now: wednesdayAfternoon,
    );

    expect(result, "One more workout today keeps your streak alive.");
  });

  test('returns null once the weekly goal is already met', () {
    final result = StreakReminderService.decideReminder(
      weeklyGoal: 2,
      weekCompletionFlags: [true, true, false, false, false, false, false],
      now: wednesdayAfternoon,
    );

    expect(result, isNull);
  });

  test('returns null when today is already done, even if goal not met', () {
    // Wednesday = index 2
    final result = StreakReminderService.decideReminder(
      weeklyGoal: 5,
      weekCompletionFlags: [false, false, true, false, false, false, false],
      now: wednesdayAfternoon,
    );

    expect(result, isNull);
  });

  test('returns null after 7pm — too late for a same-day reminder', () {
    final result = StreakReminderService.decideReminder(
      weeklyGoal: 3,
      weekCompletionFlags: [false, false, false, false, false, false, false],
      now: DateTime(2026, 8, 26, 19, 30),
    );

    expect(result, isNull);
  });

  test('returns null for a malformed completion-flags list', () {
    final result = StreakReminderService.decideReminder(
      weeklyGoal: 3,
      weekCompletionFlags: [true, false, false],
      now: wednesdayAfternoon,
    );

    expect(result, isNull);
  });

  test('returns null for a non-positive weekly goal', () {
    final result = StreakReminderService.decideReminder(
      weeklyGoal: 0,
      weekCompletionFlags: [false, false, false, false, false, false, false],
      now: wednesdayAfternoon,
    );

    expect(result, isNull);
  });
}
