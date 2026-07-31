import 'package:hive_ce/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 7)
class UserProfile extends HiveObject {
  @HiveField(0)
  int ageYears;

  @HiveField(1)
  double weightKg;

  @HiveField(2)
  String weightUnit;

  @HiveField(3)
  double heightCm;

  @HiveField(4)
  String heightUnit;

  @HiveField(5)
  String experienceLevel;

  @HiveField(6)
  int weeklyGoal;

  UserProfile({
    required this.ageYears,
    required this.weightKg,
    required this.weightUnit,
    required this.heightCm,
    required this.heightUnit,
    required this.experienceLevel,
    required this.weeklyGoal,
  });
}
