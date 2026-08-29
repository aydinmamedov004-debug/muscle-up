import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_provider.dart';

import '../features/coach/coach_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/workout/workout_screen.dart';
import '../services/streak_reminder_service.dart';
import '../shared/widgets/keep_alive_wrapper.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(navigationProvider),
    );

    // Fire-and-forget: requests notification permission (a no-op prompt
    // after the first decision) and schedules today's streak reminder if
    // one is warranted. Reminders default on, so this is the natural
    // first-run moment to ask, right after onboarding completes.
    unawaited(() async {
      final reminders = StreakReminderService();
      if (reminders.isEnabled) {
        await reminders.requestPermission();
      }
      await reminders.refreshForCurrentUser();
    }());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider);

    // Keeps the swipeable PageView in sync whenever something other than a
    // direct swipe changes the tab (bottom nav taps, the settings gear icon,
    // returning home after finishing a workout, etc.) with the same slide
    // motion a swipe would produce.
    ref.listen<int>(navigationProvider, (previous, next) {
      if (!_pageController.hasClients) return;
      if (_pageController.page?.round() == next) return;

      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    });

    final screens = const [
      KeepAliveWrapper(child: HomeScreen()),
      KeepAliveWrapper(child: WorkoutScreen()),
      KeepAliveWrapper(child: ProgressScreen()),
      KeepAliveWrapper(child: HistoryScreen()),
      KeepAliveWrapper(child: SettingsScreen()),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (ref.read(navigationProvider) != index) {
            ref.read(navigationProvider.notifier).goTo(index);
          }
        },
        children: screens,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CoachScreen(),
            ),
          );
        },
        child: const Icon(Icons.chat_bubble_outline),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          ref
              .read(navigationProvider.notifier)
              .goTo(index);
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: "Progress",
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: "History",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
