import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';

class Customtextrich extends StatelessWidget {
  const Customtextrich({super.key, this.textTitle, required this.textButton, this.tapped});
final String ?textTitle;
final String textButton;
final void Function()?tapped;

  @override
  Widget build(BuildContext context) {
    return textTitle==null?Text.rich(TextSpan(text: textButton,style:Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryBrown),
        recognizer: TapGestureRecognizer()..onTap=tapped))
        :Text.rich( TextSpan(text: '$textTitle ',children: [TextSpan(text: textButton,style:Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryBrown),
            recognizer: TapGestureRecognizer()..onTap=tapped)])
    );

  }
}