import 'package:flutter/material.dart';

import '../../../shared/widgets/primary_button.dart';

class StartSessionCard extends StatelessWidget {
  final VoidCallback onPressed;

  const StartSessionCard({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.play_circle_fill,
              size: 64,
            ),

            const SizedBox(height: 16),

            Text(
              "Ready to begin?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            const Text(
              "Review today's workout, prepare your equipment, then start your session.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "START SESSION",
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}