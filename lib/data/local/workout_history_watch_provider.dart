import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_service.dart';

/// Emits whenever the workout history box changes, so dependent providers
/// can stay in sync without every write site remembering to invalidate them.
final workoutHistoryChangesProvider = StreamProvider<void>((ref) {
  return HiveService.historyBox.watch().map((_) {});
});
