import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class SocialAuthButtons extends StatelessWidget {
  final String googleLabel;
  final String appleLabel;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  const SocialAuthButtons({
    super.key,
    required this.googleLabel,
    required this.appleLabel,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(
              child: Divider(
                thickness: 1,
                color: Colors.grey,
                endIndent: 10,
              ),
            ),
            Text(
              LocaleKeys.divider_text.tr(),
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Expanded(
              child: Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 10,
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h), 

        // (Google & Apple)
        Row(
          children: [
            Expanded(
              child: _buildSocialItem(
                label: googleLabel,
                icon: Icons.g_mobiledata,
                onTap: onGoogleTap,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildSocialItem(
                label: appleLabel,
                icon: Icons.window,
                onTap: onAppleTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Method to prevent repeating the Button code
  Widget _buildSocialItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black, size: 24.sp),
      label: Text(
        label,
        style: TextStyle(color: Colors.black, fontSize: 12.sp),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        side: const BorderSide(color: Colors.grey, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}