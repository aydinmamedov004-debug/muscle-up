/// AI-generated form guidance for a single exercise. Plain data, not a
/// Hive-typed model — cached as a raw Map in
/// [HiveService.exerciseGuidanceCacheBoxRef] since Hive stores
/// Map/List/String natively without needing a generated adapter.
class ExerciseGuidance {
  final String setup;
  final String execution;
  final List<String> commonMistakes;
  final String safetyTip;

  const ExerciseGuidance({
    required this.setup,
    required this.execution,
    required this.commonMistakes,
    required this.safetyTip,
  });

  Map<String, dynamic> toJson() => {
    'setup': setup,
    'execution': execution,
    'commonMistakes': commonMistakes,
    'safetyTip': safetyTip,
  };

  factory ExerciseGuidance.fromJson(Map<String, dynamic> json) {
    return ExerciseGuidance(
      setup: json['setup'] as String,
      execution: json['execution'] as String,
      commonMistakes: (json['commonMistakes'] as List)
          .map((e) => e as String)
          .toList(),
      safetyTip: json['safetyTip'] as String,
    );
  }
}
