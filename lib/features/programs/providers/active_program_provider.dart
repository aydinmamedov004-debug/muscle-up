import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/program_repository.dart';
import '../../../models/storage/stored_workout_program.dart';

class ActiveProgramNotifier
    extends Notifier<StoredWorkoutProgram?> {
  @override
  StoredWorkoutProgram? build() {
    final programs = ProgramRepository().getPrograms();

    if (programs.isEmpty) return null;

    return programs.first;
  }

  void selectProgram(
    StoredWorkoutProgram program,
  ) {
    state = program;
  }
}

final activeProgramProvider =
    NotifierProvider<
        ActiveProgramNotifier,
        StoredWorkoutProgram?>(
  ActiveProgramNotifier.new,
);