import 'package:flutter/material.dart';

import '../../../models/workout_set.dart';
import '../../rest_timer/widgets/rest_timer_sheet.dart';

class SetRow extends StatefulWidget {
  final int setNumber;
  final WorkoutSet workoutSet;
  final VoidCallback onDelete;
  final ValueChanged<bool>? onCompletedChanged;

  const SetRow({
    super.key,
    required this.setNumber,
    required this.workoutSet,
    required this.onDelete,
    this.onCompletedChanged,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late final TextEditingController weightController;
  late final TextEditingController repsController;

  @override
  void initState() {
    super.initState();

    weightController = TextEditingController(
      text: widget.workoutSet.weight?.toString() ?? '',
    );

    repsController = TextEditingController(
      text: widget.workoutSet.reps?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showRestTimer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RestTimerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.workoutSet.completed;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: completed ? 0.6 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                "${widget.setNumber}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: TextField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: inputDecoration("kg"),
                onChanged: (value) {
                  widget.workoutSet.weight = double.tryParse(value);
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration("reps"),
                onChanged: (value) {
                  widget.workoutSet.reps = int.tryParse(value);
                },
              ),
            ),

            Checkbox(
              value: completed,
              onChanged: (value) {
                setState(() {
                  final wasCompleted = widget.workoutSet.completed;
                  widget.workoutSet.completed = value ?? false;

                  if (!wasCompleted && widget.workoutSet.completed) {
                    widget.onCompletedChanged?.call(true);
                    _showRestTimer();
                  }
                });
              },
            ),

            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}