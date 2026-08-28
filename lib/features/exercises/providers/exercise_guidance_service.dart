import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../../data/local/hive_service.dart';
import '../models/exercise_guidance.dart';

/// Thrown when guidance generation fails. The message is safe to show.
class ExerciseGuidanceException implements Exception {
  final String message;

  ExerciseGuidanceException(this.message);

  @override
  String toString() => message;
}

/// Generates and caches AI form guidance for a single exercise. Guidance
/// for a given exercise name is generated once and reused from then on —
/// there's no reason to re-spend an AI call every time the same exercise
/// detail screen is opened, since the guidance for "Bench Press" doesn't
/// change between visits.
class ExerciseGuidanceService {
  Future<ExerciseGuidance> getGuidance(
    String exerciseName, {
    bool forceRegenerate = false,
  }) async {
    final box = HiveService.exerciseGuidanceCacheBoxRef;

    if (!forceRegenerate) {
      final cached = box.get(exerciseName);
      if (cached is Map) {
        try {
          return ExerciseGuidance.fromJson(Map<String, dynamic>.from(cached));
        } catch (_) {
          // Fall through and regenerate — a stale/corrupt cache entry
          // shouldn't permanently block this exercise's guidance.
        }
      }
    }

    final guidance = await _generate(exerciseName);
    await box.put(exerciseName, guidance.toJson());
    return guidance;
  }

  Future<ExerciseGuidance> _generate(String exerciseName) async {
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
        Content.text(_buildPrompt(exerciseName)),
      ]);
    } catch (_) {
      throw ExerciseGuidanceException(
        "Couldn't reach the coach for form guidance. Check your "
        "connection and try again.",
      );
    }

    final raw = response.text;
    if (raw == null || raw.isEmpty) {
      throw ExerciseGuidanceException(
        "Couldn't generate form guidance right now. Try again.",
      );
    }

    return parseGuidance(raw);
  }

  /// Parses and validates the model's raw JSON output, pulled out of
  /// [_generate] so this logic is testable without a network call. Throws
  /// [ExerciseGuidanceException] if any required field is missing/empty.
  @visibleForTesting
  static ExerciseGuidance parseGuidance(String raw) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final mistakes = (decoded['commonMistakes'] as List?)
          ?.map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();

      final setup = decoded['setup'] as String?;
      final execution = decoded['execution'] as String?;
      final safetyTip = decoded['safetyTip'] as String?;

      if (setup == null ||
          setup.trim().isEmpty ||
          execution == null ||
          execution.trim().isEmpty ||
          mistakes == null ||
          mistakes.isEmpty) {
        throw const FormatException('missing required field');
      }

      return ExerciseGuidance(
        setup: setup,
        execution: execution,
        commonMistakes: mistakes,
        safetyTip: (safetyTip == null || safetyTip.trim().isEmpty)
            ? "If something hurts (not just feels hard), stop and check "
                  "your form or ease off the weight."
            : safetyTip,
      );
    } catch (_) {
      throw ExerciseGuidanceException(
        "Couldn't generate form guidance right now. Try again.",
      );
    }
  }

  String _buildPrompt(String exerciseName) {
    return '''
Give concise, practical form guidance for the exercise "$exerciseName" in a
gym workout app. Write for someone doing this exercise who wants a quick
refresher, not a full tutorial.

Rules:
- setup: 1-2 sentences on starting position/setup.
- execution: 1-2 sentences on how to perform the rep (the movement itself).
- commonMistakes: 2-4 short bullet-point phrases (not full sentences) of
  mistakes people commonly make with this exercise.
- safetyTip: one short sentence. General technique/safety advice only —
  never diagnose pain or injury; if relevant, suggest easing off weight or
  checking form, and for anything beyond that, seeing a doctor or physical
  therapist.
- Keep everything specific to "$exerciseName" — don't give generic
  full-body advice that could apply to any exercise.
''';
  }

  static final Schema _schema = Schema.object(
    properties: {
      'setup': Schema.string(),
      'execution': Schema.string(),
      'commonMistakes': Schema.array(
        minItems: 2,
        maxItems: 4,
        items: Schema.string(),
      ),
      'safetyTip': Schema.string(),
    },
  );
}
