import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';

class ListingBottomBar extends StatelessWidget {
  final VoidCallback? onBookViewing;
  final VoidCallback? onChat;

  const ListingBottomBar({
    super.key,
    this.onBookViewing,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Row(
        children: [
          // ── Book Viewing button ──
          Expanded(
            child: GestureDetector(
              onTap: onBookViewing,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBeig,
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Request Property',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Chat icon button ──
          GestureDetector(
            onTap: onChat,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryBeig,
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF1A1A1A),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}