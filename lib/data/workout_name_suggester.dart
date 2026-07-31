import 'exercise_catalog.dart';
import 'muscle_group.dart';

/// Suggests a workout name from the muscle groups of the given exercises,
/// e.g. mostly squats/leg presses -> "Leg Day". Falls back to "Full Body"
/// when no single group dominates, and "Workout" when nothing is tagged.
String suggestWorkoutName(List<String> exerciseNames) {
  final counts = <MuscleGroup, int>{};

  for (final name in exerciseNames) {
    final group = muscleGroupOf(name);
    if (group == null) continue;

    counts[group] = (counts[group] ?? 0) + 1;
  }

  if (counts.isEmpty) return "Workout";

  final tagged = counts.values.fold(0, (sum, count) => sum + count);

  final dominant = counts.entries.reduce(
    (a, b) => a.value >= b.value ? a : b,
  );

  final isDominant = dominant.value / tagged > 0.5;

  if (!isDominant) return "Full Body";

  return "${dominant.key.label} Day";
}
