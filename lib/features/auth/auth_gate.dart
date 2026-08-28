import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_shell.dart';
import '../../data/local/profile_provider.dart';
import '../onboarding/onboarding_screen.dart';
import 'auth_screen.dart';
import 'providers/auth_provider.dart';

/// Shows the sign-in flow when signed out, the onboarding questionnaire when
/// signed in but without a saved profile yet, the app once both are done,
/// and a loading spinner while Firebase resolves the initial auth state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const AuthScreen();

        final profile = ref.watch(profileProvider);
        return profile == null ? const OnboardingScreen() : const AppShell();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text("Something went wrong: $error")),
      ),
    );
  }
}
