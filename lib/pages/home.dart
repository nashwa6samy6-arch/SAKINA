import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_app_bar.dart';
import 'package:sakina/features/ai_match/screens/loading_screen.dart';
import 'package:sakina/pages/widgets/services_near_you.dart';
import 'package:sakina/pages/widgets/top_match.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Myappbar(),
      backgroundColor: AppColors.primaryColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find your quiet in the chaos.',
                style: TextStyle(
                  color: const Color(0xFF120A00),
                  fontSize: 32,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1.60,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Curated roommate matches and premium living spaces across Egypt's academic districts.",
                style: TextStyle(
                  color: const Color(0xFF4C463C),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 24, width: 24),
              //------------------start----------------search bar and filter button----------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SearchBar(
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: const Icon(Icons.search),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hintText: 'Search by area or university...',
                      onChanged: (value) {
                        // Handle search input changes
                      },
                    ),
                  ),
                  SizedBox(width: 24, height: 24),
                  IconButton(
                    padding: const EdgeInsets.all(20),
                    style: IconButton.styleFrom(
                      iconSize: 20,
                      backgroundColor: AppColors.bottomNavigationBarColor,
                      foregroundColor: AppColors.appbarColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Handle filter button press
                    },
                    icon: SvgPicture.asset("assets/icons/filtericon.svg"),
                  ),
                ],
              ),

              //------------------end----------------search bar and filter button----------------------------------
              //------------------start----------------container for AI smart match----------------------------------
              SizedBox(height: 24, width: 24),
              Container(
                // height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primaryBeig,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Robot icon with sparkles
                    SizedBox(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            'assets/pictures/AI_Cute.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                    // Text content + button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          // Label
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: const Text(
                              'AI Smart Match',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Manrope',
                                color: Color(0xFF4D4634),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Bold headline
                          const Text(
                            'Let AI find your perfect room.',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF120A00),
                              height: 1.80,
                              letterSpacing: -1.60,
                            ),
                          ),

                          // Subtext
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: const Text(
                              'Personalized matches tailored to your lifestyle and budget.',
                              style: TextStyle(
                                color: Color(0xFF4C463C),
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                                // height: 1.63,
                              ),
                            ),
                          ),

                          // CTA Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 12.0,
                            ),
                            child: SizedBox(
                              width: 170,
                              height: 35,
                              child: ElevatedButton(
                                // ------------------------on pressed button of AI smart match is here------------------------
                                onPressed: () {
                                  // Navigate to the loading screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoadingScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.bottomNavigationBarColor,
                                  foregroundColor: AppColors.primaryBeig,
                                  // padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Find my match',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                    height: 1.71,
                                    letterSpacing: 0.40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //------------------end----------------container for AI smart match----------------------------------
              //------------------start----------------container ( Browse Nearby )----------------------------------
              SizedBox(height: 24, width: 24),
              Container(
                color: AppColors.themeColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Browse Nearby',
                          style: TextStyle(
                            color: Color(0xFF120A00),
                            fontSize: 24,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                            letterSpacing: -0.60,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {}, // WHEN CLICK ON VIEW MAP
                          child: Text(
                            'VIEW MAP',
                            style: TextStyle(
                              color: const Color(0xFF4C463C),
                              fontSize: 12,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                              letterSpacing: 1.20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Main card with background image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        height: 190.38,
                        child: Stack(
                          children: [
                            // Background room image
                            Positioned.fill(
                              child: Image.asset(
                                'assets/pictures/room.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Dark overlay (subtle)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Match badge
                            Align(
                              alignment: const Alignment(
                                0,
                                -0.5,
                              ), // centered, slightly above middle
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C1C1C),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '98% Match',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w400,
                                        height: 1.33,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // Handle card tap (navigate to details)
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          'assets/pictures/room.jpg',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Premium Studio, Maadi',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1C1C1C),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Color(0xFF888888),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  '0.8km away',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF888888),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFF1C1C1C),
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //------------------end----------------container ( Browse Nearby )----------------------------------
              
              TopMatch(), //----------------TOP MATCH FUNCTION in a separate widget------------------

              SizedBox(height: 24, width: 24),

              ServicesNearYouContainer() // SERVICES NEAR YOU FUNCTION in a separate widget

             


            ],
          ),
        ),
      ),
    );
  }
}

