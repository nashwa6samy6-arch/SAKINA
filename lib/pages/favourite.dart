import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_app_bar.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Myappbar(),
      backgroundColor: AppColors.primaryColor,
      body: const Center(
        child: Text('Favourite Page'),
      ),
    );
  }
}