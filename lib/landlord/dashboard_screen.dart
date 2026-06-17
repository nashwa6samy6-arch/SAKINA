import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_listing_screen.dart';
import 'listing_details_screen.dart';
import 'host_profile_screen.dart';
import 'package:sakina/features/notifications/notifications_screen.dart';
import 'package:sakina/pages/messages/chat_screen/messages.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  String? _avatarUrl;
  List<Map<String, dynamic>> _pendingBookings = [];

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    try {
      final landlordId = supabase.auth.currentUser?.id;

      // جيب صورة الـ user
      final userResponse = await supabase
          .from('users')
          .select('avatar_url')
          .eq('user_id', landlordId!)
          .maybeSingle();

      final response = await supabase
          .from('property_listings')
          .select()
          .eq('landlord_id', landlordId)
          .order('created_at', ascending: false);

      final bookingsResponse = await supabase
          .from('bookings')
          .select('booking_id, tenant_id, listing_id, payment_method, created_at')
          .eq('landlord_id', landlordId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        _avatarUrl = userResponse?['avatar_url'];
        _listings = List<Map<String, dynamic>>.from(response);
        _pendingBookings = List<Map<String, dynamic>>.from(bookingsResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    await supabase.from('bookings').update({'status': status}).eq('booking_id', bookingId);
    _loadListings();
  }

  String get _userName =>
      supabase.auth.currentUser?.userMetadata?['full_name'] ??
      supabase.auth.currentUser?.userMetadata?['name'] ??
      supabase.auth.currentUser?.email?.split('@')[0] ??
      'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5EFE6),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _scaffoldKey.currentState?.openDrawer(), // ← ده المهم
                        child: Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A0F0A),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? Image.network(
                                    _avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20.r),
                                  )
                                : Icon(Icons.person,
                                    color: Colors.white, size: 20.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        _userName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Manrope",
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen()),
                          );
                        },
                        child: Icon(Icons.notifications_none, size: 24.r),
                      ),
                    ],
                  ),
                ),

                // GREETING
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WELCOME BACK",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey,
                            letterSpacing: 1,
                            fontFamily: "Manrope",
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Hello,\n$_userName.",
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Manrope",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // STATS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.home_work_outlined,
                          number: _listings.length.toString(),
                          label: "Total Listings",
                          bg: Colors.white,
                          textColor: const Color(0xFF1A0F0A),
                          iconColor: const Color(0xFF1A0F0A),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      const Expanded(
                        child: StatCard(
                          icon: Icons.group_outlined,
                          number: "0",
                          label: "Active Tenants",
                          bg: Color(0xFF1A0F0A),
                          textColor: Colors.white,
                          iconColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: StatCard(
                          icon: Icons.assignment_outlined,
                          number: _pendingBookings.length.toString(),
                          label: "Pending Requests",
                          bg: const Color(0xFFEDE8E0),
                          textColor: const Color(0xFF1A0F0A),
                          iconColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // TITLE
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Listings",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Manrope",
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            height: 3.h,
                            width: 40.w,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(color: Color(0xFF1A0F0A)),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        "Manage all →",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.sp,
                          fontFamily: "Manrope",
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // LISTINGS
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _listings.isEmpty
                          ? Center(
                              child: Text(
                                'No listings yet.\nTap + to add your first listing!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "Manrope",
                                  fontSize: 14.sp,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadListings,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                itemCount: _listings.length,
                                itemBuilder: (context, index) {
                                  final listing = _listings[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ListingDetailsScreen(
                                              listingId: listing['listing_id'],
                                              title: listing['title'] ?? '',
                                              location:
                                                  listing['description'] ?? '',
                                              price:
                                                  listing['rent_price'].toString(),
                                              beds:
                                                  '${listing['available_rooms']} rooms',
                                              tag: listing['status'] ?? '',
                                              imageUrl: listing['image_url'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                      child: ListingCard(
                                        title: listing['title'] ?? '',
                                        location: listing['description'] ?? '',
                                        price: listing['rent_price'].toString(),
                                        beds: '${listing['available_rooms']} rooms',
                                        tag: listing['status'] ?? '',
                                        imageUrl: listing['image_url'] ?? '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A0F0A),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddListingScreen()),
          );
          // Refresh after adding
          _loadListings();
        },
        child: Icon(Icons.add, color: Colors.white, size: 24.r),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // BOTTOM NAV
      bottomNavigationBar: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F0A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NavItem(Icons.grid_view, "DASHBOARD", active: true),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ConversationsScreen()),
                    );
                  },
                  child:
                      NavItem(Icons.chat_bubble_outline, "MESSAGES", active: false),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HostProfileScreen()),
                  ),
                  child: NavItem(Icons.person_outline, "PROFILE", active: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF5EFE6),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: const Color(0xFF1A0F0A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pending Requests',
                      style: TextStyle(color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
                  const SizedBox(height: 4),
                  Text('${_pendingBookings.length} awaiting your response',
                      style: const TextStyle(color: Color(0xFFB0A090),
                          fontSize: 13, fontFamily: 'Manrope')),
                ],
              ),
            ),
            Expanded(
              child: _pendingBookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFB0A090)),
                          SizedBox(height: 12),
                          Text('No pending requests',
                              style: TextStyle(color: Color(0xFFB0A090),
                                  fontSize: 15, fontFamily: 'Manrope')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingBookings.length,
                      itemBuilder: (context, index) {
                        final b = _pendingBookings[index];
                        return _PendingCard(
                          booking: b,
                          onApprove: () {
                            Navigator.pop(context);
                            _updateBookingStatus(b['booking_id'], 'approved');
                          },
                          onReject: () {
                            Navigator.pop(context);
                            _updateBookingStatus(b['booking_id'], 'rejected');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final Color bg;
  final Color textColor;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.number,
    required this.label,
    required this.bg,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22.r),
          SizedBox(height: 10.h),
          Text(
            number,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "Manrope",
              color: textColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: "Manrope",
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  final String title, location, price, beds, tag, imageUrl;

  const ListingCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.beds,
    required this.tag,
    this.imageUrl = "",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: AspectRatio(
              aspectRatio: 1.8,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE0D8CC),
                        child: Center(child: Icon(Icons.image, size: 40.r)),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return  Container(
                          color: Color(0xFFE0D8CC),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFFE0D8CC),
                      child: Center(child: Icon(Icons.image, size: 40.r)),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          fontFamily: "Manrope",
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.sp,
                          fontFamily: "Manrope",
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(beds,
                              style: TextStyle(
                                  fontSize: 12.sp, fontFamily: "Manrope")),
                          if (tag.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0D8CC),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(tag,
                                  style: TextStyle(
                                      fontSize: 10.sp, fontFamily: "Manrope")),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0F0A),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "EGP $price",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontFamily: "Manrope",
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0F0A),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "View Details →",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontFamily: "Manrope",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem(this.icon, this.label, {super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 24.r),
        SizedBox(height: 4.h),
        Text(label,
            style: TextStyle(
                color: Colors.white, fontSize: 10.sp, fontFamily: "Manrope")),
      ],
    );
  }
}

class _PendingCard extends StatefulWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _PendingCard({required this.booking, required this.onApprove, required this.onReject});

  @override
  State<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends State<_PendingCard> {
  final _db = Supabase.instance.client;
  String _tenant = '';
  String _email = '';
  String _listing = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tenantId  = widget.booking['tenant_id'];
    final listingId = widget.booking['listing_id'];
    if (tenantId != null) {
      final t = await _db.from('users').select('full_name, email').eq('user_id', tenantId).maybeSingle();
      if (t != null && mounted) setState(() { _tenant = t['full_name'] ?? ''; _email = t['email'] ?? ''; });
    }
    if (listingId != null) {
      final l = await _db.from('property_listings').select('title').eq('listing_id', listingId).maybeSingle();
      if (l != null && mounted) setState(() { _listing = l['title'] ?? ''; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts    = _tenant.trim().split(' ').where((w) => w.isNotEmpty).toList();
    final initials = parts.isEmpty ? '?' : (parts.length == 1 ? parts[0][0] : '${parts[0][0]}${parts[1][0]}').toUpperCase();
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8.r, offset: Offset(0, 2.h))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFF1A0F0A),
                child: Text(initials, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_tenant.isEmpty ? 'Loading...' : _tenant,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp, fontFamily: 'Manrope')),
                    if (_email.isNotEmpty)
                      Text(_email, style: TextStyle(color: Colors.grey, fontSize: 12.sp, fontFamily: 'Manrope')),
                  ],
                ),
              ),
            ],
          ),
          if (_listing.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(children: [
              Icon(Icons.home_outlined, size: 15.r, color: const Color(0xFF8B7355)),
              SizedBox(width: 6.w),
              Expanded(child: Text(_listing, style: TextStyle(fontSize: 13.sp, fontFamily: 'Manrope'))),
            ]),
          ],
          if (widget.booking['payment_method'] != null) ...[
            SizedBox(height: 4.h),
            Row(children: [
              Icon(Icons.credit_card_outlined, size: 15.r, color: const Color(0xFF8B7355)),
              SizedBox(width: 6.w),
              Text(widget.booking['payment_method'], style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: 'Manrope')),
            ]),
          ],
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a5c45), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h), elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✓', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      SizedBox(width: 6.w),
                      Text('Approve', style: TextStyle(fontSize: 13.sp, fontFamily: 'Manrope', fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7a1a1a), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h), elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✕', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      SizedBox(width: 6.w),
                      Text('Reject', style: TextStyle(fontSize: 13.sp, fontFamily: 'Manrope', fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}