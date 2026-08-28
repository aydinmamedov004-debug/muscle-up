import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/primary_button.dart';
import 'providers/auth_provider.dart';

/// Converts a guest (anonymous) session into a real account, in place —
/// the Firebase UID doesn't change, so none of the guest's local data
/// (workouts, programs, profile) needs to move.
class UpgradeAccountScreen extends ConsumerStatefulWidget {
  const UpgradeAccountScreen({super.key});

  @override
  ConsumerState<UpgradeAccountScreen> createState() =>
      _UpgradeAccountScreenState();
}

class _UpgradeAccountScreenState extends ConsumerState<UpgradeAccountScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _upgrade() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty) {
      setState(() => errorMessage = "Enter your name.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider).upgradeGuestAccount(
        name: name,
        email: email,
        password: password,
      );

      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Your workouts, programs, and progress stay exactly as "
                  "they are — this just makes sure you never lose them.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.xl),

                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: "Name"),
                ),

                const SizedBox(height: AppSpacing.md),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: AppSpacing.md),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _upgrade(),
                  decoration: InputDecoration(
                    labelText: "Password",
                    helperText: "6+ characters",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => obscurePassword = !obscurePassword,
                      ),
                    ),
                  ),
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: AppTheme.primary),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                PrimaryButton(
                  text: "CREATE ACCOUNT",
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _upgrade,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
