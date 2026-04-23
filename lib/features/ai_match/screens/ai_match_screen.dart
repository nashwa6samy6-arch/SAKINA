import 'package:flutter/material.dart';

class AiMatchScreen extends StatelessWidget {
  const AiMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: const Center(
        child: Text('Your match is ready!'),
      ),
    );
  }
}