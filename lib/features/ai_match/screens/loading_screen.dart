import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sakina/features/ai_match/screens/ai_match_screen.dart';
import '../painters/spinner_painter.dart';
import '../widgets/step_item.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  Timer? _timer;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startLoading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  void _navigateToMatch() { // ← step 2 goes here
  Future.delayed(const Duration(milliseconds: 800), () {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AiMatchScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  });
}

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      setState(() {
        _progress += Random().nextDouble() * 2.2;
        if (_progress >= 100) {
          _progress = 100;
          timer.cancel();
          _navigateToMatch(); // ← step 2 is called when loading completes
        }
      });
    });
  }

  StepStatus _getStatus(double from, double to) {
    if (_progress >= to) return StepStatus.done;
    if (_progress >= from) return StepStatus.active;
    return StepStatus.pending;
  }

  Widget _buildSpinner() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (_, _) => CustomPaint(
        size: const Size(140, 140),
        painter: SpinnerPainter(_spinController.value * 2 * pi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _progress >= 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand
                const Text(
                  'SakinaAI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),

                // Pill badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AI SYNTHESIS IN PROGRESS',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Headline
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.15,
                    ),
                    children: [
                      TextSpan(text: 'Finding your\nnew '),
                      TextSpan(
                        text: 'Home',
                        style: TextStyle(color: Color(0xFFB8824A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Subtext
                const Text(
                  'Our AI is matching you with the perfect space and companions. Curating a community that feels like home.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 36),

                // Steps
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StepItem(
                        label: 'Analyzing Lifestyle Survey',
                        status: _getStatus(0, 33),
                      ),
                      const SizedBox(height: 18),
                      StepItem(
                        label: 'Scanning Neighborhood Safety',
                        status: _getStatus(33, 66),
                      ),
                      const SizedBox(height: 18),
                      StepItem(
                        label: 'Verifying Peer Compatibility',
                        status: _getStatus(66, 100),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 44),

                // Spinner
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildSpinner(),
                    Text(
                      isComplete ? 'COMPLETE' : 'MATCHING',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress text
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: isComplete
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFAAAAAA),
                    fontWeight: isComplete ? FontWeight.w500 : FontWeight.w400,
                  ),
                  child: Text(
                    isComplete
                        ? 'Match found!'
                        : '${_progress.floor()}% complete',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}