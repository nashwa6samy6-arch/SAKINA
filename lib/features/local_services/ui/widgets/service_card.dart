import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/local_services/ui/widgets/service_model.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String rating;
  final String distance;
  final String imageUrl;
  final String? tag;
  final String? priceRange;
  final ServiceCategory category;

  final dynamic onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    this.tag,
    this.priceRange,
    this.onTap,
    this.category = ServiceCategory.all,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                if (tag != null)
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.fontColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Text(
                        tag!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.fontColor,
                          fontSize: 20.sp,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7E0B6),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              size: 12.sp, color: const Color(0xFF251A02)),
                          SizedBox(width: 4.w),
                          Text(
                            rating,
                            style: TextStyle(
                              color: const Color(0xFF251A02),
                              fontSize: 12.sp,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    color: const Color(0xFF4C463C),
                    fontSize: 14.sp,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14.sp, color: const Color(0xB24C463C)),
                        SizedBox(width: 4.w),
                        Column(
                          children: [
                            Text(
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              distance,
                              style: TextStyle(
                                color: const Color(0xB24C463C),
                                fontSize: 12.sp,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (category == ServiceCategory.laundry &&
                    priceRange != null) ...[
                  SizedBox(height: 24.h),
                  Text(
                    priceRange!,
                    style: TextStyle(
                      color: const Color(0xFF2C2005),
                      fontSize: 18.sp,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else if (priceRange != null ||
                    category == ServiceCategory.maintenance ||
                    category == ServiceCategory.food) ...[
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: // لو الكاتيجوري laundry هنعرض السعر كتكست، غير كدة هنعرض الزرار
                        category == ServiceCategory.laundry
                            ? Center(
                                child: Text(
                                  priceRange ??
                                      '', // هيعرض السعر اللي جاي من الموديل
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                    color: const Color(
                                        0xFF2C2005), // نفس لون الزرار عشان التناسق
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: onTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C2005),
                                  foregroundColor: const Color(0xFFF7E0B6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      category == ServiceCategory.maintenance
                                          ? 'REQUEST QUOTE'
                                          : (category == ServiceCategory.food
                                              ? 'DETAILS'
                                              : (priceRange ?? 'DETAILS')),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(Icons.arrow_forward, size: 16.sp),
                                  ],
                                ),
                              ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
