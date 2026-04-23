import 'dart:math';
import 'package:flutter/material.dart';

class SpinnerPainter extends CustomPainter {
  final double angle;

  SpinnerPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFDDDDDD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Rotating arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      angle - pi / 2,
      1.2,
      false,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Amber dot at arc head
    final dot = Offset(
      center.dx + radius * cos(angle - pi / 2),
      center.dy + radius * sin(angle - pi / 2),
    );
    canvas.drawCircle(dot, 4, Paint()..color = const Color(0xFFB8824A));
  }

  @override
  bool shouldRepaint(SpinnerPainter old) => old.angle != angle;
}