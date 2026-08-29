import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'models/chat_message.dart';
import 'providers/coach_provider.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  bool isSending = false;

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = textController.text;
    if (text.trim().isEmpty || isSending) return;

    textController.clear();
    setState(() => isSending = true);
    _scrollToBottom();

    await ref.read(coachControllerProvider.notifier).sendMessage(text);

    if (mounted) setState(() => isSending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(coachControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Coach"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: messages.length + (isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= messages.length) {
                    return const _AnimatedEntry(child: _TypingBubble());
                  }

                  return _AnimatedEntry(
                    key: ValueKey(index),
                    child: _MessageBubble(message: messages[index]),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: "Ask your coach...",
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  IconButton.filled(
                    onPressed: isSending ? null : _send,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final Widget child;

  const _AnimatedEntry({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Small leading avatar marking a message as the coach's, in place of an
/// emoji in the bubble text — a placeholder for the mascot avatar once
/// that's designed.
class _CoachAvatar extends StatelessWidget {
  const _CoachAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 14,
      backgroundColor: AppTheme.accentTint,
      child: Icon(Icons.support_agent, size: 16, color: AppTheme.primary),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: message.isUser ? AppTheme.primary : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: AppTheme.text),
      ),
    );

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: bubble,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const _CoachAvatar(),
            const SizedBox(width: AppSpacing.sm),
            bubble,
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _CoachAvatar(),
          const SizedBox(width: AppSpacing.sm),
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }
}
