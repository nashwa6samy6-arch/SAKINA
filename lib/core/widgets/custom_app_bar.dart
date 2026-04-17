import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';

class Myappbar extends StatelessWidget implements PreferredSizeWidget {
  const Myappbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Home Page'),
      backgroundColor: AppColors.appbarColor,
      leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
