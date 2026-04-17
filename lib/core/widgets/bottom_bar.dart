import 'package:sakina/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/pages/explore.dart';
import 'package:sakina/pages/favourite.dart';
import 'package:sakina/pages/home.dart';
import 'package:sakina/pages/messages.dart';
import 'package:sakina/features/home/bloc/home_bloc.dart';

class ButtomNavBarScreen extends StatefulWidget {
  const ButtomNavBarScreen({super.key});

  @override
  State<ButtomNavBarScreen> createState() => _ButtomNavBarScreenState();
}

class _ButtomNavBarScreenState extends State<ButtomNavBarScreen> {
  int activeindex = 0;

  List<Widget> screens = [
    BlocProvider(
      create: (context) => HomeBloc(),
      child: const HomePage(),
    ),
    const ExplorePage(),
    const FavouritePage(),
    const MessagesPage(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: AppColors.bottomNavigationBarColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: BottomNavigationBar(
          backgroundColor: AppColors.bottomNavigationBarColor,
          elevation: 0,
          unselectedItemColor: Colors.white,
          currentIndex: activeindex,
          onTap: (index) {
            setState(() {
              activeindex = index;
            });
          },
          selectedItemColor: AppColors.themeColor,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: activeindex == 0 ? AppColors.themeColor : Colors.white,
              ),
              label: "Home",
              
              
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.explore,
                color: activeindex == 1 ? AppColors.themeColor : Colors.white,
              ),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: activeindex == 2 ? AppColors.themeColor : Colors.white,
              ),
              label: "Favourites",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
                color: activeindex == 3 ? AppColors.themeColor : Colors.white,
              ),
              label: "Messages",
            )
            
            
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SafeArea(child: screens[activeindex]),
      ),
    );
  }
}
