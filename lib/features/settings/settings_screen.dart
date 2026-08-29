import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/backup_service.dart';
import '../../data/local/program_repository.dart';
import '../../data/local/workout_repository.dart';
import '../../services/streak_reminder_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/section_header.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/upgrade_account_screen.dart';
import '../home/providers/dashboard_provider.dart';
import '../programs/providers/active_program_provider.dart';
import '../progress/providers/progress_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _reminderService = StreakReminderService();
  late bool remindersEnabled = _reminderService.isEnabled;

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _toggleReminders(bool enabled) async {
    setState(() => remindersEnabled = enabled);
    await _reminderService.setEnabled(enabled);

    if (!enabled) return;

    final granted = await _reminderService.requestPermission();
    await _reminderService.refreshForCurrentUser();

    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Notifications are blocked for this app — enable them in "
            "system settings for reminders to actually show up.",
          ),
        ),
      );
    }
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      await BackupService().exportBackup();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't create backup: $e")),
      );
    }
  }

  Future<void> _importBackup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await _confirm(
      context,
      title: "Restore from Backup",
      message:
          "This replaces all workouts, programs, custom exercises, and your "
          "profile with the contents of the backup file. This cannot be "
          "undone.",
    );

    if (!confirmed) return;
    if (!context.mounted) return;

    final picked = await FilePicker.pickFile(
      dialogTitle: "Select a Muscle Up backup",
      type: FileType.custom,
      allowedExtensions: ["json"],
    );

    final path = picked?.path;
    if (path == null) return;

    try {
      final jsonString = await File(path).readAsString();
      await BackupService().restoreFromJson(jsonString);

      ref.invalidate(dashboardProvider);
      ref.invalidate(progressDataProvider);
      ref.invalidate(activeProgramProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backup restored")),
      );
    } on BackupImportException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't read that file: $e")),
      );
    }
  }

  Future<void> _clearHistory(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await _confirm(
      context,
      title: "Clear Workout History",
      message:
          "This will permanently delete all recorded workouts. "
          "This action cannot be undone.",
    );

    if (!confirmed) return;

    await WorkoutRepository().clearHistory();

    ref.invalidate(dashboardProvider);
    ref.invalidate(progressDataProvider);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout history cleared")),
    );
  }

  Future<void> _clearPrograms(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await _confirm(
      context,
      title: "Delete All Programs",
      message:
          "This will permanently delete all workout programs. "
          "This action cannot be undone.",
    );

    if (!confirmed) return;

    await ProgramRepository().clearPrograms();

    ref.invalidate(activeProgramProvider);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Programs deleted")),
    );
  }

  Future<void> _upgradeAccount(BuildContext context) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const UpgradeAccountScreen()),
    );

    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created — your progress is saved")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final isGuest = ref.watch(isGuestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SectionHeader(title: "Account"),

            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    child: Icon(isGuest ? Icons.person_outline : Icons.person),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGuest ? "Guest" : (user?.displayName ?? "Signed in"),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isGuest
                              ? "Progress is saved on this device only"
                              : (user?.email ?? ""),
                          style: const TextStyle(color: AppTheme.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            if (isGuest) ...[
              FilledButton.icon(
                onPressed: () => _upgradeAccount(context),
                icon: const Icon(Icons.person_add_alt),
                label: const Text("Create Account"),
              ),

              const SizedBox(height: AppSpacing.sm),
            ],

            OutlinedButton.icon(
              onPressed: () {
                ref.read(authControllerProvider).signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
            ),

            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: "Notifications"),

            AppCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                borderRadius: AppRadius.large,
                clipBehavior: Clip.antiAlias,
                child: SwitchListTile(
                  title: const Text("Streak Reminders"),
                  subtitle: const Text(
                    "A nudge in the evening if you haven't trained today "
                    "and your weekly streak is at risk",
                  ),
                  value: remindersEnabled,
                  onChanged: _toggleReminders,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: "Backup"),

            AppCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                borderRadius: AppRadius.large,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.ios_share),
                      title: const Text("Export Backup"),
                      subtitle: const Text(
                        "Save your workouts, programs, and profile to a file",
                      ),
                      onTap: () => _exportBackup(context),
                    ),

                    const Divider(height: 1),

                    ListTile(
                      leading: const Icon(Icons.settings_backup_restore),
                      title: const Text("Restore from Backup"),
                      subtitle: const Text("Replaces all current app data"),
                      onTap: () => _importBackup(context, ref),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: "Data"),

            AppCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                borderRadius: AppRadius.large,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text("Clear Workout History"),
                      onTap: () => _clearHistory(context, ref),
                    ),

                    const Divider(height: 1),

                    ListTile(
                      leading: const Icon(Icons.playlist_remove),
                      title: const Text("Delete All Programs"),
                      onTap: () => _clearPrograms(context, ref),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: "About"),

            const AppCard(
              child: Row(
                children: [
                  Expanded(child: Text("Version")),
                  Text("1.0.0"),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.fabClearance),
          ],
        ),
      ),
    );
  }
}
