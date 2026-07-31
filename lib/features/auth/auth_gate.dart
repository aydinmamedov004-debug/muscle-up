import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_shell.dart';
import 'providers/auth_provider.dart';
import 'sign_in_screen.dart';

/// Shows the sign-in flow when signed out, the app when signed in, and a
/// loading spinner while Firebase resolves the initial auth state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        return user == null ? const SignInScreen() : const AppShell();
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
