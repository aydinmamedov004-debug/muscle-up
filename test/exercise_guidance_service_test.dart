import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_up/features/exercises/providers/exercise_guidance_service.dart';

void main() {
  test('parses a well-formed response', () {
    const raw = '''
    {
      "setup": "Lie on the bench with feet flat on the floor.",
      "execution": "Lower the bar to your chest, then press up.",
      "commonMistakes": ["Bouncing the bar off the chest", "Flaring elbows too wide"],
      "safetyTip": "Use a spotter for heavy sets."
    }
    ''';

    final guidance = ExerciseGuidanceService.parseGuidance(raw);

    expect(guidance.setup, "Lie on the bench with feet flat on the floor.");
    expect(guidance.execution, "Lower the bar to your chest, then press up.");
    expect(guidance.commonMistakes, hasLength(2));
    expect(guidance.safetyTip, "Use a spotter for heavy sets.");
  });

  test('falls back to a default safety tip when missing', () {
    const raw = '''
    {
      "setup": "Setup text.",
      "execution": "Execution text.",
      "commonMistakes": ["Mistake one"]
    }
    ''';

    final guidance = ExerciseGuidanceService.parseGuidance(raw);

    expect(guidance.safetyTip, isNotEmpty);
    expect(guidance.safetyTip, contains("stop"));
  });

  test('drops blank entries from commonMistakes', () {
    const raw = '''
    {
      "setup": "Setup text.",
      "execution": "Execution text.",
      "commonMistakes": ["Real mistake", "   ", ""],
      "safetyTip": "Tip."
    }
    ''';

    final guidance = ExerciseGuidanceService.parseGuidance(raw);

    expect(guidance.commonMistakes, ["Real mistake"]);
  });

  test('throws when setup is missing', () {
    const raw = '''
    {
      "execution": "Execution text.",
      "commonMistakes": ["Mistake one"],
      "safetyTip": "Tip."
    }
    ''';

    expect(
      () => ExerciseGuidanceService.parseGuidance(raw),
      throwsA(isA<ExerciseGuidanceException>()),
    );
  });

  test('throws when commonMistakes is empty', () {
    const raw = '''
    {
      "setup": "Setup text.",
      "execution": "Execution text.",
      "commonMistakes": [],
      "safetyTip": "Tip."
    }
    ''';

    expect(
      () => ExerciseGuidanceService.parseGuidance(raw),
      throwsA(isA<ExerciseGuidanceException>()),
    );
  });

  test('throws when the response is not valid JSON', () {
    expect(
      () => ExerciseGuidanceService.parseGuidance("not json"),
      throwsA(isA<ExerciseGuidanceException>()),
    );
  });
}
