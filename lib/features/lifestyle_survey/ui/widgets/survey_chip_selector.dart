import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';

class SurveyChipSelector extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onSelected;
  final double? chipWidth;

  const SurveyChipSelector({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.chipWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: options.map((option) {
        final isSelected = option == selectedOption;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            width: (chipWidth ?? 160).w,
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xffF7E0B6)
                  : AppColors.unSelectedChip,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xffF7E0B6)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              textAlign: TextAlign.center,
              option,
              style: TextStyle(
                color: AppColors.fontColor,
                fontSize: 14.sp,
                fontWeight: FontWeight(400),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
