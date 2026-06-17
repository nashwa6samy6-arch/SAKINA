import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_app_bar.dart';
import 'package:sakina/features/ai_match/screens/loading_screen.dart';
import 'package:sakina/features/home/bloc/home_bloc.dart';
import 'package:sakina/features/listings/listings_details/listings_details.dart';
import 'package:sakina/features/listings/models/listing_model.dart';
import 'package:sakina/pages/widgets/services_near_you.dart';
import 'package:sakina/pages/widgets/top_match.dart';
import 'package:sakina/features/map/screens/map_screen.dart';
import 'package:sakina/pages/explore.dart';
import 'package:sakina/pages/favourite.dart';
import 'package:sakina/pages/messages/chat_screen/messages.dart';

// ── HomePage: now owns the bottom nav bar ─────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activeIndex = 0;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return BlocProvider(
          create: (_) => HomeBloc()..add(LoadHomeData()),
          child: const HomeContent(),
        );
      case 1:
        return const ExplorePage();
      case 2:
        return const FavouritePage();
      case 3:
        return const ConversationsScreen();
      default:
        return BlocProvider(
          create: (_) => HomeBloc()..add(LoadHomeData()),
          child: const HomeContent(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Myappbar(),
      backgroundColor: AppColors.primaryColor,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bottomNavigationBarColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
            topRight: Radius.circular(40.r),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _activeIndex,
            onTap: (index) => setState(() => _activeIndex = index),
            selectedItemColor: AppColors.themeColor,
            unselectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home,
                    color: _activeIndex == 0 ? AppColors.themeColor : Colors.white),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore,
                    color: _activeIndex == 1 ? AppColors.themeColor : Colors.white),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite,
                    color: _activeIndex == 2 ? AppColors.themeColor : Colors.white),
                label: 'Favourites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message,
                    color: _activeIndex == 3 ? AppColors.themeColor : Colors.white),
                label: 'Messages',
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: _buildScreen(_activeIndex),
      ),
    );
  }
}

// ── HomeContent: the scrollable home tab body ─────────────────────────────────
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

const List<Map<String, dynamic>> _searchSuggestions = [
  {'label': 'Zamalek', 'subtitle': 'District · Cairo', 'icon': Icons.location_on_outlined},
  {'label': 'Maadi', 'subtitle': 'District · Cairo', 'icon': Icons.location_on_outlined},
  {'label': 'Heliopolis', 'subtitle': 'District · Cairo', 'icon': Icons.location_on_outlined},
  {'label': 'Dokki', 'subtitle': 'District · Giza', 'icon': Icons.location_on_outlined},
  {'label': 'Agouza', 'subtitle': 'District · Giza', 'icon': Icons.location_on_outlined},
  {'label': 'Downtown', 'subtitle': 'District · Cairo', 'icon': Icons.location_on_outlined},
  {'label': 'New Cairo', 'subtitle': 'District · Cairo', 'icon': Icons.location_on_outlined},
  {'label': 'Nasr City', 'subtitle': 'District · Cairo', 'icon': Icons.location_on_outlined},
  {'label': 'Mohandessin', 'subtitle': 'District · Giza', 'icon': Icons.location_on_outlined},
  {'label': 'Shubra', 'subtitle': 'District · Cairo', 'icon': Icons.location_on_outlined},
  {'label': 'Cairo University', 'subtitle': 'University · Giza', 'icon': Icons.school_outlined},
  {'label': 'Ain Shams University', 'subtitle': 'University · Cairo', 'icon': Icons.school_outlined},
  {'label': 'AUC', 'subtitle': 'University · New Cairo', 'icon': Icons.school_outlined},
  {'label': 'GUC', 'subtitle': 'University · New Cairo', 'icon': Icons.school_outlined},
  {'label': 'Helwan University', 'subtitle': 'University · Helwan', 'icon': Icons.school_outlined},
  {'label': 'Al-Azhar University', 'subtitle': 'University · Cairo', 'icon': Icons.school_outlined},
  {'label': 'Studio', 'subtitle': 'Property type', 'icon': Icons.home_outlined},
  {'label': 'Apartment', 'subtitle': 'Property type', 'icon': Icons.apartment_outlined},
  {'label': 'Room', 'subtitle': 'Property type', 'icon': Icons.bed_outlined},
];

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() =>
          _showSuggestions = _searchFocus.hasFocus && _query.isEmpty);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return _searchSuggestions.take(6).toList();
    return _searchSuggestions
        .where((s) =>
            s['label'].toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void _onSuggestionTap(String label) {
    _searchController.clear();
    setState(() {
      _query = '';
      _showSuggestions = false;
    });
    _searchFocus.unfocus();
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const MapSearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final listing = state is HomeLoaded ? state.nearbyListing : null;
        final matches = state is HomeLoaded ? state.topMatches : <TenantMatch>[];

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Container(
                margin: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ─── Hero Text ────────────────────────────────────────
                    Text(
                      'Find your quiet in the chaos.',
                      style: TextStyle(
                        color: const Color(0xFF120A00),
                        fontSize: 32.sp,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -1.60,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Curated roommate matches and premium living spaces across Egypt's academic districts.",
                      style: TextStyle(
                          color: const Color(0xFF4C463C),
                          fontSize: 16.sp,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 24.h),

                // ─── Search Bar ───────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            elevation: 0,
                            borderRadius: BorderRadius.circular(8),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              onChanged: (value) {
                                setState(() {
                                  _query = value;
                                  _showSuggestions = true;
                                });
                              },
                              onSubmitted: (value) {
                                if (value.isNotEmpty) _onSuggestionTap(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search by area or university...',
                                hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Manrope',
                                    fontSize: 14),
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: _query.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _query = '';
                                            _showSuggestions = false;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          padding: const EdgeInsets.all(20),
                          style: IconButton.styleFrom(
                            iconSize: 20,
                            backgroundColor: AppColors.bottomNavigationBarColor,
                            foregroundColor: AppColors.appbarColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MapSearchScreen()));
                          },
                          icon: SvgPicture.asset("assets/icons/filtericon.svg"),
                        ),
                      ],
                    ),

                    if (_showSuggestions || _query.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.10),
                                blurRadius: 12,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: _filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search_off,
                                        color: Colors.grey, size: 20),
                                    const SizedBox(width: 10),
                                    Text('No results for "$_query"',
                                        style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            color: Colors.grey,
                                            fontSize: 14)),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  if (_query.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('POPULAR SEARCHES',
                                            style: TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.2,
                                                color: Colors.grey)),
                                      ),
                                    ),
                                  ..._filtered.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final s = entry.value;
                                    return InkWell(
                                      onTap: () => _onSuggestionTap(s['label']),
                                      borderRadius: BorderRadius.vertical(
                                        top: i == 0
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                        bottom: i == _filtered.length - 1
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFFF5EFE6),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Icon(s['icon'] as IconData,
                                                  size: 18,
                                                  color: const Color(0xFF4C463C)),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(s['label'],
                                                      style: const TextStyle(
                                                          fontFamily: 'Manrope',
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF120A00))),
                                                  Text(s['subtitle'],
                                                      style: const TextStyle(
                                                          fontFamily: 'Manrope',
                                                          fontSize: 12,
                                                          color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.north_west,
                                                size: 14, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                      ),
                  ],
                ),

                // ─── AI Smart Match Card ──────────────────────────────
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.primaryBeig,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/pictures/AI_Cute.png',
                          width: 100, height: 100, fit: BoxFit.cover),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: Text('AI Smart Match',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Manrope',
                                      color: Color(0xFF4D4634),
                                      fontWeight: FontWeight.w500)),
                            ),
                            const Text('Let AI find your perfect room.',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF120A00),
                                    height: 1.80,
                                    letterSpacing: -1.60)),
                            const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text(
                                  'Personalized matches tailored to your lifestyle and budget.',
                                  style: TextStyle(
                                      color: Color(0xFF4C463C),
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 12.0),
                              child: SizedBox(
                                width: 170,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoadingScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.bottomNavigationBarColor,
                                    foregroundColor: AppColors.primaryBeig,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Find my match',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w700,
                                          height: 1.71,
                                          letterSpacing: 0.40)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Browse Nearby ─────────────────────────────────────
                const SizedBox(height: 24),
                Container(
                  color: AppColors.themeColor,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Browse Nearby',
                              style: TextStyle(
                                  color: Color(0xFF120A00),
                                  fontSize: 24,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                  letterSpacing: -0.60)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MapSearchScreen())),
                            child: const Text('VIEW MAP',
                                style: TextStyle(
                                    color: Color(0xFF4C463C),
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    height: 1.33,
                                    letterSpacing: 1.20)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (state is HomeLoading)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: CircularProgressIndicator(),
                        ))
                      else if (listing != null)
                        _BrowseNearbyCard(listing: listing)
                      else
                        _BrowseNearbyPlaceholder(),
                    ],
                  ),
                ),

                // ─── Top Match ─────────────────────────────────────────
                if (state is! HomeLoading) ...[
                  TopMatch(matches: matches),
                  const SizedBox(height: 24),
                ],

                // ─── Services Near You ─────────────────────────────────
                ServicesNearYouContainer(),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
  }
}

// ─── Browse Nearby Card ───────────────────────────────────────────────────────
class _BrowseNearbyCard extends StatelessWidget {
  final ListingModel listing;
  const _BrowseNearbyCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.galleryImages.isNotEmpty
        ? listing.galleryImages.first
        : null;
    final location = listing.address?.isNotEmpty == true
        ? listing.address!
        : listing.locationDisplay;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RoomDetailScreen(listing: listing)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: Stack(
            children: [
              Positioned.fill(
                child: imageUrl != null
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF8AACB8),
                            child: Icon(Icons.home,
                                size: 60.r, color: Colors.white30)))
                    : Container(
                        color: const Color(0xFF8AACB8),
                        child: Icon(Icons.home,
                            size: 60.r, color: Colors.white30)),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3)
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined, color: Colors.white, size: 16.r),
                      SizedBox(width: 6.w),
                      Text(listing.propertyTypeDisplay,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          width: 60.r,
                          height: 60.r,
                          color: const Color(0xFF8AACB8),
                          child: imageUrl != null
                              ? Image.network(imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.home, color: Colors.white30, size: 30.r))
                              : Icon(Icons.home, color: Colors.white30, size: 30.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.title.isNotEmpty
                                  ? listing.title
                                  : 'Available Property',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1C1C)),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14.r, color: const Color(0xFF888888)),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    location.isNotEmpty ? location : 'Cairo, Egypt',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.sp, color: const Color(0xFF888888)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: const Color(0xFF1C1C1C), size: 24.r),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrowseNearbyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: Container(
          color: const Color(0xFF8AACB8),
          child: Center(
            child: Text('No listings available',
                style: TextStyle(color: Colors.white70, fontFamily: 'Manrope', fontSize: 14.sp)),
          ),
        ),
      ),
    );
  }
}