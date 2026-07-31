import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/program_repository.dart';
import '../../models/storage/stored_workout_program.dart';
import '../../shared/widgets/empty_state.dart';
import 'create_program_flow.dart';
import 'providers/active_program_provider.dart';
import 'widgets/program_card.dart';
import 'edit_program_screen.dart';

class ProgramListScreen extends ConsumerStatefulWidget {
  const ProgramListScreen({super.key});

  @override
  ConsumerState<ProgramListScreen> createState() =>
      _ProgramListScreenState();
}

class _ProgramListScreenState
    extends ConsumerState<ProgramListScreen> {
  final repository = ProgramRepository();

  @override
  Widget build(BuildContext context) {
    final List<StoredWorkoutProgram> programs =
        repository.getPrograms();
    final activeProgram = ref.watch(activeProgramProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Programs"),
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
          ? const EmptyState(
              icon: Icons.fitness_center,
              title: "No Programs",
              subtitle:
                  "Create your first workout program.",
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
