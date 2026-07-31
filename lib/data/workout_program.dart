import '../models/exercise.dart';
import '../models/workout_day.dart';

final List<WorkoutDay> workoutProgram = [
  WorkoutDay(
    name: "Push",
    exercises: [
      Exercise(name: "Bench Press"),
      Exercise(name: "Incline Dumbbell Press"),
      Exercise(name: "Machine Chest Fly"),
      Exercise(name: "Overhead Press"),
      Exercise(name: "Lateral Raise"),
      Exercise(name: "Cable Triceps Pushdown"),
      Exercise(name: "Overhead Cable Extension"),
    ],
  ),

  WorkoutDay(
    name: "Pull",
    exercises: [
      Exercise(name: "Pull-ups"),
      Exercise(name: "Chest Supported Row"),
      Exercise(name: "Lat Pulldown"),
      Exercise(name: "Face Pull"),
      Exercise(name: "Incline Dumbbell Curl"),
      Exercise(name: "Hammer Curl"),
      Exercise(name: "Reverse Curl"),
    ],
  ),

  WorkoutDay(
    name: "Legs",
    exercises: [
      Exercise(name: "Squat"),
      Exercise(name: "Romanian Deadlift"),
      Exercise(name: "Leg Press"),
      Exercise(name: "Leg Extension"),
      Exercise(name: "Leg Curl"),
      Exercise(name: "Standing Calf Raise"),
    ],
  ),

  WorkoutDay(
    name: "Upper",
    exercises: [
      Exercise(name: "Incline Dumbbell Press"),
      Exercise(name: "Pull-up"),
      Exercise(name: "Chest Supported Row"),
      Exercise(name: "Lateral Raise"),
      Exercise(name: "Cable Triceps Pushdown"),
      Exercise(name: "Incline Dumbbell Curl"),
    ],
  ),

  WorkoutDay(
    name: "Lower",
    exercises: [
      Exercise(name: "Deadlift"),
      Exercise(name: "Hack Squat"),
      Exercise(name: "Leg Curl"),
      Exercise(name: "Leg Extension"),
      Exercise(name: "Standing Calf Raise"),
      Exercise(name: "Wrist Curl"),
      Exercise(name: "Reverse Wrist Curl"),
    ],
  ),
];