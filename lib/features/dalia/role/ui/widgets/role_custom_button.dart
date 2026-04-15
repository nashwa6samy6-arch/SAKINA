import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/features/dalia/login/ui/login_screen.dart';

class RoleCustomButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  const RoleCustomButton({
    super.key,
    required this.buttonText,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      },
      child: Container(
        width: 292.w,
        height: 53.h,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
