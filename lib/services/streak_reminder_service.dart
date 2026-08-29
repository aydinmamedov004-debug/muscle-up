import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/local/hive_service.dart';
import '../data/local/profile_repository.dart';
import '../data/local/workout_repository.dart';

const _enabledKey = 'streakRemindersEnabled';
const _notificationId = 1001;
const _channelId = 'streak_reminders';
const _channelName = 'Streak Reminders';

/// Reminds the user in the evening if they haven't trained today and
/// haven't hit this week's goal yet — the one thing standing between them
/// and their weekly streak resetting. Entirely local: no server, no push
/// infra, just a single scheduled notification that gets re-evaluated
/// (and rescheduled or cancelled) whenever anything relevant changes.
class StreakReminderService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to whatever `timezone` defaults to (UTC) — the reminder
      // still fires, just possibly not at the intended local hour, which
      // beats not firing at all over an unrecognized identifier.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    _initialized = true;
  }

  bool get isEnabled =>
      (HiveService.appSettingsBoxRef.get(_enabledKey) as bool?) ?? true;

  Future<void> setEnabled(bool enabled) async {
    await HiveService.appSettingsBoxRef.put(_enabledKey, enabled);

    if (!enabled) {
      await _ensureInitialized();
      await _plugin.cancel(id: _notificationId);
    }
  }

  /// Requests the Android 13+ POST_NOTIFICATIONS permission. Safe to call
  /// unconditionally — once the user has answered the system prompt once,
  /// later calls just return the current status without prompting again.
  Future<bool> requestPermission() async {
    await _ensureInitialized();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return true;

    return await androidPlugin.requestNotificationsPermission() ?? false;
  }

  /// Re-evaluates streak risk from current profile/workout data and
  /// (re)schedules or cancels today's reminder to match. Cheap and
  /// idempotent — safe to call on app start and after every workout.
  Future<void> refreshForCurrentUser() async {
    final profile = ProfileRepository().getProfile();
    if (profile == null) return; // onboarding not finished yet

    await refresh(
      weeklyGoal: profile.weeklyGoal,
      weekCompletionFlags: WorkoutRepository().getCurrentWeekCompletionFlags(),
    );
  }

  /// Pure-ish version of [refreshForCurrentUser] taking its inputs directly,
  /// so the scheduling decision itself is testable without touching Hive.
  Future<void> refresh({
    required int weeklyGoal,
    required List<bool> weekCompletionFlags,
  }) async {
    await _ensureInitialized();

    if (!isEnabled) {
      await _plugin.cancel(id: _notificationId);
      return;
    }

    final decision = decideReminder(
      weeklyGoal: weeklyGoal,
      weekCompletionFlags: weekCompletionFlags,
      now: DateTime.now(),
    );

    if (decision == null) {
      await _plugin.cancel(id: _notificationId);
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      19, // 7pm local — evening, but early enough to still act on it
    );

    await _plugin.zonedSchedule(
      id: _notificationId,
      scheduledDate: scheduledDate,
      title: "Don't lose your streak 🔥",
      body: decision,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              "Reminds you before your weekly streak is at risk.",
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Decides whether a reminder is warranted right now and, if so, what it
  /// should say. Returns null when there's nothing to warn about (goal
  /// already met, already trained today) or it's too late in the day for a
  /// same-day evening reminder to make sense. Pulled out as a pure
  /// function of its inputs so this logic is unit-testable without a
  /// notifications plugin or a clock to mock.
  static String? decideReminder({
    required int weeklyGoal,
    required List<bool> weekCompletionFlags,
    required DateTime now,
  }) {
    if (weeklyGoal <= 0 || weekCompletionFlags.length != 7) return null;

    final daysCompleted = weekCompletionFlags.where((done) => done).length;
    final todayIndex = now.weekday - 1; // 0 = Monday
    final completedToday = weekCompletionFlags[todayIndex];

    if (daysCompleted >= weeklyGoal || completedToday) return null;

    // Too late for a same-day 7pm reminder to still be useful.
    if (now.hour >= 19) return null;

    final remaining = weeklyGoal - daysCompleted;

    return remaining == 1
        ? "One more workout today keeps your streak alive."
        : "You still need $remaining workouts this week to keep your streak.";
  }
}
