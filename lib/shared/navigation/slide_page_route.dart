import 'package:flutter/material.dart';

/// A right-to-left slide transition for full-screen takeovers pushed on top
/// of the tab content (streak celebration, workout summary) — shares the
/// easing/duration of the tab-slide in [AppShell] so navigation reads as one
/// continuous motion system instead of a mix of transition styles.
PageRouteBuilder<T> slidePageRoute<T>(
  WidgetBuilder builder, {
  Duration duration = const Duration(milliseconds: 320),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incoming = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      final outgoing = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOutCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(incoming),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.25, 0),
          ).animate(outgoing),
          child: child,
        ),
      );
    },
  );
}
