import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/stat_tile.dart';
import '../auth/providers/auth_provider.dart';
import '../programs/create_program_flow.dart';
import '../programs/program_list_screen.dart';
import 'providers/dashboard_provider.dart';
import '../programs/providers/active_program_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String formatTrainingTime(Duration duration) {
    if (duration.inHours > 0) {
      return "${duration.inHours}h";
    }

    return "${duration.inMinutes}m";
  }

  String _greeting(String? name) {
    final hour = DateTime.now().hour;

    final timeOfDay = hour < 12
        ? "Good morning"
        : hour < 18
            ? "Good afternoon"
            : "Good evening";

    if (name == null || name.isEmpty) {
      return "$timeOfDay! 💪";
    }

    final firstName = name.trim().split(' ').first;

    return "$timeOfDay, $firstName! 💪";
  }

  Future<void> _createFirstWorkout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final program = await runCreateProgramFlow(context);

    if (program == null) return;

    ref.invalidate(activeProgramProvider);

    if (!context.mounted) return;

    ref.read(navigationProvider.notifier).goTo(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final activeProgram = ref.watch(activeProgramProvider);
    final user = ref.watch(authStateProvider).value;
    final stats = dashboard.stats;
    final workouts = dashboard.workouts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Muscle-up"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Settings",
            onPressed: () {
              ref.read(navigationProvider.notifier).goTo(4);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              _greeting(user?.displayName),
              style: Theme.of(context).textTheme.headlineLarge,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              "Ready for today's workout?",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: AppSpacing.xl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S WORKOUT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      activeProgram?.name ?? "Let's set up your first workout",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    if (activeProgram == null)
                      PrimaryButton(
                        text: "CREATE WORKOUT",
                        icon: Icons.add,
                        onPressed: () => _createFirstWorkout(context, ref),
                      )
                    else ...[
                      PrimaryButton(
                        text: "START WORKOUT",
                        icon: Icons.play_arrow,
                        onPressed: () {
                          ref.read(navigationProvider.notifier).goTo(1);
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      OutlinedButton.icon(
                        onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ProgramListScreen(),
    ),
  );

  ref.invalidate(activeProgramProvider);
},
                        icon: const Icon(Icons.edit),
                        label: const Text("Manage Programs"),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              "Your Statistics",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                StatTile(
                  icon: Icons.fitness_center,
                  value: stats.totalWorkouts.toString(),
                  label: "Workouts",
                ),

                const SizedBox(width: AppSpacing.sm),

                StatTile(
                  icon: Icons.timer_outlined,
                  value: formatTrainingTime(
                    stats.totalTrainingTime,
                  ),
                  label: "Training",
                ),

                const SizedBox(width: AppSpacing.sm),

                StatTile(
                  icon: Icons.local_fire_department,
                  value: stats.currentStreak.toString(),
                  label: "Streak",
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              "Latest Workout",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: AppSpacing.md),

            if (workouts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    "No workouts yet.",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.history),
                  ),
                  title: Text(workouts.first.workoutName),
                  subtitle: Text(
                    "${workouts.first.completedAt.day}/${workouts.first.completedAt.month}/${workouts.first.completedAt.year}",
                  ),
                  trailing: Text(
                    formatTrainingTime(
                      Duration(
                        seconds: workouts.first.durationSeconds,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.fabClearance),
          ],
        ),
      ),
    );
  }
}