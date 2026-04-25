import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';

class SurveySlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String leftLabel;
  final String centerLabel;
  final String rightLabel;
  final Function(double) onChanged;

  const SurveySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 10,
    required this.leftLabel,
    required this.centerLabel,
    required this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primaryBrown,
            inactiveTrackColor: AppColors.textFieldBackground,
            thumbColor: AppColors.primaryBrown,
            overlayColor: AppColors.primaryBrown,
            trackHeight: 4.h,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //first label
              Expanded(
                child: Text(
                  leftLabel,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: 10.sp,
                  ),
                ),
              ),

              //center label
              Expanded(
                child: Text(
                  centerLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: 10.sp,
                  ),
                ),
              ),

              //end label
              Expanded(
                child: Text(
                  rightLabel,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
