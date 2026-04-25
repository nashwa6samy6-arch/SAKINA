import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class StepIntroScreen extends StatelessWidget {
  const StepIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The back button requested by the user
          // It allows navigating back to the previous screen (Login/Role selection)
          SizedBox(height: 20.h),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.primaryBrown,
              size: 24.sp,
            ),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          
          SizedBox(height: 56.h),
          
          // Header text with letter spacing
          Text(
            textAlign: TextAlign.start,
            LocaleKeys.curated_living.tr(),
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          
          SizedBox(height: 48.h),
          
          // Main title of the survey intro
          Text(
            LocaleKeys.survey_intro_title.tr(),
            textAlign: TextAlign.start,
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 59.h),
          
          // Descriptive text explaining the AI compatibility matching
          Text(
            LocaleKeys.survey_intro_subtitle.tr(),
            textAlign: TextAlign.start,
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 18.sp,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
