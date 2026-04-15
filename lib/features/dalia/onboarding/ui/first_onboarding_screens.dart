import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/dalia/onboarding/ui/second_onboarding_screens.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class FirstOnboardingScreens extends StatelessWidget {
  const FirstOnboardingScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Image.asset(
              width: double.infinity,
              "assets/dalia_assets/pictures/onboarding1.png",
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
                  IconButton(
                    onPressed: () {
                      if (context.locale.languageCode == 'ar') {
                        context.setLocale(const Locale('en'));
                      } else {
                        context.setLocale(const Locale('ar'));
                      }
                    },
                    icon: const Icon(Icons.language),
                  ),
                  Spacer(flex: 2),
                  Text(
                    LocaleKeys.right_place.tr(),
                    style: appTheme.titleText,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(flex: 2),
                  Text(
                    LocaleKeys.search_description.tr(),
                    style: appTheme.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(flex: 2),
                  SvgPicture.asset("assets/dalia_assets/icons/step1.svg"),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left :context.locale.languageCode=="en"? 10:null, 
            right: context.locale.languageCode=="ar"? 10:null,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecondOnboardingScreens(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
    );
  }
}
