import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/storage/user_profile.dart';
import 'profile_repository.dart';
import 'profile_watch_provider.dart';

final profileProvider = Provider<UserProfile?>((ref) {
  ref.watch(profileChangesProvider);
  return ProfileRepository().getProfile();
});
