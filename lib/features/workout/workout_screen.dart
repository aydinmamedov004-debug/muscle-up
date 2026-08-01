import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/workout_session.dart';
import '../../shared/navigation/slide_page_route.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_button.dart';
import '../programs/create_program_flow.dart';
import '../programs/providers/active_program_provider.dart';
import '../streak_celebration/streak_celebration_screen.dart';
import '../workout/providers/workout_provider.dart';
import '../workout_summary/workout_summary_screen.dart';
import 'widgets/exercise_card.dart';
import '../../data/local/profile_provider.dart';
import '../../data/local/workout_repository.dart';
import '../../data/mappers/workout_mapper.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  final WorkoutRepository repository = WorkoutRepository();
  late Timer timer;
  bool isFinishing = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final session = ref.read(workoutSessionProvider);
      if (session.hasStarted && !session.hasFinished) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> _finishWorkout({
    required WorkoutSession session,
    required int completedSets,
    required int totalSets,
  }) async {
    // Guards against the finish save firing twice from a fast double-tap,
    // which would otherwise log a second, empty workout once the session
    // resets underneath the still-visible button. session.hasFinished is
    // the permanent guard (set the instant finishWorkout() runs, for the
    // life of this session); isFinishing only covers the async window.
    if (isFinishing || session.hasFinished) return;

    setState(() => isFinishing = true);

    try {
      final weeklyGoal = ref.read(profileProvider)!.weeklyGoal;
      final beforeStats = repository.getDashboardStats(weeklyGoal: weeklyGoal);
      final beforeWeekDone = repository.getCurrentWeekCompletionFlags();

      ref.read(workoutSessionProvider.notifier).finishWorkout();

      await repository.saveWorkout(
        WorkoutMapper.fromSession(session),
      );

      if (!mounted) return;

      final afterStats = repository.getDashboardStats(weeklyGoal: weeklyGoal);
      final afterWeekDone = repository.getCurrentWeekCompletionFlags();

      final summary = WorkoutSummaryData(
        duration: formatDuration(session.duration),
        totalExercises: session.exercises.length,
        completedSets: completedSets,
        totalSets: totalSets,
      );

      if (afterStats.currentStreak != beforeStats.currentStreak) {
        final todayIndex = DateTime.now().weekday - 1;
        final animateToday =
            !beforeWeekDone[todayIndex] && afterWeekDone[todayIndex];

        await showStreakCelebration(
          context,
          fromStreak: beforeStats.currentStreak,
          toStreak: afterStats.currentStreak,
          weekDone: afterWeekDone,
          todayIndex: todayIndex,
          animateToday: animateToday,
          summary: summary,
        );
      } else {
        await Navigator.of(context).push(
          slidePageRoute<void>(
            (context) => WorkoutSummaryScreen(summary: summary),
          ),
        );
      }

      if (!mounted) return;

      ref.read(navigationProvider.notifier).goTo(0);
      ref.read(workoutSessionProvider.notifier).endSession();
    } finally {
      if (mounted) setState(() => isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(workoutSessionProvider);

    final completedExercises = session.exercises.where((exercise) {
      return exercise.sets.isNotEmpty &&
          exercise.sets.every((set) => set.completed);
    }).length;

    final completedSets = session.exercises
        .expand((exercise) => exercise.sets)
        .where((set) => set.completed)
        .length;

    final totalSets = session.exercises
        .expand((exercise) => exercise.sets)
        .length;

    final progress = session.exercises.isEmpty
        ? 0.0
        : completedExercises / session.exercises.length;

    if (session.exercises.isEmpty) {
      final activeProgram = ref.watch(activeProgramProvider);
      final hasProgram = activeProgram != null;

      return Scaffold(
        appBar: AppBar(
          title: Text(session.workout.name),
        ),
        body: SafeArea(
          child: EmptyState(
            icon: hasProgram ? Icons.play_arrow : Icons.fitness_center,
            title: hasProgram ? "Ready to Train?" : "No Program Selected",
            subtitle: hasProgram
                ? "Tap Start Workout to begin your ${activeProgram.name} session."
                : "Create a workout program to start training.",
            buttonText: hasProgram ? "Start Workout" : "Create Workout",
            onPressed: hasProgram
                ? () => ref
                    .read(workoutSessionProvider.notifier)
                    .beginSession()
                : () async {
                    final program = await runCreateProgramFlow(context);

                    if (program == null) return;

                    ref.invalidate(activeProgramProvider);
                  },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.workout.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              session.workout.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Workout Time",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatDuration(session.duration),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "$completedExercises / ${session.exercises.length} exercises completed",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(12),
            ),

            const SizedBox(height: 30),

            ...session.exercises.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ExerciseCard(
                  exerciseNumber: entry.key + 1,
                  exercise: entry.value,
                ),
              ),
            ),

            const Text(
              "Notes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              key: ValueKey(session),
              initialValue: session.note,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "How did this workout feel?",
              ),
              onChanged: (value) {
                session.note = value;
              },
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              text: "FINISH WORKOUT",
              isLoading: isFinishing,
              onPressed: session.hasFinished
                  ? null
                  : () => _finishWorkout(
                        session: session,
                        completedSets: completedSets,
                        totalSets: totalSets,
                      ),
            ),

            const SizedBox(height: AppSpacing.fabClearance),
          ],
        ),
      ),
    );
  }
}