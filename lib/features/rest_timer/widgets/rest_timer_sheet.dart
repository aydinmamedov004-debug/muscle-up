import 'dart:async';

import 'package:flutter/material.dart';

class RestTimerSheet extends StatefulWidget {
  const RestTimerSheet({super.key});

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet> {
  late Timer timer;
  int secondsRemaining = 90;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatTime() {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Rest Time",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              formatTime(),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        secondsRemaining =
                            (secondsRemaining - 15).clamp(0, 3600);
                      });
                    },
                    child: const Text("-15s"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        secondsRemaining += 15;
                      });
                    },
                    child: const Text("+15s"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Skip Rest"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}