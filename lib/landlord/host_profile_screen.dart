import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
import 'edit_profile_screen.dart';
import 'listing_details_screen.dart';
import 'package:sakina/features/notifications/notifications_screen.dart';
import 'screen/premium_screen.dart';

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
            : Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          // Bell
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: card,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.notifications_outlined,
                                      color: brown,
                                      size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Profile Photo
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: card,
                                shape: BoxShape.circle,
                                border: Border.all(color: border, width: 3),
                              ),
                              child: ClipOval(
                                child:
                                    _avatarUrl != null && _avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            _avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person,
                                                    size: 50, color: muted),
                                          )
                                        : const Icon(Icons.person,
                                            size: 50, color: muted),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Name
                          Text(
                            _fullName,
                            style: const TextStyle(
                              fontSize: 30,
                              height: 1.0,
                              fontWeight: FontWeight.w800,
                              color: brown,
                              letterSpacing: -1.2,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Email
                          Text(
                            _email,
                            style: const TextStyle(
                                fontSize: 13,
                                color: muted,
                                fontWeight: FontWeight.w400),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 15, color: muted),
                              const SizedBox(width: 4),
                              const Text('Cairo, Egypt',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: muted,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 10),
                              const Text(' | ',
                                  style: TextStyle(color: Color(0xFFB8B1A7))),
                              const SizedBox(width: 10),
                              Text(
                                'Member since $_memberSince',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: muted,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: brown,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            size: 18, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Edit Profile',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: card,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.headset_mic_outlined,
                                          size: 18, color: brown),
                                      SizedBox(width: 8),
                                      Text('Contact Support',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: brown)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  label: 'PROPERTIES',
                                  value: _listings.length.toString(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  label: 'RESPONSE RATE',
                                  value: _responseRate,
                                ),
                              ),
                              const SizedBox(width: 12),
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
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: card,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.star,
                                      color: Color(0xFFD4A017), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _rating > 0
                                      ? _rating.toStringAsFixed(1)
                                      : 'No ratings yet',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: brown,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _reviews.isNotEmpty
                                      ? '(${_reviews.length} reviews)'
                                      : '',
                                  style: const TextStyle(
                                      fontSize: 13, color: muted),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // About Me
                          const Text(
                            'About Me',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: brown,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _bio,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.75,
                              color: Color(0xFF59534D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Host Badges
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                            decoration: BoxDecoration(
                              color: softCard,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HOST BADGES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7A746C),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 12),
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

                          const SizedBox(height: 18),
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
                                width: 292,
                                height: 53.10,
                                padding:
                                    const EdgeInsets.only(top: 17.10, bottom: 16),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF2B1F04) /* button */,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium_outlined,
                                      color: accent,
                                      size: 18,
                                    ),
                                    Text(
                                      'Add Premium Subscription',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 14,
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
                          const SizedBox(height: 18),

                          // All Properties
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'All Properties',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: brown,
                                ),
                              ),
                              Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF746A5F),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Dynamic Listings
                          _listings.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('No listings yet',
                                        style: TextStyle(color: muted)),
                                  ),
                                )
                              : Column(
                                  children: _listings.map((listing) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child:
                                          _buildPropertyCard(context, listing),
                                    );
                                  }).toList(),
                                ),

                          // === REVIEWS SECTION (after listings) ===
                          if (_reviews.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            const Text(
                              'Host Ratings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: brown,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._reviews
                                .take(3)
                                .map((review) => _buildReviewItem(review)),
                            if (_reviews.length > 3) ...[
                              const SizedBox(height: 12),
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
                                  child: const Text(
                                    'See all reviews →',
                                    style: TextStyle(
                                      color: Color(0xFF746A5F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: brown)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: muted,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: brown)),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: listing['image_url'] != null &&
                      listing['image_url'].toString().isNotEmpty
                  ? Image.network(
                      listing['image_url'],
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        color: const Color(0xFFE0D8CC),
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    )
                  : Container(
                      height: 140,
                      color: const Color(0xFFE0D8CC),
                      child: const Center(child: Icon(Icons.image, size: 40)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing['title'] ?? '',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: brown)),
                  const SizedBox(height: 4),
                  Text(listing['description'] ?? '',
                      style: const TextStyle(fontSize: 12, color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EGP ${listing['rent_price']}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: brown),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: softCard,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          listing['status'] ?? '',
                          style: const TextStyle(
                              fontSize: 10,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: softCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: card,
                    shape: BoxShape.circle,
                    border: Border.all(color: border),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 20, color: muted),
                  ),
                ),
                const SizedBox(width: 10),
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
                            size: 14,
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
                  style: const TextStyle(
                      fontSize: 10, color: muted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (review['comment'] != null &&
                review['comment'].toString().isNotEmpty)
              const SizedBox(height: 10),
            if (review['comment'] != null &&
                review['comment'].toString().isNotEmpty)
              Text(
                review['comment'],
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF59534D),
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
      height: 70,
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
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, letterSpacing: 0.04)),
      ],
    );
  }
}
