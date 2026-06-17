import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
import 'edit_profile_screen.dart';
import 'listing_details_screen.dart';
import 'package:sakina/features/notifications/notifications_screen.dart';
import 'screen/premium_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HostProfileScreen extends StatefulWidget {
  const HostProfileScreen({super.key});

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  final supabase = Supabase.instance.client;

  static const Color bg = Color(0xFFF5F3EF);
  static const Color card = Color(0xFFEEE9DF);
  static const Color softCard = Color(0xFFF0EBE2);
  static const Color brown = Color(0xFF1B1209);
  static const Color muted = Color(0xFF7A746C);
  static const Color border = Color(0xFFE8E1D7);
  static const Color accent = Color(0xFFEFD9A7);

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _landlordData;
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _reviews = [];
  String _responseRate = '--'; // Changed from static getter

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final userResponse = await supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final landlordResponse = await supabase
          .from('landlord')
          .select()
          .eq('landlord_id', userId)
          .maybeSingle();

      final listingsResponse = await supabase
          .from('property_listings')
          .select()
          .eq('landlord_id', userId)
          .order('created_at', ascending: false);

      final reviewsResponse = await supabase
          .from('review')
          .select()
          .eq('landlord_id', userId)
          .eq('is_flagged', false)
          .order('created_at', ascending: false);

      setState(() {
        _userData = userResponse;
        _landlordData = landlordResponse;
        _listings = List<Map<String, dynamic>>.from(listingsResponse);
        _reviews = List<Map<String, dynamic>>.from(reviewsResponse);
      });

      // Fetch dynamic response rate
      await _fetchResponseRate();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchResponseRate() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Get all conversation IDs where the host is the owner
      final conversations = await supabase
          .from('conversation')
          .select('conversation_id')
          .eq('user_id', userId);

      if (conversations.isEmpty) {
        setState(() => _responseRate = '0%');
        return;
      }

      final List<dynamic> conversationIds =
          conversations.map((c) => c['conversation_id']).toList();

      // 2. Get all messages for those conversations
      final messagesResponse = await supabase
          .from('messages')
          .select('conversation_id, sender_id')
          .inFilter('conversation_id', conversationIds);

      // 3. Group by conversation_id and collect unique sender_ids
      final Map<String, Set<String>> conversationSenders = {};
      for (var msg in messagesResponse) {
        final convId = msg['conversation_id'] as String;
        final senderId = msg['sender_id'] as String;
        conversationSenders.putIfAbsent(convId, () => {}).add(senderId);
      }

      int totalConversations = conversationIds.length;
      int hostRepliedConversations = 0;

      for (var senders in conversationSenders.values) {
        if (senders.contains(userId)) {
          hostRepliedConversations++;
        }
      }

      int rate = totalConversations == 0
          ? 0
          : (hostRepliedConversations / totalConversations * 100).round();
      setState(() {
        _responseRate = '$rate%';
      });
    } catch (e) {
      setState(() => _responseRate = '0%');
    }
  }

  String get _fullName =>
      _userData?['full_name'] ??
      supabase.auth.currentUser?.userMetadata?['full_name'] ??
      supabase.auth.currentUser?.email?.split('@')[0] ??
      'User';

  String get _email =>
      _userData?['email'] ?? supabase.auth.currentUser?.email ?? '';

  String get _bio => _userData?['bio'] ?? 'No bio yet.';

  double get _rating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<double>(
        0.0, (sum, r) => sum + (r['rating'] as num).toDouble());
    return total / _reviews.length;
  }

  String? get _avatarUrl => _userData?['avatar_url'];

  String get _memberSince =>
      supabase.auth.currentUser?.createdAt.substring(0, 4) ?? '2024';

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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 110.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6.h),

                              // Bell
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const NotificationsScreen()),
                                      );
                                    },
                                    child: Container(
                                      width: 40.r,
                                      height: 40.r,
                                      decoration: BoxDecoration(
                                        color: card,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Icon(
                                          Icons.notifications_outlined,
                                          color: brown,
                                          size: 20.r),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // Profile Photo
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
                                    child:
                                        _avatarUrl != null && _avatarUrl!.isNotEmpty
                                            ? Image.network(
                                                _avatarUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(Icons.person,
                                                        size: 50.r, color: muted),
                                              )
                                            : Icon(Icons.person,
                                                size: 50.r, color: muted),
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
                                ),
                              ),

                              SizedBox(height: 6.h),

                              // Email
                              Text(
                                _email,
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: muted,
                                    fontWeight: FontWeight.w400),
                              ),

                              SizedBox(height: 10.h),

                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 15.r, color: muted),
                                  SizedBox(width: 4.w),
                                  Text('Cairo, Egypt',
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: muted,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(width: 10.w),
                                  const Text(' | ',
                                      style: TextStyle(color: Color(0xFFB8B1A7))),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Member since $_memberSince',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: muted,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),

                              SizedBox(height: 18.h),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditProfileScreen(
                                              fullName: _fullName,
                                              bio: _bio,
                                              avatarUrl: _avatarUrl,
                                            ),
                                          ),
                                        );
                                        _loadData();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14.h),
                                        decoration: BoxDecoration(
                                          color: brown,
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit_outlined,
                                                size: 18.r, color: Colors.white),
                                            SizedBox(width: 8.w),
                                            Text('Edit Profile',
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14.h),
                                      decoration: BoxDecoration(
                                        color: card,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.headset_mic_outlined,
                                              size: 18.r, color: brown),
                                          SizedBox(width: 8.w),
                                          Text('Contact Support',
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: brown)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Stats
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'PROPERTIES',
                                      value: _listings.length.toString(),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'RESPONSE RATE',
                                      value: _responseRate,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'REVIEWS',
                                      value: _reviews.length.toString(),
                                    ),
                                  ),
                                ],
                              ),
                          const SizedBox(height: 12),

                          // Rating
                          Container(
                            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: card,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(Icons.star,
                                      color: const Color(0xFFD4A017), size: 20.r),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  _rating > 0
                                      ? _rating.toStringAsFixed(1)
                                      : 'No ratings yet',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w800,
                                    color: brown,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _reviews.isNotEmpty
                                      ? '(${_reviews.length} reviews)'
                                      : '',
                                  style: TextStyle(
                                      fontSize: 13.sp, color: muted),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 22.h),

                          // About Me
                          Text(
                            'About Me',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: brown,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _bio,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.75,
                              color: const Color(0xFF59534D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 28.h),

                          // Host Badges
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
                            decoration: BoxDecoration(
                              color: softCard,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HOST BADGES',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF7A746C),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildBadge('Fast Responder'),
                                    if (_userData?['is_verified'] == true)
                                      _buildBadge('Identity Verified'),
                                    _buildBadge('Safe Space Host'),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 18.h),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PremiumScreen(landlordId: '',),
                                  ),
                                );
                              },
                              child: Container(
                                width: 292.w,
                                height: 54.h,
                                padding:
                                    EdgeInsets.only(top: 17.h, bottom: 16.h),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF2B1F04) /* button */,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium_outlined,
                                      color: accent,
                                      size: 18.r,
                                    ),
                                    Text(
                                      'Add Premium Subscription',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 14.sp,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                        letterSpacing: 0.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),

                          // All Properties
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'All Properties',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: brown,
                                ),
                              ),
                              Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF746A5F),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Dynamic Listings
                          _listings.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.r),
                                    child: const Text('No listings yet',
                                        style: TextStyle(color: muted)),
                                  ),
                                )
                              : Column(
                                  children: _listings.map((listing) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 12.h),
                                      child:
                                          _buildPropertyCard(context, listing),
                                    );
                                  }).toList(),
                                ),

                          // === REVIEWS SECTION (after listings) ===
                          if (_reviews.isNotEmpty) ...[
                            SizedBox(height: 28.h),
                            Text(
                              'Host Ratings',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: brown,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ..._reviews
                                .take(3)
                                .map((review) => _buildReviewItem(review)),
                            if (_reviews.length > 3) ...[
                              SizedBox(height: 12.h),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to full reviews screen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'All reviews screen coming soon')),
                                    );
                                  },
                                  child: Text(
                                    'See all reviews →',
                                    style: TextStyle(
                                      color: const Color(0xFF746A5F),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],

                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),),
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _buildBottomNav(context),
        ),
      ),
    );
  }
  

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24.sp, fontWeight: FontWeight.w800, color: brown)),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: muted,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12.sp, fontWeight: FontWeight.w500, color: brown)),
    );
  }

  Widget _buildPropertyCard(
      BuildContext context, Map<String, dynamic> listing) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingDetailsScreen(
            listingId: listing['listing_id'],
            title: listing['title'] ?? '',
            location: listing['description'] ?? '',
            price: listing['rent_price'].toString(),
            beds: '${listing['available_rooms']} rooms',
            tag: listing['status'] ?? '',
            imageUrl: listing['image_url'] ?? '',
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12.r)),
              child: listing['image_url'] != null &&
                      listing['image_url'].toString().isNotEmpty
                  ? Image.network(
                      listing['image_url'],
                      height: 140.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140.h,
                        color: const Color(0xFFE0D8CC),
                        child: Center(child: Icon(Icons.image, size: 40.r)),
                      ),
                    )
                  : Container(
                      height: 140.h,
                      color: const Color(0xFFE0D8CC),
                      child: Center(child: Icon(Icons.image, size: 40.r)),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing['title'] ?? '',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: brown)),
                  SizedBox(height: 4.h),
                  Text(listing['description'] ?? '',
                      style: TextStyle(fontSize: 12.sp, color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EGP ${listing['rent_price']}',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: brown),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: softCard,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          listing['status'] ?? '',
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: brown),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: softCard,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: card,
                    shape: BoxShape.circle,
                    border: Border.all(color: border),
                  ),
                  child: Icon(Icons.person, size: 20.r, color: muted),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < (review['rating'] as num).toInt()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14.r,
                            color: const Color(0xFFD4A017),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  review['created_at'] != null
                      ? review['created_at'].toString().substring(0, 10)
                      : 'No date',
                  style: TextStyle(
                      fontSize: 10.sp, color: muted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (review['comment'] != null &&
                review['comment'].toString().isNotEmpty)
              SizedBox(height: 10.h),
            if (review['comment'] != null &&
                review['comment'].toString().isNotEmpty)
              Text(
                review['comment'],
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: const Color(0xFF59534D),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: const BoxDecoration(
        color: brown,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            ),
            child: const _NavItem(
                icon: Icons.grid_view, label: 'DASHBOARD', active: false),
          ),
          const _NavItem(
              icon: Icons.chat_bubble_outline,
              label: 'MESSAGES',
              active: false),
          const _NavItem(icon: Icons.person, label: 'PROFILE', active: true),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem(
      {required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 22.r),
        SizedBox(height: 4.h),
        Text(label,
            style: TextStyle(
                color: Colors.white, fontSize: 10.sp, letterSpacing: 0.04)),
      ],
    );
  }
}
