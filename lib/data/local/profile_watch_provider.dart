import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_service.dart';

/// Emits whenever the user profile box changes, so dependent providers
/// can stay in sync without every write site remembering to invalidate them.
final profileChangesProvider = StreamProvider<void>((ref) {
  return HiveService.userProfileBoxRef.watch().map((_) {});
});
