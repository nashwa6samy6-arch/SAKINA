import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/local_services/ui/discover_services_screen.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// ---------------------------------------------------------------------------
// ServicesNearYouContainer
// Drop this anywhere in your widget tree.
// ---------------------------------------------------------------------------
class ServicesNearYouContainer extends StatelessWidget {
  const ServicesNearYouContainer({super.key});

  static const List<ServiceItem> _services = [
    ServiceItem(
      title: 'Laundry',
      subtitle: '4 available',
      icon: Icons.local_laundry_service_outlined,
    ),
    ServiceItem(
      title: 'Food',
      subtitle: 'Coming soon',
      icon: Icons.restaurant_outlined,
    ),
    ServiceItem(
      title: 'Maintenance',
      subtitle: 'Coming soon',
      icon: Icons.build_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      color: AppColors.themeColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services Near You',
                style: TextStyle(
                  color: const Color(0xFF120A00),
                  fontSize: 24.sp,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                  letterSpacing: -0.60,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiscoverServicesScreen(),
                    ),
                  );
                },
                child: Text(
                  'SEE ALL',
                  style: TextStyle(
                    color: const Color(0xFF4C463C),
                    fontSize: 12.sp,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // ── Horizontally scrollable cards ────────────────────────────────
          SizedBox(
            height: 220.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _services.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: 8.w), //change the space between the cards
              itemBuilder: (context, index) =>
                  _ServiceCard(service: _services[index]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private card widget
// ---------------------------------------------------------------------------
class _ServiceCard extends StatefulWidget {
  final ServiceItem service;
  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.95,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  bool get _isAvailable =>
      !widget.service.subtitle.toLowerCase().contains('coming');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DiscoverServicesScreen(),
          ),
        );
      },
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 160.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beige icon tile
              AspectRatio(
                aspectRatio: 160 / 150,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBeig,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Center(
                    child: Icon(
                      widget.service.icon,
                      size: 38.r,
                      color: const Color(0xFF3B2E1E),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Title
              Text(
                widget.service.title,
                style: TextStyle(
                  color: const Color(0xFF120A00),
                  fontSize: 14.sp,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),

              SizedBox(height: 2.h),

              // Subtitle
              Text(
                widget.service.subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  color: _isAvailable
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF4C463C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
