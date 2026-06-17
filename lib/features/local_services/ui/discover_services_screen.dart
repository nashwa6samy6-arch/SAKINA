
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_app_bar.dart';
import 'package:sakina/core/widgets/bottom_bar.dart';
import 'package:sakina/features/local_services/ui/widgets/category_selector.dart';
import 'package:sakina/features/local_services/ui/widgets/food_content.dart';
import 'package:sakina/features/local_services/ui/widgets/service_model.dart';
import 'widgets/discover_header.dart';
import 'package:sakina/features/local_services/ui/widgets/all_services_content.dart';
import 'package:sakina/features/local_services/ui/widgets/laundry_content.dart';
import 'package:sakina/features/local_services/ui/widgets/maintenance_content.dart';

class DiscoverServicesScreen extends StatefulWidget {
  const DiscoverServicesScreen({super.key});

  @override
  State<DiscoverServicesScreen> createState() => _DiscoverServicesScreenState();
}

class _DiscoverServicesScreenState extends State<DiscoverServicesScreen> {
  ServiceCategory _selectedCategory = ServiceCategory.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Myappbar(
        showBackButton: true,
        showProfile: true,

      ),
      backgroundColor: AppColors.primaryColor,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Assuming Explore/Services is index 1
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ButtomNavBarScreen(initialIndex: index)),
          );
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DiscoverHeader(),
                  SizedBox(height: 32.h),
                  CategorySelector(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                  SizedBox(height: 32.h),
                  _buildActiveSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSection() {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    child: _getContentWidget(), 
  );
}

Widget _getContentWidget() {
  switch (_selectedCategory) {
    case ServiceCategory.food:
      return const FoodContent(key: ValueKey('food'));
    case ServiceCategory.laundry:
      return const LaundryContent(key: ValueKey('laundry'));
    case ServiceCategory.maintenance:
      return const MaintenanceContent(key: ValueKey('maintenance'));
    default:
      return const AllServicesContent(key: ValueKey('all'));
  }
}
}