import '../../models/storage/stored_workout_program.dart';
import 'hive_service.dart';

class ProgramRepository {
  List<StoredWorkoutProgram> getPrograms() {
    return HiveService.workoutProgramsBoxRef.values.toList();
  }

  Future<void> addProgram(
    StoredWorkoutProgram program,
  ) async {
    await HiveService.workoutProgramsBoxRef.add(program);
  }

  Future<void> deleteProgram(
    StoredWorkoutProgram program,
  ) async {
    await program.delete();
  }

  Future<void> clearPrograms() async {
    await HiveService.workoutProgramsBoxRef.clear();
  }
}