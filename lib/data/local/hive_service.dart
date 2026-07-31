import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../models/storage/custom_exercise.dart';
import '../../models/storage/exercise_history.dart';
import '../../models/storage/set_history.dart';
import '../../models/storage/stored_exercise_template.dart';
import '../../models/storage/stored_workout_program.dart';
import '../../models/storage/user_profile.dart';
import '../../models/storage/workout_history.dart';

class HiveService {
  static const String workoutHistoryBox = "workout_history";
  static const String workoutProgramsBox = "workout_programs";
  static const String customExercisesBox = "custom_exercises";
  static const String userProfileBox = "user_profile";
  static const String appSettingsBox = "app_settings";

  static Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(SetHistoryAdapter());
    Hive.registerAdapter(ExerciseHistoryAdapter());
    Hive.registerAdapter(WorkoutHistoryAdapter());

    Hive.registerAdapter(StoredExerciseTemplateAdapter());
    Hive.registerAdapter(StoredWorkoutProgramAdapter());
    Hive.registerAdapter(CustomExerciseAdapter());
    Hive.registerAdapter(UserProfileAdapter());

    await Hive.openBox<WorkoutHistory>(workoutHistoryBox);
    await Hive.openBox<StoredWorkoutProgram>(workoutProgramsBox);
    await Hive.openBox<CustomExercise>(customExercisesBox);
    await Hive.openBox<UserProfile>(userProfileBox);
    await Hive.openBox(appSettingsBox);
  }

  static Box<WorkoutHistory> get historyBox =>
      Hive.box<WorkoutHistory>(workoutHistoryBox);

  static Box<StoredWorkoutProgram> get workoutProgramsBoxRef =>
      Hive.box<StoredWorkoutProgram>(workoutProgramsBox);

  static Box<CustomExercise> get customExercisesBoxRef =>
      Hive.box<CustomExercise>(customExercisesBox);

  static Box<UserProfile> get userProfileBoxRef =>
      Hive.box<UserProfile>(userProfileBox);

  static Box get appSettingsBoxRef => Hive.box(appSettingsBox);
}
