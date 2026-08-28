import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/storage/custom_exercise.dart';
import '../../models/storage/exercise_history.dart';
import '../../models/storage/set_history.dart';
import '../../models/storage/stored_exercise_template.dart';
import '../../models/storage/stored_workout_program.dart';
import '../../models/storage/user_profile.dart';
import '../../models/storage/workout_history.dart';
import 'hive_service.dart';

const _backupVersion = 1;
const _activeProgramKeyField = 'activeProgramKey';

/// Thrown when a file the user picked for restore isn't a valid Muscle Up
/// backup. The message is safe to show directly to the user.
class BackupImportException implements Exception {
  final String message;

  BackupImportException(this.message);

  @override
  String toString() => message;
}

/// Exports all local app data (workout history, programs, custom exercises,
/// profile) to a single JSON file and restores it back, since the app has no
/// cloud sync — this is the only thing standing between a user and losing
/// everything on reinstall or a new device.
class BackupService {
  /// Builds the backup JSON string from current local data. Split out from
  /// [exportBackup] so the payload logic can be unit-tested without the
  /// platform channels `share_plus`/`path_provider` need at runtime.
  String buildBackupJson() {
    final payload = _buildPayload();
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> exportBackup() async {
    final json = buildBackupJson();

    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final file = File('${dir.path}/muscle_up_backup_$stamp.json');
    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Muscle Up backup',
      ),
    );
  }

  /// Validates [jsonString] and replaces all local app data with its
  /// contents. Throws [BackupImportException] if the file isn't a valid
  /// backup — callers should show `message` to the user and stop, without
  /// touching any existing data (validation happens before anything is
  /// cleared).
  Future<void> restoreFromJson(String jsonString) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw BackupImportException("That file isn't a valid backup.");
    }

    if (data['backupVersion'] is! int) {
      throw BackupImportException("That file isn't a Muscle Up backup.");
    }

    final profileJson = data['userProfile'] as Map<String, dynamic>?;
    final programsJson = (data['workoutPrograms'] as List?) ?? const [];
    final exercisesJson = (data['customExercises'] as List?) ?? const [];
    final historyJson = (data['workoutHistory'] as List?) ?? const [];
    final activeProgramName = data['activeProgramName'] as String?;

    try {
      await HiveService.userProfileBoxRef.clear();
      if (profileJson != null) {
        await HiveService.userProfileBoxRef.add(_profileFromJson(profileJson));
      }

      await HiveService.workoutProgramsBoxRef.clear();
      StoredWorkoutProgram? matchedActive;
      for (final raw in programsJson) {
        final program = _programFromJson(raw as Map<String, dynamic>);
        await HiveService.workoutProgramsBoxRef.add(program);
        if (activeProgramName != null && program.name == activeProgramName) {
          matchedActive = program;
        }
      }
      if (matchedActive != null) {
        await HiveService.appSettingsBoxRef.put(
          _activeProgramKeyField,
          matchedActive.key,
        );
      } else {
        await HiveService.appSettingsBoxRef.delete(_activeProgramKeyField);
      }

      await HiveService.customExercisesBoxRef.clear();
      for (final raw in exercisesJson) {
        await HiveService.customExercisesBoxRef.add(
          _customExerciseFromJson(raw as Map<String, dynamic>),
        );
      }

      await HiveService.historyBox.clear();
      for (final raw in historyJson) {
        await HiveService.historyBox.add(
          _workoutFromJson(raw as Map<String, dynamic>),
        );
      }
    } catch (_) {
      throw BackupImportException("That backup file looks corrupted.");
    }
  }

  Map<String, dynamic> _buildPayload() {
    final programs = HiveService.workoutProgramsBoxRef;
    final activeKey = HiveService.appSettingsBoxRef.get(_activeProgramKeyField);
    String? activeProgramName;
    if (activeKey != null && programs.containsKey(activeKey)) {
      activeProgramName = programs.get(activeKey)?.name;
    }

    return {
      'backupVersion': _backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'userProfile': _profileToJson(
        HiveService.userProfileBoxRef.isEmpty
            ? null
            : HiveService.userProfileBoxRef.getAt(0),
      ),
      'workoutPrograms': programs.values.map(_programToJson).toList(),
      'customExercises': HiveService.customExercisesBoxRef.values
          .map(_customExerciseToJson)
          .toList(),
      'workoutHistory': HiveService.historyBox.values
          .map(_workoutToJson)
          .toList(),
      'activeProgramName': activeProgramName,
    };
  }

  // --- JSON mapping (kept flat and explicit rather than pulling in
  // json_serializable — these models are small and rarely change shape) ---

  Map<String, dynamic>? _profileToJson(UserProfile? p) {
    if (p == null) return null;
    return {
      'ageYears': p.ageYears,
      'weightKg': p.weightKg,
      'weightUnit': p.weightUnit,
      'heightCm': p.heightCm,
      'heightUnit': p.heightUnit,
      'experienceLevel': p.experienceLevel,
      'weeklyGoal': p.weeklyGoal,
    };
  }

  UserProfile _profileFromJson(Map<String, dynamic> j) => UserProfile(
    ageYears: j['ageYears'] as int,
    weightKg: (j['weightKg'] as num).toDouble(),
    weightUnit: j['weightUnit'] as String,
    heightCm: (j['heightCm'] as num).toDouble(),
    heightUnit: j['heightUnit'] as String,
    experienceLevel: j['experienceLevel'] as String,
    weeklyGoal: j['weeklyGoal'] as int,
  );

  Map<String, dynamic> _programToJson(StoredWorkoutProgram p) => {
    'name': p.name,
    'exercises': p.exercises.map(_templateToJson).toList(),
  };

  StoredWorkoutProgram _programFromJson(Map<String, dynamic> j) =>
      StoredWorkoutProgram(
        name: j['name'] as String,
        exercises: ((j['exercises'] as List?) ?? const [])
            .map((e) => _templateFromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> _templateToJson(StoredExerciseTemplate t) => {
    'name': t.name,
    'targetSets': t.targetSets,
    'minReps': t.minReps,
    'maxReps': t.maxReps,
    'restSeconds': t.restSeconds,
  };

  StoredExerciseTemplate _templateFromJson(Map<String, dynamic> j) =>
      StoredExerciseTemplate(
        name: j['name'] as String,
        targetSets: j['targetSets'] as int? ?? 3,
        minReps: j['minReps'] as int? ?? 8,
        maxReps: j['maxReps'] as int? ?? 12,
        restSeconds: j['restSeconds'] as int? ?? 90,
      );

  Map<String, dynamic> _customExerciseToJson(CustomExercise e) => {
    'name': e.name,
    'muscleGroupName': e.muscleGroupName,
  };

  CustomExercise _customExerciseFromJson(Map<String, dynamic> j) =>
      CustomExercise(
        name: j['name'] as String,
        muscleGroupName: j['muscleGroupName'] as String,
      );

  Map<String, dynamic> _workoutToJson(WorkoutHistory w) => {
    'workoutName': w.workoutName,
    'completedAt': w.completedAt.toIso8601String(),
    'durationSeconds': w.durationSeconds,
    'note': w.note,
    'exercises': w.exercises.map(_exerciseHistoryToJson).toList(),
  };

  WorkoutHistory _workoutFromJson(Map<String, dynamic> j) => WorkoutHistory(
    workoutName: j['workoutName'] as String,
    completedAt: DateTime.parse(j['completedAt'] as String),
    durationSeconds: j['durationSeconds'] as int,
    note: j['note'] as String?,
    exercises: ((j['exercises'] as List?) ?? const [])
        .map((e) => _exerciseHistoryFromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> _exerciseHistoryToJson(ExerciseHistory e) => {
    'name': e.name,
    'sets': e.sets.map(_setHistoryToJson).toList(),
  };

  ExerciseHistory _exerciseHistoryFromJson(Map<String, dynamic> j) =>
      ExerciseHistory(
        name: j['name'] as String,
        sets: ((j['sets'] as List?) ?? const [])
            .map((s) => _setHistoryFromJson(s as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> _setHistoryToJson(SetHistory s) => {
    'weight': s.weight,
    'reps': s.reps,
    'completed': s.completed,
  };

  SetHistory _setHistoryFromJson(Map<String, dynamic> j) => SetHistory(
    weight: (j['weight'] as num?)?.toDouble(),
    reps: j['reps'] as int?,
    completed: j['completed'] as bool? ?? false,
  );
}
