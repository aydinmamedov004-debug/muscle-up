import 'dart:async';

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

  // Which coach message indices have already played their typewriter
  // reveal — tracked here (not inside the bubble's own State) so it
  // survives the bubble being disposed/recreated as the list scrolls, and
  // a message never "re-types" itself just because you scrolled back to
  // it.
  final Set<int> _typedIndices = {};

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

  /// Instant (unanimated) follow-scroll used while a message is mid-typewriter
  /// — called often enough that animating each call would just fight itself.
  void _scrollToBottomInstant() {
    if (!scrollController.hasClients) return;
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
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

                  final message = messages[index];
                  final animate =
                      !message.isUser && !_typedIndices.contains(index);

                  return _AnimatedEntry(
                    key: ValueKey(index),
                    child: _MessageBubble(
                      message: message,
                      animateText: animate,
                      onTypingTick: animate
                          ? (revealed) {
                              if (revealed % 8 == 0) _scrollToBottomInstant();
                            }
                          : null,
                      onTypingComplete: animate
                          ? () {
                              if (!mounted) return;
                              setState(() => _typedIndices.add(index));
                              _scrollToBottom();
                            }
                          : null,
                    ),
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
  final bool animateText;
  final ValueChanged<int>? onTypingTick;
  final VoidCallback? onTypingComplete;

  const _MessageBubble({
    required this.message,
    this.animateText = false,
    this.onTypingTick,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: AppTheme.text);

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: message.isUser ? AppTheme.primary : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: animateText
          ? _TypewriterText(
              text: message.text,
              style: textStyle,
              onTick: onTypingTick,
              onComplete: onTypingComplete,
            )
          : Text(message.text, style: textStyle),
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

/// Reveals [text] one character at a time, like the coach is typing it live
/// — rather than the full reply just appearing, which reads as a
/// pre-written, static response instead of something generated for you.
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final ValueChanged<int>? onTick;
  final VoidCallback? onComplete;

  const _TypewriterText({
    required this.text,
    this.style,
    this.onTick,
    this.onComplete,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  static const _perCharDelay = Duration(milliseconds: 15);

  int _charCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Message text is immutable once created in practice, but guard
    // against a widget instance being reused for different text anyway.
    if (oldWidget.text != widget.text) {
      _charCount = 0;
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();

    if (widget.text.isEmpty) {
      widget.onComplete?.call();
      return;
    }

    _timer = Timer.periodic(_perCharDelay, (timer) {
      if (_charCount >= widget.text.length) {
        timer.cancel();
        widget.onComplete?.call();
        return;
      }

      setState(() => _charCount++);
      widget.onTick?.call(_charCount);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _charCount.clamp(0, widget.text.length)),
      style: widget.style,
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
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

/// Three dots bouncing in sequence — the standard "someone is typing"
/// affordance, in place of a plain loading spinner that reads as "the app
/// is busy" rather than "the coach is composing a reply".
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_controller.value - i * 0.2) % 1.0;
              final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(0, -bounce * 5),
                  child: Opacity(
                    opacity: 0.4 + bounce * 0.6,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.text,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
