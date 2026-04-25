import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_bloc.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_event.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_state.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_chip_selector.dart';

class StepPets extends StatelessWidget {
  const StepPets({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Text(
            'Preferred animals',
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 20.sp,
              fontWeight: FontWeight(400),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.textFieldBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      color: AppColors.primaryBrown,
                      size: 24.sp,
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Pets',
                      style: TextStyle(
                        color: AppColors.primaryBrown,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
                  builder: (context, state) {
                    return SurveyChipSelector(
                      chipWidth: 143.w,
                      options: const ['None', 'Have'],
                      selectedOption: state.pets,
                      onSelected: (val) => context
                          .read<LifestyleSurveyBloc>()
                          .add(PetsChanged(val)),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 72.h),
          Text(
            'Habits',
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 20.sp,
              fontWeight: FontWeight(400),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.textFieldBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/smoke.svg",
                      width: 20.w,
                      height: 17,
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Smoking',
                      style: TextStyle(
                        color: AppColors.primaryBrown,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
                  builder: (context, state) {
                    return SurveyChipSelector(
                      chipWidth: 143.w,
                      options: const ['Non-smoker', 'Smoker'],
                      selectedOption: state.smoking,
                      onSelected: (val) => context
                          .read<LifestyleSurveyBloc>()
                          .add(SmokingChanged(val)),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
