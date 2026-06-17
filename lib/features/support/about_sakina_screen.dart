import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';

class AboutSakinaScreen extends StatelessWidget {
  const AboutSakinaScreen({super.key});

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
        title: Text('About Sakina',
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
              children: [
                Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    color: AppColors.fontColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.home_work, size: 50.r, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20.h),
                Text('Sakina',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2416))),
                SizedBox(height: 8.h),
                Text('Version 2.4.0',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14.sp,
                        color: const Color(0xFF888888))),
                SizedBox(height: 24.h),
                Text(
                  'Sakina is a platform connecting students with safe, verified housing and trusted landlords. We believe in creating a secure and transparent rental experience for everyone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14.sp,
                      height: 1.6,
                      color: const Color(0xFF4C463C)),
                ),
                SizedBox(height: 32.h),
                _infoRow('Email:', 'hello@sakina.com'),
                _infoRow('Website:', 'www.sakina.com'),
                _infoRow('Founded:', '2025'),
                SizedBox(height: 32.h),
                Text('© 2026 Sakina. All rights reserved.',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.sp,
                        color: const Color(0xFF888888))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2416))),
          ),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14.sp,
                  color: const Color(0xFF4C463C))),
        ],
      ),
    );
  }
}
