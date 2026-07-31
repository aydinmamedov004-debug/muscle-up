class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Extra bottom space scrollable tab content needs to clear the
  /// AppShell's floating Coach button, so it never sits on top of the
  /// last item (e.g. "Add Set", "Latest Workout").
  static const double fabClearance = 96;
}