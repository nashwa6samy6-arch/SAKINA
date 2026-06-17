import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListingAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String listingId;
  const ListingAppbar({super.key, required this.listingId});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ListingAppbar> createState() => _ListingAppbarState();
}

class _ListingAppbarState extends State<ListingAppbar> {
  final _supabase = Supabase.instance.client;
  bool _isFavourited = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFavourite();
  }

  Future<void> _checkFavourite() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) { setState(() => _loading = false); return; }
    try {
      final result = await _supabase
          .from('favourites')
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', widget.listingId)
          .maybeSingle();
      if (mounted) setState(() { _isFavourited = result != null; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavourite() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => _isFavourited = !_isFavourited);
    try {
      if (_isFavourited) {
        await _supabase.from('favourites').insert({
          'user_id': userId,
          'listing_id': widget.listingId,
        });
      } else {
        await _supabase.from('favourites')
            .delete()
            .eq('user_id', userId)
            .eq('listing_id', widget.listingId);
      }
    } catch (_) {
      if (mounted) setState(() => _isFavourited = !_isFavourited);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ---------- Responsive sizes via MediaQuery ----------
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth * 0.062).clamp(20.0, 28.0);
    final loadingSize = (screenWidth * 0.046).clamp(16.0, 22.0);

    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: iconSize),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, size: iconSize),
          onPressed: () {},
        ),
        SizedBox(width: screenWidth * 0.02),
        IconButton(
          icon: _loading
              ? SizedBox(
                  width: loadingSize,
                  height: loadingSize,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _isFavourited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavourited ? Colors.red : null,
                  size: iconSize,
                ),
          onPressed: _loading ? null : _toggleFavourite,
        ),
        SizedBox(width: screenWidth * 0.04),
      ],
    );
  }
}