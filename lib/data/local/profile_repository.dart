import '../../models/storage/user_profile.dart';
import 'hive_service.dart';

class ProfileRepository {
  UserProfile? getProfile() {
    final box = HiveService.userProfileBoxRef;
    return box.isEmpty ? null : box.getAt(0);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = HiveService.userProfileBoxRef;
    if (box.isEmpty) {
      await box.add(profile);
    } else {
      await box.putAt(0, profile);
    }
  }
}
