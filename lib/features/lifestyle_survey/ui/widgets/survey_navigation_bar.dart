import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class SurveyNavigationBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isFirstPage;
  final bool isLastPage;

  const SurveyNavigationBar({
    super.key,
    this.onBack,
    this.onNext,
    this.isFirstPage = false,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isFirstPage)
            TextButton(
              onPressed: onBack,
              child: Text(
                LocaleKeys.back.tr(),
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          TextButton(
            onPressed: onNext,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastPage ? LocaleKeys.finish.tr() : LocaleKeys.next.tr(),
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.primaryBrown,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
