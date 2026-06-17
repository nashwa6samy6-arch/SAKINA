import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/features/listings/bloc/listings_bloc.dart';
import 'package:sakina/features/listings/bloc/listings_event.dart';
import 'package:sakina/features/listings/bloc/listings_state.dart';
import 'package:sakina/features/listings/models/listing_model.dart';
import 'package:sakina/features/listings/listings_details/listings_details.dart';
class PropertyListingScreen extends StatefulWidget {
  const PropertyListingScreen({super.key});

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  int _selectedTab = 0;
  final tabs = ['Apartment', 'Room'];

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, state) {
        if (state is ListingsLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.w),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (state is ListingsError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (state is ListingsLoaded) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 750),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTabBar(context),
                      SizedBox(height: 20.h),
                      state.listings.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(20.w),
                              child: const Text('No listings available'),
                            )
                          : SizedBox(
                              height: 300.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(left: 20.w, right: 8.w),
                                itemCount: state.listings.length,
                                itemBuilder: (context, index) {
                                  return _buildFeaturedCard(state.listings[index]);
                                },
                              ),
                            ),
                      SizedBox(height: 28.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          'Property Nearby',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: state.listings.length,
                        itemBuilder: (context, index) {
                          return _buildNearbyCard(state.listings[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: EdgeInsets.only(right: index < tabs.length - 1 ? 12.w : 0),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = index);
                context.read<ListingsBloc>().add(
                      LoadListingsByType(index == 0 ? 'apartment' : 'room'),
                    );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.grey.shade800
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _openListingDetails(ListingModel listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailScreen(
          listing: listing,
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(ListingModel listing) {
    return GestureDetector(
      onTap: () {
        _openListingDetails(listing);
      },
      child: Container(
        width: 230.w,
        margin: EdgeInsets.only(right: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              listing.coverImage != null
                  ? Image.network(
                      listing.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.apartment,
                          size: 60.r,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.apartment,
                        size: 60.r,
                        color: Colors.white,
                      ),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 14.h,
                left: 14.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.threesixty, color: Colors.white, size: 12.r),
                      SizedBox(width: 4.w),
                      Text(
                        '360 view',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14.h,
                right: 14.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${listing.priceDisplay}/mo',
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                ),
              ),
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: 14.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (listing.locationDisplay.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.r,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              listing.locationDisplay,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 8.h),
                    Text(
                      'View details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyCard(ListingModel listing) {
    return GestureDetector(
        onTap: () {
          _openListingDetails(listing);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: listing.coverImage != null
                    ? Image.network(
                        listing.coverImage!,
                        width: 70.r,
                        height: 65.r,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70.r,
                          height: 65.r,
                          color: Colors.grey.shade200,
                          child:
                              Icon(Icons.apartment, color: Colors.grey, size: 30.r),
                        ),
                      )
                    : Container(
                        width: 70.r,
                        height: 65.r,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.apartment, color: Colors.grey, size: 30.r),
                      ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${listing.priceDisplay}/mo',
                      style:
                          TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                    ),
                    if (listing.locationDisplay.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.r,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              listing.locationDisplay,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (listing.nearbyUniversities != null &&
                        listing.nearbyUniversities!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 12.r,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              listing.nearbyUniversities!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 6.h),
                    Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.threesixty,
                          size: 13.r,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '360 view',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey, size: 24.r),
            ],
          ),
        ));
  }
}
