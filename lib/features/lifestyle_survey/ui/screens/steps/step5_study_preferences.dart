import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_bloc.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_event.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_state.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_chip_selector.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_slider.dart';

class StepStudyPreferences extends StatelessWidget {
  const StepStudyPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),

          Text(
            'Daily study hours',
            style: TextStyle(
              color: AppColors.fontColor,
              fontSize: 20.sp,
              fontWeight: FontWeight(400),
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 24.h),
          BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
            builder: (context, state) {
              return SurveySlider(
                centerLabel: "",
                value: state.studyHours,
                min: 1,
                max: 16,
                divisions: 15,
                onChanged: (val) => context.read<LifestyleSurveyBloc>().add(
                  StudyHoursChanged(val),
                ),
                leftLabel: '1 HOUR',
                rightLabel: '16 HOUR',
              );
            },
          ),
          SizedBox(height: 111.h),
          Text(
            'Preferred study time',
            style: TextStyle(
              color: AppColors.fontColor,
              fontSize: 20.sp,
              fontWeight: FontWeight(400),
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 30.h),
          BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
            builder: (context, state) {
              return SurveyChipSelector(
                options: const [
                  'Morning',
                  'Afternoon',
                  'Evening',
                  'Late night',
                ],
                selectedOption: state.studyTime,
                onSelected: (val) => context.read<LifestyleSurveyBloc>().add(
                  StudyTimeChanged(val),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
