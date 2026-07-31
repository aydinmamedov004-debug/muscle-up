enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  legs,
  core;

  String get label {
    switch (this) {
      case MuscleGroup.chest:
        return "Chest";
      case MuscleGroup.back:
        return "Back";
      case MuscleGroup.shoulders:
        return "Shoulders";
      case MuscleGroup.biceps:
        return "Biceps";
      case MuscleGroup.triceps:
        return "Triceps";
      case MuscleGroup.forearms:
        return "Forearms";
      case MuscleGroup.legs:
        return "Legs";
      case MuscleGroup.core:
        return "Abs";
    }
  }

  /// A simple body diagram highlighting the region this group works.
  String get diagramAsset => "assets/muscle_groups/$name.png";
}
