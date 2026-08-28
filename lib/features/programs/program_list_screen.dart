import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/local/program_repository.dart';
import '../../models/storage/stored_workout_program.dart';
import '../../shared/widgets/empty_state.dart';
import 'create_program_flow.dart';
import 'edit_program_screen.dart';
import 'generate_program_screen.dart';
import 'providers/active_program_provider.dart';
import 'widgets/program_card.dart';

class ProgramListScreen extends ConsumerStatefulWidget {
  const ProgramListScreen({super.key});

  @override
  ConsumerState<ProgramListScreen> createState() =>
      _ProgramListScreenState();
}

class _ProgramListScreenState
    extends ConsumerState<ProgramListScreen> {
  final repository = ProgramRepository();

  Future<void> _openGenerator() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const GenerateProgramScreen()),
    );

    if (created == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<StoredWorkoutProgram> programs =
        repository.getPrograms();
    final activeProgram = ref.watch(activeProgramProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Programs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: "Generate with AI",
            onPressed: _openGenerator,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final program = await runCreateProgramFlow(context);

          if (program == null) return;

          setState(() {});
        },
        child: const Icon(Icons.add),
      ),

      body: programs.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmptyState(
                  icon: Icons.auto_awesome,
                  title: "No Programs Yet",
                  subtitle:
                      "Let your coach build a starter program from your "
                      "profile, or create one yourself.",
                  buttonText: "Generate with AI",
                  onPressed: _openGenerator,
                ),
                TextButton(
                  onPressed: () async {
                    final program = await runCreateProgramFlow(context);
                    if (program == null) return;
                    setState(() {});
                  },
                  child: const Text("Create manually"),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: programs.length,
              itemBuilder: (_, index) {
                final program = programs[index];
                final isActive = activeProgram?.key == program.key;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProgramCard(
                    program: program,
                    isActive: isActive,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProgramScreen(
                            program: program,
                          ),
                        ),
                      );

                      setState(() {});
                    },
                    onSetActive: () {
                      ref
                          .read(activeProgramProvider.notifier)
                          .selectProgram(program);
                    },
                    onDelete: () async {
                      await repository.deleteProgram(
                        program,
                      );

                      if (isActive) {
                        ref.invalidate(activeProgramProvider);
                      }

                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}
