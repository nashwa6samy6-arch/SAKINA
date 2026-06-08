import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reusable widget that displays a list of property listings for a landlord.
/// Can be embedded in any screen without navigation overhead.
///
/// Usage:
///   PropertyListingsWidget(
///     landlordId: 'user_123',
///     onListingTap: (listing) { ... },
///   )

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(
        child: PropertyListingsWidget(landlordId: 'user_123'),
      ),
    ),
  ));
}

class PropertyListingsWidget extends StatefulWidget {
  /// The landlord/property owner ID
  final String landlordId;

  /// Callback when a listing is tapped
  final void Function(Map<String, dynamic> listing)? onListingTap;

  /// Show refresh indicator. Defaults to true.
  final bool enableRefresh;

  /// Custom padding. Defaults to vertical 16, horizontal 20.
  final EdgeInsetsGeometry padding;

  const PropertyListingsWidget({
    super.key,
    required this.landlordId,
    this.onListingTap,
    this.enableRefresh = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  State<PropertyListingsWidget> createState() =>
      PropertyListingsWidgetState();
}

class PropertyListingsWidgetState extends State<PropertyListingsWidget> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadListings();
  }

  /// Public method to reload listings (accessible via GlobalKey)
  Future<void> loadListings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('property_listings')
          .select()
          .eq('landlord_id', widget.landlordId)
          .eq('status', 'available')
          .order('created_at', ascending: false);

      setState(() {
        _listings = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  /// Get the current listing count
  int get count => _listings.length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_listings.isEmpty) {
      return Padding(
        padding: widget.padding,
        child: const Center(
          child: Text(
            'No available listings',
            style: TextStyle(
              fontSize: 14,
              color: _ListingColors.muted,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      );
    }

    final list = ListView.builder(
      padding: widget.padding,
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => widget.onListingTap?.call(listing),
            child: _ListingCard(listing: listing),
          ),
        );
      },
    );

    if (widget.enableRefresh) {
      return RefreshIndicator(
        onRefresh: loadListings,
        child: list,
      );
    }

    return list;
  }
}

// ─── Listing Card ──────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final title = listing['title'] ?? 'Untitled';
    final price = listing['rent_price'];
    final type = listing['property_type'] ?? '';
    final rooms = listing['available_rooms'] ?? 0;
    final imageUrl = listing['image_url']?.toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ListingColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: _ListingColors.imageBg,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.home,
                        color: _ListingColors.muted,
                      ),
                    )
                  : const Icon(Icons.home, color: _ListingColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ListingColors.brown,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.isNotEmpty
                      ? '${type.replaceAll('_', ' ')} • $rooms rooms'
                      : '$rooms rooms',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _ListingColors.muted,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 6),
                if (price != null)
                  Text(
                    'EGP $price / month',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ListingColors.brown,
                      fontFamily: 'Manrope',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Colors ────────────────────────────────────────────────────────────────

class _ListingColors {
  static const Color bg = Color(0xFFF5F3EF);
  static const Color card = Color(0xFFEEE9DF);
  static const Color brown = Color(0xFF1B1209);
  static const Color muted = Color(0xFF7A746C);
  static const Color imageBg = Color(0xFFD8D0C0);
}