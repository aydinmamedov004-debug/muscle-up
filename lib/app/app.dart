import 'package:flutter/material.dart';

class MuscleUpApp extends StatelessWidget {
  const MuscleUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text("Muscle-up 💪"),
        ),
      ),
    );
  }
}