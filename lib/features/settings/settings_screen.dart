import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/program_repository.dart';
import '../../data/local/workout_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/section_header.dart';
import '../auth/providers/auth_provider.dart';
import '../home/providers/dashboard_provider.dart';
import '../programs/providers/active_program_provider.dart';
import '../progress/providers/progress_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

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
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Signed in",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? "",
                          style: const TextStyle(color: AppTheme.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            OutlinedButton.icon(
              onPressed: () {
                ref.read(authControllerProvider).signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
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
