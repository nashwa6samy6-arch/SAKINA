import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class Listing {
  final String title;
  final String subtitle;
  final String price;
  final String priceNote;
  final List<String> tags;
  final String? matchPercent;
  final String imagePath; // placeholder tint

  const Listing({
    required this.title,
    required this.subtitle,
    required this.price,
    this.priceNote = '',
    this.tags = const [],
    this.matchPercent,
    required this.imagePath,
  });
}

final List<Listing> _listings = [
  Listing(
    title: 'Maadi Garden Suite',
    subtitle: '2.4 km from AUC Campus',
    price: '4,500',
    priceNote: 'EGP/mo\nUtilities\nIncluded',
    tags: ['Private Balcony', '98% Match', 'High-speed WiFi'],
    matchPercent: '98%',
    imagePath:
        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
  ),
  Listing(
    title: 'New Cairo Cozy Flat',
    subtitle: '5.8 km from AUC Campus',
    price: '5,800',
    priceNote: 'EGP/mo\nAll Inclusive',
    tags: ['Rooftop Access', '95% Match'],
    matchPercent: '95%',
    imagePath:
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  int _selectedTab = 0; // 0 = Rooms, 1 = Apartments
  final Set<int> _favourited = {0, 1, 2, 3}; // all hearted by default

  void _toggleFavourite(int index) {
    setState(() {
      if (_favourited.contains(index)) {
        _favourited.remove(index);
      } else {
        _favourited.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURATED COLLECTION',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.4,
                        color: Colors.brown.shade400,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Saved & Favorites',
                      style: TextStyle(
                        color:  Color(0xFF120A00),
                        fontSize: 32,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: -1.60,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Tab Toggle ─────────────────────────────────────────
                    _TabToggle(
                      selected: _selectedTab,
                      onChanged: (v) => setState(() => _selectedTab = v),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Listing Cards ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final listing = _listings[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ListingCard(
                      listing: listing,
                      isFavourited: _favourited.contains(index),
                      onFavouriteToggle: () => _toggleFavourite(index),
                    ),
                  );
                }, childCount: _listings.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _CompareFavoritesPromo(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Tab Toggle ────────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _TabToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5D8),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            label: 'Rooms',
            active: selected == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            label: 'Apartments',
            active: selected == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? const Color(0xFF2C2218) : const Color(0xFF9C8878),
          ),
        ),
      ),
    );
  }
}

// ── Listing Card ──────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final Listing listing;
  final bool isFavourited;
  final VoidCallback onFavouriteToggle;

  const _ListingCard({
    required this.listing,
    required this.isFavourited,
    required this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ──────────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(listing.imagePath), // 👈 مسار الصورة
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.home_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              // Heart button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onFavouriteToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavourited ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFavourited
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color(0xFF9C8878),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Details ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C2218),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Colors.brown.shade300,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                listing.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.brown.shade400,
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
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: listing.price,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C2218),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (listing.priceNote.isNotEmpty)
                          Text(
                            listing.priceNote,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.brown.shade400,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Tags
                if (listing.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: listing.tags.map((tag) {
                      final isMatch = tag.contains('Match');
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isMatch
                              ? const Color(0xFFE8F5E8)
                              : const Color(0xFFF3EDE4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isMatch
                                ? const Color(0xFF8BC48A)
                                : const Color(0xFFD4C4A8),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isMatch
                                ? const Color(0xFF4A8A49)
                                : const Color(0xFF7A6550),
                          ),
                        ),
                      );
                    }).toList(),
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

// ── Compare Favorites Promo ───────────────────────────────────────────────────

class _CompareFavoritesPromo extends StatelessWidget {
  const _CompareFavoritesPromo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Quote Section ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFF7E0B6), width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '"Finding the right space is the first step toward building your sanctuary. These are the homes you\'ve felt a connection with."',
                  style: TextStyle(
                    color: Color(0xFF2C2005),
                    fontSize: 24,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    height: 1.30,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 2,
                      color: const Color(0xFFDAC49B),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'EDITORIAL NOTE',
                      style: TextStyle(
                        color: Color(0xFF4C463C),
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: 1.20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Dark Card Section ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF28200B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compare your favorites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 1.40,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Analyze compatibility scores and utility splits side-by-side to make the final decision.',
                style: TextStyle(
                  color: const Color(0xFF9A8762),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 1.63,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7E0B6),
                  foregroundColor: const Color(0xFF2C2218),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enter Compare Mode',
                  style: TextStyle(
                    color:  Color(0xFF120A00),
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
