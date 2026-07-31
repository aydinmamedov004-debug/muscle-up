enum MuscleGroup {
  chest,
  shoulders,
  back,
  arms,
  legs,
  core;

  String get label {
    switch (this) {
      case MuscleGroup.chest:
        return "Chest";
      case MuscleGroup.shoulders:
        return "Shoulders";
      case MuscleGroup.back:
        return "Back";
      case MuscleGroup.arms:
        return "Arms";
      case MuscleGroup.legs:
        return "Legs";
      case MuscleGroup.core:
        return "Core";
    }
  }

  /// A simple body diagram highlighting the region this group works.
  String get diagramAsset => "assets/muscle_groups/$name.png";
}
