import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/profile_provider.dart';
import '../../data/local/program_repository.dart';
import '../../models/storage/stored_workout_program.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import 'providers/program_generator.dart';

/// Generates a starter program (or small split) from the user's onboarding
/// profile, shows it for review, and only saves it once they confirm — the
/// model's output is a proposal, not something silently written to their
/// programs list.
class GenerateProgramScreen extends ConsumerStatefulWidget {
  const GenerateProgramScreen({super.key});

  @override
  ConsumerState<GenerateProgramScreen> createState() =>
      _GenerateProgramScreenState();
}

class _GenerateProgramScreenState
    extends ConsumerState<GenerateProgramScreen> {
  final generator = ProgramGenerator();

  List<StoredWorkoutProgram>? generated;
  String? errorMessage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      generated = null;
      errorMessage = null;
    });

    final profile = ref.read(profileProvider);
    if (profile == null) {
      setState(
        () => errorMessage = "Finish setting up your profile first.",
      );
      return;
    }

    try {
      final result = await generator.generate(profile);
      if (!mounted) return;
      setState(() => generated = result);
    } on ProgramGenerationException catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => errorMessage =
            "Couldn't generate a program right now. Try again.",
      );
    }
  }

  Future<void> _useThese() async {
    final programs = generated;
    if (programs == null || isSaving) return;

    setState(() => isSaving = true);

    final repository = ProgramRepository();
    for (final program in programs) {
      await repository.addProgram(program);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Starter Program")),
      body: SafeArea(
        child: errorMessage != null
            ? _ErrorView(message: errorMessage!, onRetry: _generate)
            : generated == null
            ? const _LoadingView()
            : _PreviewView(
                programs: generated!,
                isSaving: isSaving,
                onUseThese: _useThese,
                onRegenerate: _generate,
              ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.lg),
            Text(
              "Building a program from your profile…",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.secondaryText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(text: "TRY AGAIN", onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  final List<StoredWorkoutProgram> programs;
  final bool isSaving;
  final VoidCallback onUseThese;
  final VoidCallback onRegenerate;

  const _PreviewView({
    required this.programs,
    required this.isSaving,
    required this.onUseThese,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                programs.length == 1
                    ? "Here's your starter program."
                    : "Here's your starter split — "
                          "${programs.length} programs to rotate through.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              for (final program in programs) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final exercise in program.exercises)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(exercise.name)),
                              Text(
                                "${exercise.targetSets} × "
                                "${exercise.minReps}-${exercise.maxReps}",
                                style: const TextStyle(
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  text: "USE THESE PROGRAMS",
                  isLoading: isSaving,
                  onPressed: isSaving ? null : onUseThese,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: isSaving ? null : onRegenerate,
                  child: const Text("Regenerate"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
