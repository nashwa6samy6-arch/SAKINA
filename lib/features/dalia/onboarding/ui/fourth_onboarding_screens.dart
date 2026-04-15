import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/dalia/role/ui/role_screen.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class FourthOnboardingScreens extends StatelessWidget {
  const FourthOnboardingScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,

        children: [
          Positioned(
            top: 0,
            bottom: 300,
            child: Image.asset(
              "assets/dalia_assets/pictures/onboarding4.png",
              width: 1.sw,
              height: 0.45.sh,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16.r),
              width: 390.w,
              height: 480.h,
              decoration: ShapeDecoration(
                color: AppColors.onBoardingContainerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Spacer(flex: 2),
                  Text(
                    LocaleKeys.get_started.tr(),
                    style: appTheme.titleText,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(flex: 2),
                  Text(
                    LocaleKeys.get_started_description.tr(),
                    style: appTheme.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            left: 30,
            child: InkWell(
  borderRadius: BorderRadius.circular(20.r),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoleScreen(),
      ),
    );
  },
  child: Container(
    height: 60.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r),
      color: AppColors.primaryBrown,
    ),
    child: Row(
      children: [
        Spacer(),
        Text(
          LocaleKeys.get_started.tr(),
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(width: 3.w),
        Icon(Icons.arrow_forward, color: Colors.white, size: 20.r),
        Spacer(),
      ],
    ),
  ),
),
          ),
        ],
      ),
    );
  }
}
