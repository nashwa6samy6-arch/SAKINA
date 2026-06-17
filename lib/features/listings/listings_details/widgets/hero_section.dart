import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/listings/models/listing_model.dart';

class HeroSection extends StatefulWidget {
  final ListingModel listing;
  final VoidCallback? onViewProfile;
  final VoidCallback? onView360;
  const HeroSection({
    super.key,
    required this.listing,
    this.onViewProfile,
    this.onView360,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.listingId != widget.listing.listingId) {
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.listing.galleryImages;
    final profile = widget.listing.landlordProfile ??
        LandlordProfile.fallback(widget.listing.landlordId);
    final avatarUrl = profile.avatarUrl;
    final rating = profile.rating ?? widget.listing.ratingValue;

    // ---------- Responsive sizes from MediaQuery ----------
    final screenWidth = MediaQuery.of(context).size.width;
    final heroHeight = (screenWidth * 0.65).clamp(220.0, 340.0);
    final arrowSize = (screenWidth * 0.1).clamp(36.0, 52.0);
    final arrowIconSize = arrowSize * 0.55;
    final arrowInset = (screenWidth * 0.03).clamp(10.0, 20.0);
    final overlayTop =  16.0;

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: heroHeight,
              child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFF8AACB8)),
              child: Stack(
                children: [
                  // ---------- Image Carousel ----------
                  if (images.isEmpty)
                    const Center(
                      child: Icon(Icons.bed, size: 60, color: Colors.white30),
                    )
                  else
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                size: 60, color: Colors.white30),
                          ),
                        );
                      },
                    ),

                  // ---------- Left Arrow ----------
                  if (images.length > 1)
                    Positioned(
                      left: arrowInset,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            width: arrowSize,
                            height: arrowSize,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: arrowIconSize,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ---------- Right Arrow ----------
                  if (images.length > 1)
                    Positioned(
                      right: arrowInset,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentPage < images.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            width: arrowSize,
                            height: arrowSize,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: arrowIconSize,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ---------- Image Counter ----------
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentPage + 1} / ${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // ---------- Page Indicators ----------
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ),

            // ---------- Price Tag ----------
            Positioned(
              top: overlayTop,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STARTING AT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                            letterSpacing: 1.20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.listing.priceDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            height: 1.40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ---------- 360 View button ----------
            Positioned(
              top: overlayTop,
              right: 16,
              child: GestureDetector(
                onTap: widget.onView360,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0XFF2C2005),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '360 view',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ---------- Host Avatar & Info (in normal flow — tappable) ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onViewProfile,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.primaryBeig,
                      backgroundImage:
                          avatarUrl == null ? null : NetworkImage(avatarUrl),
                      child: avatarUrl == null
                          ? const Icon(Icons.person_rounded,
                              color: Colors.black54, size: 34)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBeig,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            'view profile',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              height: 1.67,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF120A00),
                        fontSize: 19,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        height: 1.47,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF5A623), size: 16),
                        const SizedBox(width: 3),
                        Text(
                          rating > 0
                              ? rating.toStringAsFixed(1)
                              : 'New host',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF4C463C),
                            fontSize: 13,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        if (widget.listing.status.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.listing.status,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF4C463C),
                                fontSize: 13,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}