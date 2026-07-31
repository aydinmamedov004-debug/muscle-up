import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/exercise_catalog.dart';
import '../../../data/local/profile_provider.dart';
import '../../../models/storage/user_profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/dashboard_provider.dart';
import '../../programs/providers/active_program_provider.dart';
import '../models/chat_message.dart';

class CoachController extends Notifier<List<ChatMessage>> {
  late final ChatSession _chat;

  @override
  List<ChatMessage> build() {
    // Read (not watch) — this context should seed the conversation once,
    // not reset an in-progress chat whenever unrelated app state changes.
    final name = ref.read(authStateProvider).value?.displayName;
    final activeProgram = ref.read(activeProgramProvider);
    final dashboard = ref.read(dashboardProvider);
    final profile = ref.read(profileProvider);

    final systemInstruction = _buildSystemInstruction(
      name: name,
      programName: activeProgram?.name,
      exercises: activeProgram?.exercises
              .map((exercise) => exercise.name)
              .toList() ??
          const [],
      totalWorkouts: dashboard.stats.totalWorkouts,
      lastWorkoutName: dashboard.workouts.isEmpty
          ? null
          : dashboard.workouts.first.workoutName,
      availableExercises:
          allExercises.map((exercise) => exercise.name).toList(),
      profile: profile,
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
      systemInstruction: Content.system(systemInstruction),
    );

    _chat = model.startChat();

    final firstName = (name == null || name.isEmpty)
        ? null
        : name.trim().split(' ').first;

    return [
      ChatMessage(
        isUser: false,
        text: firstName == null
            ? "Hey! I'm your workout coach. Ask me anything about "
                "training, form, or just need a pep talk before you lift 💪"
            : "Hey $firstName! I'm your workout coach. Ask me anything "
                "about training, form, or just need a pep talk before "
                "you lift 💪",
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = [...state, ChatMessage(text: trimmed, isUser: true)];

    try {
      final response = await _chat.sendMessage(Content.text(trimmed));

      state = [
        ...state,
        ChatMessage(
          isUser: false,
          text: response.text ??
              "I'm not sure how to respond to that — try asking me "
                  "something else.",
        ),
      ];
    } catch (_) {
      state = [
        ...state,
        const ChatMessage(
          isUser: false,
          text: "Something went wrong reaching the coach. "
              "Please try again.",
        ),
      ];
    }
  }
}

final coachControllerProvider =
    NotifierProvider<CoachController, List<ChatMessage>>(
  CoachController.new,
);

String _buildSystemInstruction({
  required String? name,
  required String? programName,
  required List<String> exercises,
  required int totalWorkouts,
  required String? lastWorkoutName,
  required List<String> availableExercises,
  required UserProfile? profile,
}) {
  final buffer = StringBuffer()
    ..writeln(
      "You are Coach, a friendly, encouraging workout companion inside "
      "the Muscle Up fitness app. Help the user with workout advice, "
      "form tips, motivation, and fitness questions. Keep responses "
      "short and conversational (2-4 sentences) unless the user asks "
      "for more detail. Never give medical advice — for injuries or "
      "medical concerns, tell them to see a doctor or physical "
      "therapist.",
    )
    ..writeln(
      "When you name a specific exercise for the user to do, only name "
      "ones from this list, since those are the only ones logged in the "
      "app: ${availableExercises.join(', ')}. If the best exercise for "
      "what they're asking isn't on that list, say so and tell them "
      "they can add it themselves via the + button in the Exercise "
      "Library, rather than naming an exercise that isn't on the list.",
    );

  if (name != null && name.isNotEmpty) {
    buffer.writeln("The user's name is $name.");
  }

  if (programName != null) {
    final exerciseList =
        exercises.isEmpty ? "" : " with exercises: ${exercises.join(', ')}";

    buffer.writeln("Their current program is \"$programName\"$exerciseList.");
  }

  buffer.writeln(
    "They've logged $totalWorkouts "
    "${totalWorkouts == 1 ? 'workout' : 'workouts'} so far.",
  );

  if (lastWorkoutName != null) {
    buffer.writeln("Their most recent workout was \"$lastWorkoutName\".");
  }

  if (profile != null) {
    final weight = profile.weightUnit == 'lb'
        ? "${(profile.weightKg / 0.45359237).round()} lb"
        : "${profile.weightKg.round()} kg";

    final height = profile.heightUnit == 'ftIn'
        ? "${(profile.heightCm / 2.54 / 12).floor()}'"
            "${(profile.heightCm / 2.54 % 12).round()}\""
        : "${profile.heightCm.round()} cm";

    buffer.writeln(
      "The user is ${profile.ageYears} years old, weighs $weight, and is "
      "$height tall. They describe their training experience as "
      "${profile.experienceLevel} and aim to work out ${profile.weeklyGoal} "
      "${profile.weeklyGoal == 1 ? 'time' : 'times'} per week. Use this to "
      "tailor advice — don't ask them for these details again.",
    );
  }

  return buffer.toString();
}
