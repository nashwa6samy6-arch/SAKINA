import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/features/dalia/login/ui/login_screen.dart';

class RoleCustomButton extends StatelessWidget {
  final String button_text;
  final Color button_color;
  const RoleCustomButton({
    super.key,
    required this.button_text,
    required this.button_color,
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
          color: button_color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            button_text,
            style: TextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
