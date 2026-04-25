import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';

class LifestyleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LifestyleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 120.w,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.avatarolor,
              child: const Icon(
                Icons.person_outline,
                size: 25,
                color: AppColors.primaryBrown,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              'Sakina',
              style: TextStyle(
                color: AppColors.primaryBrown,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: AppColors.primaryBrown,
          ),
          onPressed: () {
            // I put it for the notifications
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}