import 'package:sakina/core/utils/app_dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/listings/listings_details/widgets/community_voice_widget.dart';
import 'package:sakina/features/listings/listings_details/widgets/facilities_card.dart';
import 'package:sakina/features/listings/listings_details/widgets/hero_section.dart';
import 'package:sakina/features/listings/listings_details/widgets/listing_app_bar.dart';
import 'package:sakina/features/listings/listings_details/widgets/listing_bottom_bar.dart';
import 'package:sakina/features/listings/listings_details/widgets/location_listing.dart';
import 'package:sakina/features/listings/models/listing_model.dart';
import 'package:sakina/features/listings/repository/listings_repository.dart';
import 'package:sakina/landlord/public_landlord_profile_screen.dart';
import 'package:sakina/pages/messages/chat_screen/chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class RoomDetailScreen extends StatefulWidget {
  final ListingModel listing;

  const RoomDetailScreen({
    super.key,
    required this.listing,
  });

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _repository = ListingsRepository();
  late Future<ListingModel>? _listingFuture;

  @override
  void initState() {
    super.initState();
    _listingFuture = widget.listing.listingId.isEmpty
        ? null
        : _repository.getListingById(widget.listing.listingId);
  }

  @override
  Widget build(BuildContext context) {
    final future = _listingFuture;
    if (future == null) return _buildScaffold(widget.listing);

    return FutureBuilder<ListingModel>(
      future: future,
      initialData: widget.listing,
      builder: (context, snapshot) {
        return _buildScaffold(
          snapshot.data ?? widget.listing,
          isRefreshing: snapshot.connectionState == ConnectionState.waiting,
          refreshError: snapshot.hasError ? snapshot.error.toString() : null,
        );
      },
    );
  }

  Widget _buildScaffold(
    ListingModel listing, {
    bool isRefreshing = false,
    String? refreshError,
  }) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      extendBodyBehindAppBar: true,
      appBar: ListingAppbar(listingId: listing.listingId),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroSection(
                  listing: listing,
                  onViewProfile: () => _showLandlordProfile(listing),
                  onView360: () => _show360Tour(listing),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoCard(listing: listing),
                      const SizedBox(height: 28),
                      _SakinaMatchSection(listing: listing),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                FacilitiesCard(listing: listing),
                LocationMapWidget(listing: listing),
                EssentialComfortsCard(listing: listing),
                CommunityVoiceWidget(
                  listing: listing,
                  onSubmitReview: (rating, comment) =>
                      _submitReview(listing, rating, comment),
                ),
                ListingBottomBar(
                  onBookViewing: () => _requestProperty(listing),
                  onChat: () async {
                    try {
                      final convId = await _getOrCreateConversation();
                      final profile = widget.listing.landlordProfile ??
                          LandlordProfile.fallback(widget.listing.landlordId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversationId: convId,
                            otherUserId: widget.listing.landlordId!,
                            otherUserName: profile.name,
                            otherUserAvatar: profile.avatarUrl,
                          ),
                        ),
                      );
                    } catch (e) {
                      showErrorDialog(context, e.toString(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          if (isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (refreshError != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _RefreshErrorBanner(message: refreshError),
            ),
        ],
      ),
    );
  }

  Future<void> _requestProperty(ListingModel listing) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      showErrorDialog(context, 'Please log in first.');
      return;
    }

    // Check if already requested
    final existing = await supabase
        .from('bookings')
        .select('booking_id')
        .eq('tenant_id', userId)
        .eq('listing_id', listing.listingId ?? '')
        .maybeSingle();

    if (existing != null) {
      showErrorDialog(context, 'You have already sent a request for this property.');
      return;
    }

    try {
      // Insert booking request
      await supabase.from('bookings').insert({
        'tenant_id': userId,
        'listing_id': listing.listingId,
        'landlord_id': listing.landlordId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Get tenant name
      final tenantData = await supabase
          .from('users')
          .select('full_name')
          .eq('user_id', userId)
          .maybeSingle();
      final tenantName = tenantData?['full_name'] ?? 'A tenant';

      // Send notification to landlord
      if (listing.landlordId != null && listing.landlordId!.isNotEmpty) {
        await supabase.from('notification').insert({
          'user_id': listing.landlordId,
          'type': 'booking_request',
          'message': '$tenantName has requested to book "${listing.title}". Tap to accept or decline.',
          'is_read': false,
          'sent_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 64),
              const SizedBox(height: 16),
              const Text('Request Sent!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Your request for "${listing.title}" has been sent to the host. You will be notified once they respond.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2416),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }

  void _showLandlordProfile(ListingModel listing) {
    final landlordId = listing.landlordId;
    if (landlordId == null || landlordId.isEmpty) {
      showErrorDialog(context, 'Host profile not available.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicLandlordProfileScreen(landlordId: landlordId),
      ),
    );
  }

  void _show360Tour(ListingModel listing) {
  // tour_360_url is null in your DB — fall back to image_url when has_360_tour is true
  final tourUrl = (listing.tour360Url?.trim().isNotEmpty == true)
      ? listing.tour360Url!
      : (listing.has360Tour && listing.imageUrl?.trim().isNotEmpty == true)
          ? listing.imageUrl!
          : null;

  debugPrint('[360 Tour] resolved URL: $tourUrl');

  if (tourUrl == null) {
    showErrorDialog(context, 'The host has not uploaded a 360° tour yet.');
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => _Tour360Screen(url: tourUrl)),
  );
}

  Future<String> _getOrCreateConversation() async {
    final supabase = Supabase.instance.client;
    final tenantId = supabase.auth.currentUser?.id;
    if (tenantId == null) throw Exception('Please login to message the host');

    final listing = widget.listing;
    final landlordId = listing.landlordId;
    if (landlordId == null || landlordId.isEmpty) {
      throw Exception('Host not found');
    }

    try {
      final existing = await supabase
          .from('conversation')
          .select('conversation_id')
          .eq('listing_id', listing.listingId)
          .maybeSingle();
      if (existing != null) {
        final participant = await supabase
            .from('conversation_participants')
            .select()
            .eq('conversation_id', existing['conversation_id'])
            .eq('tenant_id', tenantId)
            .maybeSingle();
        if (participant == null) {
          await supabase.from('conversation_participants').insert({
            'conversation_id': existing['conversation_id'],
            'tenant_id': tenantId,
            'joined_at': DateTime.now().toIso8601String(),
          });
        }
        return existing['conversation_id'];
      }
    } catch (_) {}

    final newConv = await supabase
        .from('conversation')
        .insert({
          'user_id': landlordId,
          if (listing.listingId.isNotEmpty) 'listing_id': listing.listingId,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final conversationId = newConv['conversation_id'];

    await supabase.from('conversation_participants').insert({
      'conversation_id': conversationId,
      'tenant_id': tenantId,
      'joined_at': DateTime.now().toIso8601String(),
    });

    return conversationId;
  }

  Future<void> _submitReview(
    ListingModel listing,
    int rating,
    String comment,
  ) async {
    if (listing.listingId.isEmpty) {
      throw Exception('Listing id is missing.');
    }

    await _repository.addReview(
      listingId: listing.listingId,
      landlordId: listing.landlordId ?? '',
      rating: rating,
      comment: comment,
    );

    if (!mounted) return;
    setState(() {
      _listingFuture = _repository.getListingById(listing.listingId);
    });
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ListingModel listing;

  const _InfoCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final location = listing.address?.isNotEmpty == true
        ? listing.address!
        : listing.locationDisplay;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  listing.propertyTypeDisplay.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.black,
              ),
              Expanded(
                child: Text(
                  location.isNotEmpty ? location : 'Location not available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    height: 1.54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            listing.title.isNotEmpty ? listing.title : 'Untitled listing',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              height: 1.41,
              letterSpacing: -0.90,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            listing.description.isNotEmpty
                ? listing.description
                : 'No description has been added for this listing yet.',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              height: 1.83,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sakina Match Section ─────────────────────────────────────────────────────

class _SakinaMatchSection extends StatelessWidget {
  final ListingModel listing;

  const _SakinaMatchSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    final university = listing.nearbyUniversities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, size: 24, color: Color(0xFF1A1A1A)),
            SizedBox(width: 6),
            Text(
              'Sakina Match',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MatchCard(
          icon: Icons.school_outlined,
          title: 'Academic Proximity',
          description: university?.isNotEmpty == true
              ? 'Close to $university, based on the location added by the host.'
              : 'University proximity will appear once the host adds it.',
          badge: university?.isNotEmpty == true ? 'Student friendly' : null,
        ),
        const SizedBox(height: 12),
        _MatchCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Budget Fit',
          description:
              '${listing.priceDisplay} per month for a ${listing.propertyTypeDisplay.toLowerCase()}.',
          badge: listing.status == 'available' ? 'Available now' : null,
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? badge;

  const _MatchCard({
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1A1A1A),
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFEEE8DE)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified, size: 14, color: Color(0xFF4CAF50)),
                const SizedBox(width: 5),
                Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Refresh Error Banner ─────────────────────────────────────────────────────

class _RefreshErrorBanner extends StatelessWidget {
  final String message;

  const _RefreshErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          'Showing saved preview. Could not refresh listing: $message',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

// ─── 360° Tour Screen ─────────────────────────────────────────────────────────

class _Tour360Screen extends StatefulWidget {
  final String url;

  const _Tour360Screen({required this.url});

  @override
  State<_Tour360Screen> createState() => _Tour360ScreenState();
}

class _Tour360ScreenState extends State<_Tour360Screen> {
  bool _imageLoaded = false;
  bool _imageFailed = false;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    _preloadImage();
  }

  /// Preload the image via Flutter's ImageStream so we get
  /// load/error callbacks without relying on PanoramaViewer internals.
  void _preloadImage() {
    final provider = NetworkImage(widget.url);
    _imageListener = ImageStreamListener(
      (_, __) {
        if (mounted) setState(() => _imageLoaded = true);
      },
      onError: (exception, stackTrace) {
        debugPrint('[360 Tour] Image failed: $exception');
        if (mounted) setState(() => _imageFailed = true);
      },
    );
    provider
        .resolve(ImageConfiguration.empty)
        .addListener(_imageListener!);
  }

  void _retry() {
    setState(() {
      _imageLoaded = false;
      _imageFailed = false;
    });
    _preloadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          '360° Tour',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ── Web: InteractiveViewer (pan + zoom) ──────────────────────────
          if (kIsWeb && _imageLoaded && !_imageFailed)
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),

          // ── Mobile: true PanoramaViewer ──────────────────────────────────
          if (!kIsWeb && _imageLoaded && !_imageFailed)
            PanoramaViewer(
              animSpeed: 1.0,
              sensorControl: SensorControl.absoluteOrientation,
              child: Image.network(widget.url),
            ),

          // ── Loading overlay ───────────────────────────────────────────────
          if (!_imageLoaded && !_imageFailed)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading 360° tour…',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),

          // ── Error state ───────────────────────────────────────────────────
          if (_imageFailed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image_outlined,
                        color: Colors.white54, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load the 360° image.\nMake sure the URL points to a valid equirectangular photo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _retry,
                      child: const Text(
                        'Try again',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Hint pill ────────────────────────────────────────────────────
          if (_imageLoaded && !_imageFailed)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        kIsWeb ? Icons.open_with : Icons.screen_rotation,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        kIsWeb
                            ? 'Drag to pan · pinch to zoom'
                            : 'Drag or tilt to explore',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}