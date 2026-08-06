import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/profile_repository.dart';
import '../../models/storage/user_profile.dart';
import '../../shared/widgets/primary_button.dart';
import '../auth/providers/auth_provider.dart';

const double _kgPerLb = 0.45359237;
const double _cmPerInch = 2.54;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final heightFeetController = TextEditingController();
  final heightInchesController = TextEditingController();

  String weightUnit = 'kg';
  String heightUnit = 'cm';
  String experienceLevel = 'beginner';
  int weeklyGoal = 3;

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    heightFeetController.dispose();
    heightInchesController.dispose();
    super.dispose();
  }

  Future<void> _finishSetup() async {
    final age = int.tryParse(ageController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (age == null || age <= 0) {
      setState(() => errorMessage = "Enter a valid age.");
      return;
    }

    if (weight == null || weight <= 0) {
      setState(() => errorMessage = "Enter a valid weight.");
      return;
    }

    double? heightCm;

    if (heightUnit == 'cm') {
      final height = double.tryParse(heightController.text.trim());
      if (height == null || height <= 0) {
        setState(() => errorMessage = "Enter a valid height.");
        return;
      }
      heightCm = height;
    } else {
      final feet = double.tryParse(heightFeetController.text.trim());
      final inches = double.tryParse(heightInchesController.text.trim());
      if (feet == null || feet < 0 || inches == null || inches < 0) {
        setState(() => errorMessage = "Enter a valid height.");
        return;
      }
      heightCm = (feet * 12 + inches) * _cmPerInch;
    }

    final weightKg = weightUnit == 'kg' ? weight : weight * _kgPerLb;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await ProfileRepository().saveProfile(
      UserProfile(
        ageYears: age,
        weightKg: weightKg,
        weightUnit: weightUnit,
        heightCm: heightCm,
        heightUnit: heightUnit,
        experienceLevel: experienceLevel,
        weeklyGoal: weeklyGoal,
      ),
    );

    // No navigation needed here — AuthGate watches the profile and swaps
    // this screen for AppShell as soon as the save above lands.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Tell us about yourself",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "This helps your coach personalize advice for you.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.xl),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age"),
                ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: "Weight"),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SegmentedButton<String>(
                      style: SegmentedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      segments: const [
                        ButtonSegment(value: 'kg', label: Text("kg")),
                        ButtonSegment(value: 'lb', label: Text("lb")),
                      ],
                      selected: {weightUnit},
                      onSelectionChanged: (selection) {
                        setState(() => weightUnit = selection.first);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: heightUnit == 'cm'
                          ? TextField(
                              controller: heightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: "Height (cm)",
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: heightFeetController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Feet",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: TextField(
                                    controller: heightInchesController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Inches",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SegmentedButton<String>(
                      style: SegmentedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      segments: const [
                        ButtonSegment(value: 'cm', label: Text("cm")),
                        ButtonSegment(value: 'ftIn', label: Text("ft/in")),
                      ],
                      selected: {heightUnit},
                      onSelectionChanged: (selection) {
                        setState(() => heightUnit = selection.first);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  "Experience level",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'beginner', label: Text("Beginner")),
                    ButtonSegment(
                      value: 'intermediate',
                      label: Text("Intermediate"),
                    ),
                    ButtonSegment(value: 'advanced', label: Text("Advanced")),
                  ],
                  selected: {experienceLevel},
                  onSelectionChanged: (selection) {
                    setState(() => experienceLevel = selection.first);
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  "Weekly workout goal",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: weeklyGoal > 1
                          ? () => setState(() => weeklyGoal--)
                          : null,
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        "$weeklyGoal / week",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: weeklyGoal < 7
                          ? () => setState(() => weeklyGoal++)
                          : null,
                    ),
                  ],
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
                  text: "FINISH SETUP",
                  isLoading: isLoading,
                  onPressed: _finishSetup,
                ),

                const SizedBox(height: AppSpacing.sm),

                TextButton(
                  onPressed: () => ref.read(authControllerProvider).signOut(),
                  child: const Text("Sign out"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
