import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
        title: Text('Help & Support',
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
                Text('FREQUENTLY ASKED QUESTIONS',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: const Color(0xFF888888))),
                SizedBox(height: 12.h),
                _faqItem(
                  'How do I edit my listing?',
                  'Go to My Listings, tap on the listing, then tap Edit.',
                ),
                _faqItem(
                  'How do I contact a tenant?',
                  'When a tenant messages you, you will see the conversation in the Messages tab.',
                ),
                _faqItem(
                  'How do I change my password?',
                  'Go to Settings → Security → Change Password.',
                ),
                _faqItem(
                  'Can I delete my listing?',
                  'Yes, open the listing details and tap Delete Listing.',
                ),
                SizedBox(height: 24.h),
                Text('CONTACT SUPPORT',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: const Color(0xFF888888))),
                SizedBox(height: 12.h),
                _contactButton(
                  'Email Us',
                  Icons.email_outlined,
                  () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'support@sakina.com',
                      query: 'subject=Help Request',
                    );
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  },
                ),
                SizedBox(height: 12.h),
                _contactButton(
                  'Call Support',
                  Icons.phone_outlined,
                  () async {
                    final Uri phoneUri = Uri(scheme: 'tel', path: '+20123456789');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        title: Text(question,
            style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2416))),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Text(answer,
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.sp,
                    color: const Color(0xFF4C463C))),
          ),
        ],
      ),
    );
  }

  Widget _contactButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.fontColor, size: 20.r),
            SizedBox(width: 10.w),
            Text(title,
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2416))),
          ],
        ),
      ),
    );
  }
}
