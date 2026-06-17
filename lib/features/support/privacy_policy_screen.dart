import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2416)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Privacy Policy',
            style: TextStyle(
                color: const Color(0xFF2C2416),
                fontSize: 18.sp,
                fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LAST UPDATED: May 2026',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.sp,
                        color: const Color(0xFF888888))),
                SizedBox(height: 20.h),
                _section('1. Information We Collect',
                    'We collect personal information you provide directly, such as name, email, phone number, and property details. We also collect usage data automatically.'),
                _section('2. How We Use Your Information',
                    'We use your information to provide, maintain, and improve our services, to communicate with you, and to comply with legal obligations.'),
                _section('3. Sharing of Information',
                    'We do not share your personal information with third parties except as necessary to provide our services (e.g., payment processing) or as required by law.'),
                _section('4. Data Security',
                    'We implement industry-standard security measures to protect your data, but no method of transmission over the Internet is 100% secure.'),
                _section('5. Your Rights',
                    'You may access, correct, or delete your personal information by contacting us.'),
                _section('6. Contact Us',
                    'If you have questions about this Privacy Policy, please contact us at privacy@sakina.com.'),
                SizedBox(height: 20.h),
                Center(
                  child: Text('© 2026 Sakina. All rights reserved.',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12.sp,
                          color: Colors.grey[600])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2416))),
          SizedBox(height: 8.h),
          Text(content,
              style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14.sp,
                  height: 1.5,
                  color: const Color(0xFF4C463C))),
        ],
      ),
    );
  }
}
