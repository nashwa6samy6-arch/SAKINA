import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/dalia/onboarding/ui/fourth_onboarding_screens.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class ThirdOnboardingScreens extends StatelessWidget {
  const ThirdOnboardingScreens({super.key});

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
              "assets/dalia_assets/pictures/onboarding3.png",
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
              height: 470.h,
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
                    LocaleKeys.discover_services.tr(),
                    style: appTheme.titleText,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(flex: 2),
                  Text(
                    LocaleKeys.services_description.tr(),
                    style: appTheme.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(flex: 2),
                  SvgPicture.asset("assets/dalia_assets/icons/step3.svg"),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      LocaleKeys.back.tr(),
                      style: TextStyle(color: AppColors.primaryBrown),
                    ),
                  ),
                ),
                SizedBox(width: 210.w),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FourthOnboardingScreens(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocaleKeys.next.tr(),
                          style: TextStyle(color: AppColors.primaryBrown),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.arrow_forward, color: Colors.brown),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
