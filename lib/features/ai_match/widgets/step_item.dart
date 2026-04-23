import 'package:flutter/material.dart';

enum StepStatus { pending, active, done }

class StepItem extends StatelessWidget {
  final String label;
  final StepStatus status;

  const StepItem({super.key, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDone = status == StepStatus.done;
    final isActive = status == StepStatus.active;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? const Color(0xFF1A1A1A) : Colors.transparent,
            border: Border.all(
              color: isDone
                  ? const Color(0xFF1A1A1A)
                  : isActive
                      ? const Color(0xFFB8824A)
                      : const Color(0xFFCCCCCC),
              width: 1.5,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          style: TextStyle(
            fontSize: 13,
            color: isDone
                ? const Color(0xFF1A1A1A)
                : isActive
                    ? const Color(0xFFB8824A)
                    : const Color(0xFFBBBBBB),
            fontWeight:
                isDone || isActive ? FontWeight.w500 : FontWeight.w400,
            decoration:
                isDone ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: const Color(0xFFAAAAAA),
          ),
          child: Text(label),
        ),
      ],
    );
  }
}