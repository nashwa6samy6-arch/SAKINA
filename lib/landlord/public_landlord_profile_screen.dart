import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PublicLandlordProfileScreen extends StatefulWidget {
  final String landlordId;

  const PublicLandlordProfileScreen({
    super.key,
    required this.landlordId,
  });

  @override
  State<PublicLandlordProfileScreen> createState() =>
      _PublicLandlordProfileScreenState();
}

class _PublicLandlordProfileScreenState
    extends State<PublicLandlordProfileScreen> {
  final supabase = Supabase.instance.client;

  static const Color bg = Color(0xFFF5F3EF);
  static const Color card = Color(0xFFEEE9DF);
  static const Color brown = Color(0xFF1B1209);
  static const Color muted = Color(0xFF7A746C);
  static const Color border = Color(0xFFE8E1D7);
  static const Color accent = Color(0xFFEFD9A7);

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _landlordData;
  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final id = widget.landlordId;

      final userResponse = await supabase
          .from('users')
          .select()
          .eq('user_id', id)
          .maybeSingle();

      Map<String, dynamic>? landlordResponse;
      try {
        landlordResponse = await supabase
            .from('landlord')
            .select()
            .eq('landlord_id', id)
            .maybeSingle();
      } catch (_) {}

      final listingsResponse = await supabase
          .from('property_listings')
          .select()
          .eq('landlord_id', id)
          .eq('status', 'available')
          .order('created_at', ascending: false);

      final reviewsResponse = await supabase
          .from('review')
          .select()
          .eq('landlord_id', id)
          .eq('is_flagged', false)
          .order('created_at', ascending: false);

      setState(() {
        _userData = userResponse;
        _landlordData = landlordResponse;
        _listings = List<Map<String, dynamic>>.from(listingsResponse);
        _reviews = List<Map<String, dynamic>>.from(reviewsResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String get _fullName =>
      _userData?['full_name'] ?? _landlordData?['name'] ?? 'Host';

  String? get _avatarUrl => _userData?['avatar_url'];

  String get _bio =>
      _userData?['bio'] ?? _landlordData?['about'] ?? 'No bio added yet.';

  String get _location =>
      _userData?['location'] ?? _landlordData?['location'] ?? 'Egypt';

  String get _memberSince {
    final raw = _userData?['created_at']?.toString();
    if (raw == null) return '—';
    try {
      final date = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '—';
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<double>(
      0,
      (sum, r) => sum + ((r['rating'] as num?)?.toDouble() ?? 0),
    );
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    children: [
                      // App bar
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40.r,
                                height: 40.r,
                                decoration: BoxDecoration(
                                  color: card,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(Icons.arrow_back_ios_new,
                                    color: brown, size: 18.r),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Host Profile',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: brown,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Center(
                                child: Container(
                                  width: 100.r,
                                  height: 100.r,
                                  decoration: BoxDecoration(
                                    color: card,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: border, width: 3.r),
                                  ),
                                  child: ClipOval(
                                    child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            _avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                                Icons.person, size: 50.r, color: muted),
                                          )
                                        : Icon(Icons.person, size: 50.r, color: muted),
                                  ),
                                ),
                              ),

                              SizedBox(height: 18.h),

                              // Name
                              Text(
                                _fullName,
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  height: 1.0,
                                  fontWeight: FontWeight.w800,
                                  color: brown,
                                  letterSpacing: -1.2,
                                  fontFamily: 'Manrope',
                                ),
                              ),

                              SizedBox(height: 10.h),

                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 15.r, color: muted),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _location,
                                    style: TextStyle(
                                        fontSize: 13.sp, color: muted,
                                        fontWeight: FontWeight.w500, fontFamily: 'Manrope'),
                                  ),
                                  SizedBox(width: 10.w),
                                  const Text(' | ', style: TextStyle(color: Color(0xFFB8B1A7))),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Member since $_memberSince',
                                    style: TextStyle(
                                        fontSize: 13.sp, color: muted,
                                        fontWeight: FontWeight.w500, fontFamily: 'Manrope'),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Stats
                              Row(
                                children: [
                                  Expanded(child: _buildStatCard(label: 'PROPERTIES', value: _listings.length.toString())),
                                  SizedBox(width: 12.w),
                                  Expanded(child: _buildStatCard(label: 'REVIEWS', value: _reviews.length.toString())),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'RATING',
                                      value: _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '—',
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12.h),

                              // Rating banner
                              if (_averageRating > 0)
                                Container(
                                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star_rounded, color: const Color(0xFFF5A623), size: 22.r),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          '${_averageRating.toStringAsFixed(1)} average rating from ${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                                          style: TextStyle(
                                            fontSize: 13.sp, fontWeight: FontWeight.w600,
                                            color: brown, fontFamily: 'Manrope',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(height: 20.h),

                              // Bio
                              Text('About',
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700,
                                      color: brown, fontFamily: 'Manrope')),
                              SizedBox(height: 8.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                    color: card, borderRadius: BorderRadius.circular(12.r)),
                                child: Text(
                                  _bio,
                                  style: TextStyle(
                                      fontSize: 14.sp, color: muted, height: 1.6, fontFamily: 'Manrope'),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Listings
                              if (_listings.isNotEmpty) ...[
                                Text('Active Listings',
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700,
                                        color: brown, fontFamily: 'Manrope')),
                                SizedBox(height: 12.h),
                                ..._listings.map((l) => _ListingTile(listing: l)),
                              ],

                              SizedBox(height: 24.h),

                              // Reviews
                              if (_reviews.isNotEmpty) ...[
                                Text('Reviews (${_reviews.length})',
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700,
                                        color: brown, fontFamily: 'Manrope')),
                                SizedBox(height: 12.h),
                                ..._reviews.take(5).map((r) => _ReviewTile(review: r)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800,
                  color: brown, fontFamily: 'Manrope')),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(fontSize: 10.sp, color: muted,
                  fontWeight: FontWeight.w500, letterSpacing: 0.5, fontFamily: 'Manrope')),
        ],
      ),
    );
  }
}

class _ListingTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _ListingTile({required this.listing});

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF1B1209);
    const muted = Color(0xFF7A746C);
    const card = Color(0xFFEEE9DF);

    final title = listing['title'] ?? 'Untitled';
    final price = listing['rent_price'];
    final type = listing['property_type'] ?? '';
    final imageUrl = listing['image_url']?.toString();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 60.w, height: 60.w,
              color: const Color(0xFFD8D0C0),
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.home, color: muted))
                  : const Icon(Icons.home, color: muted),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700,
                        color: brown, fontFamily: 'Manrope')),
                SizedBox(height: 4.h),
                Text(type.isNotEmpty ? type.replaceAll('_', ' ') : 'Property',
                    style: TextStyle(fontSize: 12.sp, color: muted, fontFamily: 'Manrope')),
              ],
            ),
          ),
          if (price != null)
            Text('EGP $price',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700,
                    color: brown, fontFamily: 'Manrope')),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF7A746C);
    const card = Color(0xFFEEE9DF);

    final comment = review['comment']?.toString() ?? '';
    final rating = (review['rating'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) => Icon(
              Icons.star_rounded, size: 16.r,
              color: i < rating.round() ? const Color(0xFFF5A623) : const Color(0xFFD8D0C0),
            )),
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(comment,
                style: TextStyle(fontSize: 13.sp, color: muted,
                    height: 1.5, fontFamily: 'Manrope')),
          ],
        ],
      ),
    );
  }
}