import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/primary_button.dart';
import 'providers/auth_provider.dart';

enum _AuthMode { signUp, logIn }

const _privacyPolicyUrl = 'https://muscleup-aydinmamedov.web.app/privacy-policy.html';

/// The app's entry point when signed out. Leads with account creation (a
/// new install is, by definition, a new user — not someone "coming back"),
/// with a one-tap toggle to log in instead, and a lower-emphasis guest path
/// for anyone not ready to commit yet.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();
  final privacyPolicyTap = TapGestureRecognizer();

  _AuthMode mode = _AuthMode.signUp;
  bool obscurePassword = true;
  bool isLoading = false;
  bool isGuestLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    privacyPolicyTap.onTap = () {
      launchUrl(
        Uri.parse(_privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
    };
    // The visibility toggle and "6+ characters" hint only make sense while
    // the user is actually in the password field — surface them on focus
    // rather than cluttering the form before it's relevant.
    passwordFocus.addListener(_onPasswordFocusChange);
  }

  void _onPasswordFocusChange() => setState(() {});

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordFocus.removeListener(_onPasswordFocusChange);
    passwordFocus.dispose();
    privacyPolicyTap.dispose();
    super.dispose();
  }

  void _switchMode(_AuthMode next) {
    if (mode == next) return;
    setState(() {
      mode = next;
      errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (mode == _AuthMode.signUp && name.isEmpty) {
      setState(() => errorMessage = "Enter your name.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final controller = ref.read(authControllerProvider);
      if (mode == _AuthMode.signUp) {
        await controller.signUp(name: name, email: email, password: password);
      } else {
        await controller.signIn(email: email, password: password);
      }
    } on AuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      isGuestLoading = true;
      errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider).signInAsGuest();
    } on AuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      if (mounted) setState(() => isGuestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = mode == _AuthMode.signUp;
    final busy = isLoading || isGuestLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Muscle-up",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Track every rep. Build the streak.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _ModeToggle(mode: mode, onChanged: busy ? null : _switchMode),

                  const SizedBox(height: AppSpacing.lg),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: isSignUp
                          ? Column(
                              key: const ValueKey("name-field"),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: nameController,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: "Name",
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            )
                          : const SizedBox(
                              key: ValueKey("no-name-field"),
                              width: double.infinity,
                            ),
                    ),
                  ),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => passwordFocus.requestFocus(),
                    decoration: const InputDecoration(labelText: "Email"),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: "Password",
                      helperText: (passwordFocus.hasFocus && isSignUp)
                          ? "6+ characters"
                          : null,
                      suffixIcon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: passwordFocus.hasFocus
                            ? IconButton(
                                key: const ValueKey("password-visibility"),
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword,
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey("password-visibility-hidden"),
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

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: PrimaryButton(
                      key: ValueKey(mode),
                      text: isSignUp ? "CREATE ACCOUNT" : "LOG IN",
                      isLoading: isLoading,
                      onPressed: busy ? null : _submit,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  OutlinedButton(
                    onPressed: busy ? null : _continueAsGuest,
                    child: isGuestLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text("Continue as Guest"),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Guest progress stays on this device only — "
                    "create an account anytime to keep it safe.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                      children: [
                        const TextSpan(text: "By continuing, you agree to our "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                            color: AppTheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: privacyPolicyTap,
                        ),
                        const TextSpan(text: "."),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _AuthMode mode;
  final ValueChanged<_AuthMode>? onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isSignUp = mode == _AuthMode.signUp;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: AppRadius.pill,
      ),
      child: Stack(
        children: [
          // Sliding highlight, painted behind the labels — animates between
          // the two halves instead of the old instant color-swap.
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: isSignUp
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: _ModeToggleSegment(
                  label: "Create Account",
                  selected: isSignUp,
                  onTap: onChanged == null
                      ? null
                      : () => onChanged!(_AuthMode.signUp),
                ),
              ),
              Expanded(
                child: _ModeToggleSegment(
                  label: "Log In",
                  selected: !isSignUp,
                  onTap: onChanged == null
                      ? null
                      : () => onChanged!(_AuthMode.logIn),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeToggleSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _ModeToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pill,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: selected ? Colors.white : AppTheme.secondaryText,
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
