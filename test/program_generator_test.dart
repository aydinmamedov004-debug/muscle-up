import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_up/features/programs/providers/program_generator.dart';

void main() {
  final validNames = {"Bench Press", "Cable Fly", "Barbell Squat"};

  test('parses a well-formed response into programs', () {
    const raw = '''
    [
      {
        "name": "Full Body",
        "exercises": [
          {"name": "Bench Press", "targetSets": 4, "minReps": 6, "maxReps": 10, "restSeconds": 90},
          {"name": "Barbell Squat", "targetSets": 3, "minReps": 8, "maxReps": 12, "restSeconds": 120}
        ]
      }
    ]
    ''';

    final programs = ProgramGenerator.parsePrograms(raw, validNames);

    expect(programs, hasLength(1));
    expect(programs.single.name, "Full Body");
    expect(programs.single.exercises.map((e) => e.name), [
      "Bench Press",
      "Barbell Squat",
    ]);
    expect(programs.single.exercises.first.targetSets, 4);
    expect(programs.single.exercises.first.restSeconds, 90);
  });

  test('drops exercises whose name is not in the real catalog', () {
    const raw = '''
    [
      {
        "name": "Push Day",
        "exercises": [
          {"name": "Bench Press", "targetSets": 3, "minReps": 8, "maxReps": 12, "restSeconds": 90},
          {"name": "Made Up Exercise", "targetSets": 3, "minReps": 8, "maxReps": 12, "restSeconds": 90}
        ]
      }
    ]
    ''';

    final programs = ProgramGenerator.parsePrograms(raw, validNames);

    expect(programs.single.exercises, hasLength(1));
    expect(programs.single.exercises.single.name, "Bench Press");
  });

  test('drops a whole program if every exercise in it is invalid', () {
    const raw = '''
    [
      {
        "name": "Bad Program",
        "exercises": [
          {"name": "Not Real", "targetSets": 3, "minReps": 8, "maxReps": 12, "restSeconds": 90}
        ]
      },
      {
        "name": "Good Program",
        "exercises": [
          {"name": "Cable Fly", "targetSets": 3, "minReps": 10, "maxReps": 15, "restSeconds": 60}
        ]
      }
    ]
    ''';

    final programs = ProgramGenerator.parsePrograms(raw, validNames);

    expect(programs, hasLength(1));
    expect(programs.single.name, "Good Program");
  });

  test('clamps out-of-range numeric values instead of trusting them', () {
    const raw = '''
    [
      {
        "name": "Extreme",
        "exercises": [
          {"name": "Bench Press", "targetSets": 99, "minReps": 0, "maxReps": 500, "restSeconds": 5}
        ]
      }
    ]
    ''';

    final programs = ProgramGenerator.parsePrograms(raw, validNames);
    final exercise = programs.single.exercises.single;

    expect(exercise.targetSets, 6);
    expect(exercise.minReps, 3);
    expect(exercise.maxReps, 20);
    expect(exercise.restSeconds, 30);
  });

  test('falls back to sane defaults for missing numeric fields', () {
    const raw = '''
    [
      {
        "name": "Sparse",
        "exercises": [
          {"name": "Bench Press"}
        ]
      }
    ]
    ''';

    final programs = ProgramGenerator.parsePrograms(raw, validNames);
    final exercise = programs.single.exercises.single;

    expect(exercise.targetSets, 3);
    expect(exercise.minReps, 8);
    expect(exercise.maxReps, 12);
    expect(exercise.restSeconds, 90);
  });

  test('throws when the response is not valid JSON', () {
    expect(
      () => ProgramGenerator.parsePrograms("not json", validNames),
      throwsA(isA<ProgramGenerationException>()),
    );
  });

  test('throws when nothing survives validation', () {
    const raw = '''
    [
      {"name": "All Bad", "exercises": [{"name": "Nonexistent"}]}
    ]
    ''';

    expect(
      () => ProgramGenerator.parsePrograms(raw, validNames),
      throwsA(isA<ProgramGenerationException>()),
    );
  });
}
