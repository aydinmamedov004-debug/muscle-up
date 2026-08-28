import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../../data/exercise_catalog.dart';
import '../../../models/storage/stored_exercise_template.dart';
import '../../../models/storage/stored_workout_program.dart';
import '../../../models/storage/user_profile.dart';

/// Thrown when generation fails or the model's output can't be turned into
/// at least one usable program. The message is safe to show the user.
class ProgramGenerationException implements Exception {
  final String message;

  ProgramGenerationException(this.message);

  @override
  String toString() => message;
}

/// Generates a starter set of workout programs from the user's onboarding
/// profile via Gemini. Every exercise name is validated against the real
/// catalog after generation — the model is instructed to only use names
/// from that list, but nothing downstream (photos, muscle group lookups)
/// should ever see a name that doesn't actually exist, so anything else is
/// dropped rather than trusted.
class ProgramGenerator {
  Future<List<StoredWorkoutProgram>> generate(UserProfile profile) async {
    final catalogNames = allExercises.map((exercise) => exercise.name).toList();
    final validNames = catalogNames.toSet();

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _schema,
      ),
    );

    final GenerateContentResponse response;
    try {
      response = await model.generateContent([
        Content.text(_buildPrompt(profile, catalogNames)),
      ]);
    } catch (_) {
      throw ProgramGenerationException(
        "Couldn't reach the coach to generate a program. Check your "
        "connection and try again.",
      );
    }

    final raw = response.text;
    if (raw == null || raw.isEmpty) {
      throw ProgramGenerationException(
        "Couldn't generate a program right now. Try again in a moment.",
      );
    }

    return parsePrograms(raw, validNames);
  }

  /// Parses and validates the model's raw JSON output into real programs,
  /// silently dropping anything that doesn't check out (wrong shape, an
  /// exercise name not actually in the catalog, etc.) rather than trusting
  /// it — pulled out of [generate] so this logic is testable without a
  /// network call. Throws [ProgramGenerationException] if nothing usable
  /// survives validation.
  @visibleForTesting
  static List<StoredWorkoutProgram> parsePrograms(
    String raw,
    Set<String> validNames,
  ) {
    final List<dynamic> decoded;
    try {
      decoded = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      throw ProgramGenerationException(
        "Couldn't generate a program right now. Try again in a moment.",
      );
    }

    final programs = <StoredWorkoutProgram>[];

    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;

      final name = entry['name'];
      final exercisesJson = entry['exercises'];
      if (name is! String || name.trim().isEmpty) continue;
      if (exercisesJson is! List) continue;

      final exercises = <StoredExerciseTemplate>[];
      for (final exerciseJson in exercisesJson) {
        if (exerciseJson is! Map<String, dynamic>) continue;

        final exerciseName = exerciseJson['name'];
        if (exerciseName is! String || !validNames.contains(exerciseName)) {
          continue;
        }

        exercises.add(
          StoredExerciseTemplate(
            name: exerciseName,
            targetSets: _clampInt(exerciseJson['targetSets'], 2, 6, 3),
            minReps: _clampInt(exerciseJson['minReps'], 3, 20, 8),
            maxReps: _clampInt(exerciseJson['maxReps'], 3, 20, 12),
            restSeconds: _clampInt(exerciseJson['restSeconds'], 30, 180, 90),
          ),
        );
      }

      if (exercises.isEmpty) continue;

      programs.add(
        StoredWorkoutProgram(name: name.trim(), exercises: exercises),
      );
    }

    if (programs.isEmpty) {
      throw ProgramGenerationException(
        "Couldn't generate a valid program right now. Try again, or "
        "create one yourself.",
      );
    }

    return programs;
  }

  static int _clampInt(Object? value, int min, int max, int fallback) {
    final n = value is num ? value.round() : fallback;
    return n.clamp(min, max);
  }

  String _buildPrompt(UserProfile profile, List<String> catalogNames) {
    final split =
        profile.weeklyGoal >= 4 || profile.experienceLevel != 'beginner'
        ? "Split it into 2-3 programs (e.g. a Push/Pull/Legs or Upper/Lower "
              "split) so they rotate through them across the week."
        : "Keep it to a single full-body program they can repeat each "
              "session, since they're just starting out.";

    return '''
Design a starter workout program for a gym app user with this profile:
- Experience level: ${profile.experienceLevel}
- Weekly workout goal: ${profile.weeklyGoal} sessions/week
- Age: ${profile.ageYears}

$split

Rules:
- Every exercise name must be copied EXACTLY (character-for-character) from
  this list — do not invent, rename, or slightly alter any name:
  ${catalogNames.join(', ')}
- 4-6 exercises per program, covering a sensible mix of muscle groups for
  that program's focus.
- targetSets 3-4, minReps/maxReps a sensible rep range for the experience
  level, restSeconds 60-120 for compound lifts and 45-90 for isolation
  moves.
- Program names should be short and clear (e.g. "Full Body", "Push Day").
''';
  }

  static final Schema _schema = Schema.array(
    minItems: 1,
    maxItems: 3,
    items: Schema.object(
      properties: {
        'name': Schema.string(),
        'exercises': Schema.array(
          minItems: 3,
          maxItems: 8,
          items: Schema.object(
            properties: {
              'name': Schema.string(),
              'targetSets': Schema.integer(),
              'minReps': Schema.integer(),
              'maxReps': Schema.integer(),
              'restSeconds': Schema.integer(),
            },
          ),
        ),
      },
    ),
  );
}
