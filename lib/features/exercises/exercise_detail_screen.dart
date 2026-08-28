import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../data/exercise_catalog.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_header.dart';
import 'models/exercise_guidance.dart';
import 'providers/exercise_guidance_service.dart';

/// Shows an exercise's photo/muscle group plus AI-generated form guidance —
/// the "how do I actually do this" screen that tapping an exercise
/// previously did nothing to answer.
class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;

  const ExerciseDetailScreen({super.key, required this.exerciseName});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final service = ExerciseGuidanceService();

  ExerciseGuidance? guidance;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRegenerate = false}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await service.getGuidance(
        widget.exerciseName,
        forceRegenerate: forceRegenerate,
      );
      if (!mounted) return;
      setState(() {
        guidance = result;
        isLoading = false;
      });
    } on ExerciseGuidanceException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Couldn't generate form guidance right now. Try again.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final muscleGroup = muscleGroupOf(widget.exerciseName);
    final photo = exercisePhotoOf(widget.exerciseName);

    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            ClipRRect(
              borderRadius: AppRadius.large,
              child: photo != null
                  ? Image.asset(
                      photo,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: AppTheme.surface,
                      child: Center(
                        child: muscleGroup != null
                            ? Image.asset(
                                muscleGroup.diagramAsset,
                                width: 100,
                                height: 100,
                              )
                            : const Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: AppTheme.secondaryText,
                              ),
                      ),
                    ),
            ),

            if (muscleGroup != null) ...[
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTint,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    muscleGroup.label,
                    style: const TextStyle(
                      color: AppTheme.accentSoft,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: "AI Form Guidance"),

            if (isLoading)
              const _LoadingView()
            else if (errorMessage != null)
              _ErrorView(message: errorMessage!, onRetry: () => _load())
            else if (guidance != null)
              _GuidanceView(
                guidance: guidance!,
                onRegenerate: () => _load(forceRegenerate: true),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text("Asking your coach…"),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(text: "TRY AGAIN", onPressed: onRetry),
        ],
      ),
    );
  }
}

class _GuidanceView extends StatelessWidget {
  final ExerciseGuidance guidance;
  final VoidCallback onRegenerate;

  const _GuidanceView({required this.guidance, required this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Subhead("Setup"),
              const SizedBox(height: AppSpacing.xs),
              Text(guidance.setup),

              const SizedBox(height: AppSpacing.md),

              _Subhead("Execution"),
              const SizedBox(height: AppSpacing.xs),
              Text(guidance.execution),

              const SizedBox(height: AppSpacing.md),

              _Subhead("Common Mistakes"),
              const SizedBox(height: AppSpacing.xs),
              ...guidance.commonMistakes.map(
                (mistake) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("•  "),
                      Expanded(child: Text(mistake)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        AppCard(
          color: AppTheme.accentTint,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, color: AppTheme.accentSoft),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  guidance.safetyTip,
                  style: const TextStyle(color: AppTheme.accentSoft),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Center(
          child: TextButton(
            onPressed: onRegenerate,
            child: const Text("Regenerate"),
          ),
        ),

        Text(
          "AI-generated general guidance, not personalized coaching or "
          "medical advice.",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _Subhead extends StatelessWidget {
  final String text;

  const _Subhead(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryText,
        letterSpacing: 0.5,
        fontSize: 13,
      ),
    );
  }
}
