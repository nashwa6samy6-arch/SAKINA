import 'package:sakina/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/pages/explore.dart';
import 'package:sakina/pages/favourite.dart';
import 'package:sakina/pages/home.dart';
import 'package:sakina/pages/messages/chat_screen/messages.dart';
import 'package:sakina/features/home/bloc/home_bloc.dart';

class ButtomNavBarScreen extends StatefulWidget {
  final int initialIndex;
  const ButtomNavBarScreen({super.key, this.initialIndex = 0});

  @override
  State<ButtomNavBarScreen> createState() => _ButtomNavBarScreenState();
}

class _ButtomNavBarScreenState extends State<ButtomNavBarScreen> {
  late int activeindex = 0;

  @override
  void initState() {
    super.initState();
    activeindex = widget.initialIndex;
  }

  List<Widget> screens = [
    BlocProvider(
      create: (context) => HomeBloc(),
      child: const HomePage(),
    ),
    const ExplorePage(),
    const FavouritePage(),
    const ConversationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      // FIX: extendBody بيخلي الـ Screen تفرش ورا الـ NavBar عشان الزوايا المنحنية تظهر صح
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: activeindex,
        onTap: (index) {
          setState(() {
            activeindex = index;
          });
        },
      ),
      body: SafeArea(
        // bottom: false عشان الـ SafeArea ما ترفعش الصفحة فوق الـ NavBar
        bottom: false,
        child: screens[activeindex],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavigationBarColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          // FIX: جعلنا الخلفية شفافة عشان تعتمد على لون الـ Container والـ BorderRadius
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: AppColors.themeColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color:
                      currentIndex == 0 ? AppColors.themeColor : Colors.grey),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.explore,
                color: currentIndex == 1 ? AppColors.themeColor : Colors.grey,
              ),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: currentIndex == 2 ? AppColors.themeColor : Colors.grey,
              ),
              label: "Favourites",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
                color: currentIndex == 3 ? AppColors.themeColor : Colors.grey,
              ),
              label: "Messages",
            ),
          ],
        ),
      ),
    );
  }
}
