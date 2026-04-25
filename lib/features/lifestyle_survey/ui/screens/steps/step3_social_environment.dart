import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_bloc.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_event.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_state.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_chip_selector.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_slider.dart';

class StepSocialEnvironment extends StatelessWidget {
  const StepSocialEnvironment({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Text(
            'Environment Order',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),

          BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
            builder: (context, state) {
              return SurveySlider(
                value: state.environmentalOrder,
                onChanged: (val) => context.read<LifestyleSurveyBloc>().add(
                  EnvironmentalOrderChanged(val),
                ),
                leftLabel: 'RELAXED',
                centerLabel: 'BALANCED',
                rightLabel: 'IMMACULATE',
              );
            },
          ),
          SizedBox(height: 99.h),
          Text(
            'Social Threshold',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'How often do you invite guests into your sanctuary?',
            style: TextStyle(color: AppColors.primaryBrown, fontSize: 14.sp),
          ),
          SizedBox(height: 40.h),
          BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
            builder: (context, state) {
              return SurveyChipSelector(
                options: const [
                  'Rarely (Introvert)',
                  'Weekends Only',
                  'Frequent Socialite',
                  'Varies',
                ],
                selectedOption: state.socialThreshold,
                onSelected: (val) => context.read<LifestyleSurveyBloc>().add(
                  SocialThresholdChanged(val),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
