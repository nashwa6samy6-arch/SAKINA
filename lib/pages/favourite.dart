import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/listings/listings_details/listings_details.dart';
import 'package:sakina/features/listings/models/listing_model.dart';
import 'package:sakina/features/listings/repository/listings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final _supabase = Supabase.instance.client;
  final _repo = ListingsRepository();

  List<ListingModel> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() => _loading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) { setState(() => _loading = false); return; }

      final favs = await _supabase
          .from('favourites')
          .select('listing_id')
          .eq('user_id', userId);

      final ids = (favs as List)
          .whereType<Map<String, dynamic>>()
          .map((f) => f['listing_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final listings = <ListingModel>[];
      for (final id in ids) {
        try {
          final listing = await _repo.getListingById(id);
          listings.add(listing);
        } catch (_) {}
      }

      if (mounted) setState(() { _listings = listings; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeFavourite(String listingId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('favourites')
        .delete()
        .eq('user_id', userId)
        .eq('listing_id', listingId);
    setState(() => _listings.removeWhere((l) => l.listingId == listingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURATED COLLECTION',
                          style: TextStyle(
                            fontSize: 10.sp,
                            letterSpacing: 2.4,
                            color: Colors.brown.shade400,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Saved & Favorites',
                          style: TextStyle(
                            color: const Color(0xFF120A00),
                            fontSize: 32.sp,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            height: 1.20,
                            letterSpacing: -1.60,
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),

                if (_loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_listings.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64.r, color: Colors.brown.shade200),
                          SizedBox(height: 16.h),
                          Text(
                            'No saved listings yet',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: 'Manrope',
                              color: Colors.brown.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap the heart on any listing to save it here',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Manrope',
                              color: Colors.brown.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final listing = _listings[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: _ListingCard(
                              listing: listing,
                              onRemove: () => _removeFavourite(listing.listingId),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RoomDetailScreen(listing: listing),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _listings.length,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const _CompareFavoritesPromo(),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _ListingCard({
    required this.listing,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.galleryImages.isNotEmpty
        ? listing.galleryImages.first
        : null;
    final location = listing.address?.isNotEmpty == true
        ? listing.address!
        : listing.locationDisplay;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.08),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: AspectRatio(
                    aspectRatio: 1.8,
                    child: Container(
                      color: const Color(0xFF8AACB8),
                      child: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.home, size: 64.r, color: Colors.white30))
                          : Icon(Icons.home, size: 64.r, color: Colors.white30),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h, right: 12.w,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 36.r, height: 36.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8.r)],
                      ),
                      child: Icon(Icons.favorite, size: 18.r, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.title.isNotEmpty ? listing.title : 'Untitled',
                              style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C2218),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 12.r, color: Colors.brown.shade300),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    location.isNotEmpty ? location : 'Cairo, Egypt',
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12.sp, color: Colors.brown.shade400),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            listing.priceDisplay,
                            style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w800,
                              color: const Color(0xFF2C2218),
                            ),
                          ),
                          Text(
                            'per month',
                            style: TextStyle(fontSize: 10.sp, color: Colors.brown.shade400),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (listing.propertyType.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w, runSpacing: 6.h,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EDE4),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xFFD4C4A8), width: 0.8),
                          ),
                          child: Text(
                            listing.propertyTypeDisplay,
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF7A6550)),
                          ),
                        ),
                        if (listing.status == 'available')
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E8),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: const Color(0xFF8BC48A), width: 0.8),
                            ),
                            child: Text(
                              'Available',
                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF4A8A49)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareFavoritesPromo extends StatelessWidget {
  const _CompareFavoritesPromo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Container(
            padding: EdgeInsets.only(left: 20.w),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: const Color(0xFFF7E0B6), width: 3.w)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"Finding the right space is the first step toward building your sanctuary. These are the homes you\'ve felt a connection with."',
                  style: TextStyle(
                    color: const Color(0xFF2C2005), fontSize: 24.sp,
                    fontFamily: 'Manrope', fontWeight: FontWeight.w400, height: 1.30,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Container(width: 40.w, height: 2.h, color: const Color(0xFFDAC49B)),
                    SizedBox(width: 12.w),
                    Text('EDITORIAL NOTE',
                        style: TextStyle(color: const Color(0xFF4C463C), fontSize: 12.sp,
                            fontFamily: 'Manrope', fontWeight: FontWeight.w400, letterSpacing: 1.20)),
                  ],
                ),
              ],
            ),
          ),
        ),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(32.r),
          decoration: BoxDecoration(
            color: const Color(0xFF28200B),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compare your favorites',
                  style: TextStyle(color: Colors.white, fontSize: 20.sp,
                      fontFamily: 'Manrope', fontWeight: FontWeight.w400, height: 1.40)),
              SizedBox(height: 12.h),
              Text(
                'Analyze compatibility scores and utility splits side-by-side to make the final decision.',
                style: TextStyle(color: const Color(0xFF9A8762), fontSize: 14.sp,
                    fontFamily: 'Manrope', fontWeight: FontWeight.w400, height: 1.63),
              ),
              SizedBox(height: 28.h),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7E0B6),
                  foregroundColor: const Color(0xFF2C2218),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  elevation: 0,
                ),
                child: Text('Enter Compare Mode',
                    style: TextStyle(color: const Color(0xFF120A00), fontSize: 14.sp,
                        fontFamily: 'Manrope', fontWeight: FontWeight.w400, height: 1.25)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}