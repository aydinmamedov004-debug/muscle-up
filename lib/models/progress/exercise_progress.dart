class ExerciseProgress {
  final double? lastWeight;
  final int? lastReps;

  final double? personalBestWeight;
  final int? personalBestReps;

  const ExerciseProgress({
    this.lastWeight,
    this.lastReps,
    this.personalBestWeight,
    this.personalBestReps,
  });

  bool get hasHistory =>
      lastWeight != null || lastReps != null;
}