class WorkoutSet {
  int number;
  double? weight;
  int? reps;
  bool completed;

  WorkoutSet({
    this.number = 1,
    this.weight,
    this.reps,
    this.completed = false,
  });
}