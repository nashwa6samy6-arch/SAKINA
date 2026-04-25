import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';

class SurveyOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SurveyOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(width: double.infinity,
       
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBrown
              : AppColors.textFieldBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrown : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            SizedBox(height: 16.h),
            Text(
              textAlign: TextAlign.start,
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryBrown,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              textAlign: TextAlign.start,
              description,
              style: TextStyle(
                color: (isSelected ? Colors.white : AppColors.primaryBrown),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
