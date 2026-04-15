import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/features/dalia/role/ui/widgets/role_custom_button.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocaleKeys.choose_role.tr(),textAlign: TextAlign.center,
            style: TextStyle(fontSize: 45.sp,),),
            SizedBox(height: 15.h,),
            RoleCustomButton(buttonText: LocaleKeys.tenant.tr(),buttonColor: Color(0xff6D5C3B),),
            SizedBox(height: 12.h,),
            RoleCustomButton(buttonText: LocaleKeys.landlord.tr(),buttonColor: Color(0xff4C463C),),
          ],
        ),
      ),
    );
  }
}
