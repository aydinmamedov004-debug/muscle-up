import 'package:flutter/material.dart';

class CreateProgramDialog extends StatefulWidget {
  final String? initialName;

  const CreateProgramDialog({
    super.key,
    this.initialName,
  });

  @override
  State<CreateProgramDialog> createState() =>
      _CreateProgramDialogState();
}

class _CreateProgramDialogState
    extends State<CreateProgramDialog> {
  late final controller = TextEditingController(
    text: widget.initialName ?? '',
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Workout Program"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: "Program name",
          hintText: "Push Day",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();

            if (name.isEmpty) return;

            Navigator.pop(context, name);
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}