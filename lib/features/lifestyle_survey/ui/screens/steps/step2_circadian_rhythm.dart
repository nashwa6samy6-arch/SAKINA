import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_bloc.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_event.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_state.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_option_card.dart';

class StepCircadianRhythm extends StatelessWidget {
  const StepCircadianRhythm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Text(
            textAlign: TextAlign.start,
            'Circadian Rhythm',
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 20.sp,
              fontWeight: FontWeight(400),
            ),
          ),

          SizedBox(height: 25.h),
          BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
            builder: (context, state) {
              return Column(
                children: [
                  SurveyOptionCard(
                    title: 'Early Bird',
                    description: 'Active by sunrise, quiet by 10 PM.         ',
                    icon: Icon(
                      Icons.wb_sunny_outlined,
                      color: state.circadianRhythm == 'Early Bird'
                          ? Colors.white
                          : AppColors.primaryBrown,
                      size: 32.sp,
                    ),
                    isSelected: state.circadianRhythm == 'Early Bird',
                    onTap: () => context.read<LifestyleSurveyBloc>().add(
                      CircadianRhythmChanged('Early Bird'),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SurveyOptionCard(
                    title: 'Night Owl',

                    description: 'Creative after dark, dormant until noon.',
                    icon: Icon(
                      Icons.nightlight_outlined,
                      color: state.circadianRhythm == 'Night Owl'
                          ? Colors.white
                          : AppColors.primaryBrown,
                      size: 32.sp,
                    ),
                    isSelected: state.circadianRhythm == 'Night Owl',
                    onTap: () => context.read<LifestyleSurveyBloc>().add(
                      CircadianRhythmChanged('Night Owl'),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
