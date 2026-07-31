import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/hive_service.dart';
import '../../../data/local/program_repository.dart';
import '../../../models/storage/stored_workout_program.dart';

const _activeProgramKeyField = 'activeProgramKey';

class ActiveProgramNotifier
    extends Notifier<StoredWorkoutProgram?> {
  @override
  StoredWorkoutProgram? build() {
    final programs = ProgramRepository().getPrograms();

    if (programs.isEmpty) return null;

    final savedKey =
        HiveService.appSettingsBoxRef.get(_activeProgramKeyField);

    for (final program in programs) {
      if (program.key == savedKey) return program;
    }

    return programs.first;
  }

  void selectProgram(
    StoredWorkoutProgram program,
  ) {
    state = program;
    HiveService.appSettingsBoxRef.put(_activeProgramKeyField, program.key);
  }
}

final activeProgramProvider =
    NotifierProvider<
        ActiveProgramNotifier,
        StoredWorkoutProgram?>(
  ActiveProgramNotifier.new,
);
