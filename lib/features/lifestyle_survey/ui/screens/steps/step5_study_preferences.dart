import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_bloc.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_event.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_state.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_chip_selector.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_slider.dart';

class StepStudyPreferences extends StatefulWidget {
  const StepStudyPreferences({super.key});

  @override
  State<StepStudyPreferences> createState() => _StepStudyPreferencesState();
}

class _StepStudyPreferencesState extends State<StepStudyPreferences> {
  bool _isDragging = false;

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
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 20.h),
          Center(
            child: BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
              builder: (context, state) {
                return AnimatedScale(
                  scale: _isDragging ? 1.0 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.studyHours.round()}',
                        style: TextStyle(
                          color: AppColors.primaryBrown,
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        state.studyHours.round() == 1 ? 'HOUR' : 'HOURS',
                        style: TextStyle(
                          color: AppColors.primaryBrown.withValues(alpha: 0.7),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
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
                onChangeStart: (_) => setState(() => _isDragging = true),
                onChangeEnd: (_) => setState(() => _isDragging = false),
                leftLabel: '1 HOUR',
                rightLabel: '16 HOUR',
              );
            },
          ),
           SizedBox(height: 20.h),
          Text(
            'Preferred study time',
            style: TextStyle(
              color: AppColors.fontColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
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
