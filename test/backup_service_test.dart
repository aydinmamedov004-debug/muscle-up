import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muscle_up/data/local/backup_service.dart';
import 'package:muscle_up/data/local/hive_service.dart';
import 'package:muscle_up/models/storage/custom_exercise.dart';
import 'package:muscle_up/models/storage/exercise_history.dart';
import 'package:muscle_up/models/storage/set_history.dart';
import 'package:muscle_up/models/storage/stored_exercise_template.dart';
import 'package:muscle_up/models/storage/stored_workout_program.dart';
import 'package:muscle_up/models/storage/user_profile.dart';
import 'package:muscle_up/models/storage/workout_history.dart';

const _activeProgramKeyField = 'activeProgramKey';

void main() {
  late Directory tempDir;
  final service = BackupService();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_backup_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(SetHistoryAdapter().typeId)) {
      Hive.registerAdapter(SetHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(ExerciseHistoryAdapter().typeId)) {
      Hive.registerAdapter(ExerciseHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutHistoryAdapter().typeId)) {
      Hive.registerAdapter(WorkoutHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(StoredExerciseTemplateAdapter().typeId)) {
      Hive.registerAdapter(StoredExerciseTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(StoredWorkoutProgramAdapter().typeId)) {
      Hive.registerAdapter(StoredWorkoutProgramAdapter());
    }
    if (!Hive.isAdapterRegistered(CustomExerciseAdapter().typeId)) {
      Hive.registerAdapter(CustomExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(UserProfileAdapter().typeId)) {
      Hive.registerAdapter(UserProfileAdapter());
    }

    await Hive.openBox<WorkoutHistory>(HiveService.workoutHistoryBox);
    await Hive.openBox<StoredWorkoutProgram>(HiveService.workoutProgramsBox);
    await Hive.openBox<CustomExercise>(HiveService.customExercisesBox);
    await Hive.openBox<UserProfile>(HiveService.userProfileBox);
    await Hive.openBox(HiveService.appSettingsBox);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('round-trips workouts, programs, exercises, and profile', () async {
    await HiveService.userProfileBoxRef.add(
      UserProfile(
        ageYears: 28,
        weightKg: 80,
        weightUnit: 'kg',
        heightCm: 180,
        heightUnit: 'cm',
        experienceLevel: 'intermediate',
        weeklyGoal: 4,
      ),
    );

    await HiveService.workoutProgramsBoxRef.add(
      StoredWorkoutProgram(
        name: 'Push Day',
        exercises: [
          StoredExerciseTemplate(name: 'Bench Press', targetSets: 4, minReps: 6, maxReps: 10, restSeconds: 120),
        ],
      ),
    );
    final activeProgram = await HiveService.workoutProgramsBoxRef.add(
      StoredWorkoutProgram(name: 'Pull Day', exercises: []),
    ).then((_) => HiveService.workoutProgramsBoxRef.values.last);
    await HiveService.appSettingsBoxRef.put(
      _activeProgramKeyField,
      activeProgram.key,
    );

    await HiveService.customExercisesBoxRef.add(
      CustomExercise(name: 'Cable Fly', muscleGroupName: 'chest'),
    );

    await HiveService.historyBox.add(
      WorkoutHistory(
        workoutName: 'Push Day',
        completedAt: DateTime.utc(2026, 1, 5),
        durationSeconds: 3600,
        note: 'Felt strong',
        exercises: [
          ExerciseHistory(
            name: 'Bench Press',
            sets: [
              SetHistory(weight: 100, reps: 8, completed: true),
              SetHistory(weight: null, reps: null, completed: false),
            ],
          ),
        ],
      ),
    );

    final json = service.buildBackupJson();

    // Wipe everything, simulating a fresh install/new device.
    await HiveService.userProfileBoxRef.clear();
    await HiveService.workoutProgramsBoxRef.clear();
    await HiveService.customExercisesBoxRef.clear();
    await HiveService.historyBox.clear();
    await HiveService.appSettingsBoxRef.clear();

    await service.restoreFromJson(json);

    final profile = HiveService.userProfileBoxRef.getAt(0)!;
    expect(profile.ageYears, 28);
    expect(profile.weightKg, 80);
    expect(profile.weeklyGoal, 4);

    final programs = HiveService.workoutProgramsBoxRef.values.toList();
    expect(programs.map((p) => p.name), ['Push Day', 'Pull Day']);
    expect(programs.first.exercises.single.name, 'Bench Press');
    expect(programs.first.exercises.single.targetSets, 4);

    // Active program is re-linked by name to its *new* key, not the old one.
    final restoredActiveKey = HiveService.appSettingsBoxRef.get(
      _activeProgramKeyField,
    );
    final restoredActive = HiveService.workoutProgramsBoxRef.get(
      restoredActiveKey,
    );
    expect(restoredActive?.name, 'Pull Day');

    final exercises = HiveService.customExercisesBoxRef.values.toList();
    expect(exercises.single.name, 'Cable Fly');
    expect(exercises.single.muscleGroupName, 'chest');

    final history = HiveService.historyBox.values.toList();
    expect(history.single.workoutName, 'Push Day');
    expect(history.single.note, 'Felt strong');
    expect(history.single.completedAt, DateTime.utc(2026, 1, 5));
    final sets = history.single.exercises.single.sets;
    expect(sets[0].weight, 100);
    expect(sets[0].reps, 8);
    expect(sets[0].completed, true);
    expect(sets[1].weight, null);
    expect(sets[1].completed, false);
  });

  test('rejects a file that is not a backup', () async {
    expect(
      () => service.restoreFromJson('{"hello": "world"}'),
      throwsA(isA<BackupImportException>()),
    );
  });

  test('rejects malformed JSON without touching existing data', () async {
    await HiveService.customExercisesBoxRef.add(
      CustomExercise(name: 'Kept Exercise', muscleGroupName: 'back'),
    );

    await expectLater(
      service.restoreFromJson('not json at all'),
      throwsA(isA<BackupImportException>()),
    );

    expect(HiveService.customExercisesBoxRef.values.single.name, 'Kept Exercise');
  });

  test('restoring with no active program clears the stored key', () async {
    await HiveService.appSettingsBoxRef.put(_activeProgramKeyField, 999);

    final json = service.buildBackupJson();
    await service.restoreFromJson(json);

    expect(
      HiveService.appSettingsBoxRef.get(_activeProgramKeyField),
      null,
    );
  });
}
