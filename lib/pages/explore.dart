import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/listings/bloc/listings_bloc.dart';
import 'package:sakina/features/listings/bloc/listings_event.dart';
import 'package:sakina/features/listings/repository/listings_repository.dart';
import 'package:sakina/pages/widgets/property_list.dart';
import 'package:sakina/features/map/screens/map_screen.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  late ListingsBloc _listingsBloc;

  @override
  void initState() {
    super.initState();
    _listingsBloc = ListingsBloc(ListingsRepository())..add(LoadListings());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _listingsBloc,
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Container(
                margin: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover\nyour new house!',
                      style: TextStyle(
                        color: const Color(0xFF120A00),
                        fontSize: 30.sp,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Search bar + filter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SearchBar(
                            controller: _searchController,
                            leading: Padding(
                              padding: EdgeInsets.only(left: 8.0.w),
                              child: Icon(Icons.search, size: 20.r),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                            ),
                            hintText: 'Search by area, title...',
                            onChanged: (value) {
                              if (value.length > 2) {
                                _listingsBloc.add(SearchListings(value));
                              } else if (value.isEmpty) {
                                _listingsBloc.add(LoadListings());
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        IconButton(
                          padding: EdgeInsets.all(20.r),
                          style: IconButton.styleFrom(
                            iconSize: 20.r,
                            backgroundColor: AppColors.bottomNavigationBarColor,
                            foregroundColor: AppColors.appbarColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () {
                            _showFilterSheet(context);
                          },
                          icon: SvgPicture.asset("assets/icons/filtericon.svg"),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Map section
                    _buildMapSection(context),

                    SizedBox(height: 24.h),

                    // Listings
                    const PropertyListingScreen(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Browse by Area',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.4,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to full map screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapSearchScreen(),
                  ),
                );
              },
              child: Text(
                'View Map',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF888880),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Mini map preview — tap to open full map
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MapSearchScreen(),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final W = constraints.maxWidth;
                return SizedBox(
                  width: double.infinity,
                  height: 180.h,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _MiniMapPainter(),
                        size: Size(W, 180.h),
                        child: const SizedBox.expand(),
                      ),
                      Positioned(
                        top: 52.h,
                        left: W * 0.18,
                        child: const _MapPin(label: 'Maadi', isDark: true),
                      ),
                      Positioned(
                        top: 108.h,
                        left: W * 0.42,
                        child: const _MapPin(label: 'Zamalek', isDark: false),
                      ),
                      // Tap overlay hint
                      Positioned(
                        bottom: 12.h,
                        right: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1C),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_outlined,
                                  color: Colors.white, size: 14.r),
                              SizedBox(width: 6.w),
                              Text(
                                'Open Map',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    String selectedType = 'All';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Type',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                ),
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 10.w,
                children: ['All', 'apartment', 'room', 'studio'].map((type) {
                  final isSelected = selectedType == type;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => selectedType = type);
                      if (type == 'All') {
                        _listingsBloc.add(LoadListings());
                      } else {
                        _listingsBloc.add(LoadListingsByType(type));
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFF2F0EB),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        type[0].toUpperCase() + type.substring(1),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Mini map painter
class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, W, H),
      Paint()..color = const Color(0xFFDDD9CF),
    );

    final block = Paint()..color = const Color(0xFFC8C4B8);

    void drawBlock(double x, double y, double w, double h) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(3)),
        block,
      );
    }

    drawBlock(W * 0.01, H * 0.03, W * 0.17, H * 0.25);
    drawBlock(W * 0.22, H * 0.03, W * 0.14, H * 0.23);
    drawBlock(W * 0.40, H * 0.02, W * 0.18, H * 0.26);
    drawBlock(W * 0.62, H * 0.03, W * 0.15, H * 0.24);
    drawBlock(W * 0.81, H * 0.02, W * 0.18, H * 0.26);
    drawBlock(W * 0.01, H * 0.36, W * 0.12, H * 0.27);
    drawBlock(W * 0.16, H * 0.35, W * 0.19, H * 0.26);
    drawBlock(W * 0.40, H * 0.36, W * 0.16, H * 0.27);
    drawBlock(W * 0.62, H * 0.35, W * 0.14, H * 0.28);
    drawBlock(W * 0.81, H * 0.36, W * 0.18, H * 0.27);

    final road = Paint()
      ..color = const Color(0xFFECE8DF)
      ..strokeWidth = W * 0.012
      ..style = PaintingStyle.stroke;

    for (final y in [0.31, 0.65]) {
      canvas.drawLine(Offset(0, H * y), Offset(W, H * y), road);
    }
    for (final x in [0.14, 0.38, 0.60, 0.80]) {
      canvas.drawLine(Offset(W * x, 0), Offset(W * x, H), road);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MapPin extends StatelessWidget {
  final String label;
  final bool isDark;
  const _MapPin({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on,
              size: 13.r, color: isDark ? Colors.white : const Color(0xFF1C1C1C)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1C1C1C),
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }
}
