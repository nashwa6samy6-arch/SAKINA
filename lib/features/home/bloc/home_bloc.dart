import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/features/listings/models/listing_model.dart';
import 'package:sakina/features/listings/repository/listings_repository.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

// ─── Models ───────────────────────────────────────────────────────────────────
class TenantMatch {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final String? university;
  final List<String> tags;
  final int matchScore; // ✅ ADDED

  TenantMatch({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.university,
    required this.tags,
    this.matchScore = 0, // ✅ default 0
  });
}

// ─── States ───────────────────────────────────────────────────────────────────
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final ListingModel? nearbyListing;
  final List<TenantMatch> topMatches;

  HomeLoaded({this.nearbyListing, required this.topMatches});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _supabase = Supabase.instance.client;
  final _listingsRepo = ListingsRepository();

  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoad);
  }

  Future<void> _onLoad(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        _fetchNearbyListing(),
        _fetchTopMatches(),
      ]);

      emit(HomeLoaded(
        nearbyListing: results[0] as ListingModel?,
        topMatches: results[1] as List<TenantMatch>,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
  

  Future<ListingModel?> _fetchNearbyListing() async {
    try {
      final response = await _supabase
          .from('property_listings')
          .select('''
            *,
            location:location!location_listing_id_fkey (
              address, street, district, city,
              nearby_universities, latitude, longitude
            )
          ''')
          .eq('status', 'available')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final listing = ListingModel.fromJson(response);

      final landlordId = listing.landlordId;
      if (landlordId != null && landlordId.isNotEmpty) {
        final userRow = await _supabase
            .from('users')
            .select()
            .eq('user_id', landlordId)
            .maybeSingle();

        Map<String, dynamic>? landlordRow;
        try {
          landlordRow = await _supabase
              .from('landlord')
              .select()
              .eq('landlord_id', landlordId)
              .maybeSingle();
        } catch (_) {}

        if (userRow != null || landlordRow != null) {
          final profile = LandlordProfile.fromJson({
            'landlord_id': landlordId,
            if (landlordRow != null) ...landlordRow,
            if (userRow != null) ...userRow,
          });
          return listing.copyWith(landlordProfile: profile);
        }
      }

      return listing;
    } catch (_) {
      return null;
    }
  }

  Future<List<TenantMatch>> _fetchTopMatches() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      final landlordResponse =
          await _supabase.from('landlord').select('landlord_id');

      final landlordIds = (landlordResponse as List)
          .whereType<Map<String, dynamic>>()
          .map((r) => r['landlord_id']?.toString())
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      // Get current user's gender
      final myTenantData = await _supabase
          .from('tenants')
          .select('gender')
          .eq('user_id', currentUserId!)
          .maybeSingle();
      final myGender = myTenantData?['gender']?.toString();

      // Fetch tenant genders
      final tenantGenders = await _supabase
          .from('tenants')
          .select('user_id, gender');
      final genderMap = {
        for (final t in (tenantGenders as List).whereType<Map<String, dynamic>>())
          t['user_id'].toString(): t['gender']?.toString()
      };

      final usersResponse = await _supabase
          .from('users')
          .select('user_id, full_name, avatar_url, bio')
          .limit(200);

      final users = (usersResponse as List)
          .whereType<Map<String, dynamic>>()
          .where((u) {
            final id = u['user_id']?.toString();
            if (id == null || id == currentUserId || landlordIds.contains(id)) return false;
            if (myGender != null && genderMap[id] != null) {
              return genderMap[id] == myGender;
            }
            return false;
          })
          .take(5)
          .toList();

      for (final u in users) {
      }

      if (users.isEmpty) return [];

      final matches = <TenantMatch>[];

      for (final user in users) {
        final userId = user['user_id']?.toString() ?? '';

        // Resolve best display name
        String displayName = _resolveName(user['full_name']);
        if (displayName.isEmpty) {
          try {
            final tenantRow = await _supabase
                .from('tenants')
                .select('full_name')
                .eq('user_id', userId)
                .maybeSingle();
            final tenantName = _resolveName(tenantRow?['full_name']);
            if (tenantName.isNotEmpty) displayName = tenantName;
          } catch (_) {}
        }
        if (displayName.isEmpty) displayName = 'Student';

        Map<String, dynamic>? lifestyle;
        try {
          lifestyle = await _supabase
              .from('lifestyle_profile')
              .select(
                  'circadian_rhythm, social_threshold, smoking_preferences, pets_allowed')
              .eq('user_id', userId)
              .maybeSingle();
        } catch (_) {}

        Map<String, dynamic>? tenant;
        try {
          tenant = await _supabase
              .from('tenants')
              .select('university')
              .eq('user_id', userId)
              .maybeSingle();
        } catch (_) {}

        final score = _calculateScore(lifestyle);

        matches.add(TenantMatch(
          userId: userId,
          name: displayName,
          avatarUrl: user['avatar_url']?.toString(),
          bio: user['bio']?.toString(),
          university: tenant?['university']?.toString(),
          tags: _buildTags(lifestyle),
          matchScore: score,
        ));
      }

      return matches;
    } catch (e) {
      return [];
    }
  }

  String _resolveName(dynamic value) {
    final name = value?.toString().trim() ?? '';
    if (name.isEmpty || name.toLowerCase() == 'null') return '';
    return name;
  }

  int _calculateScore(Map<String, dynamic>? lifestyle) {
    if (lifestyle == null) return 60;
    int score = 60;
    if ((lifestyle['circadian_rhythm'] ?? '').toString().isNotEmpty) score += 10;
    if ((lifestyle['social_threshold'] ?? '').toString().isNotEmpty) score += 10;
    if ((lifestyle['smoking_preferences'] ?? '').toString().isNotEmpty) score += 10;
    if (lifestyle['pets_allowed'] != null) score += 5;
    if (score > 99) score = 99;
    return score;
  }

  List<String> _buildTags(Map<String, dynamic>? lifestyle) {
    if (lifestyle == null) return [];
    final tags = <String>[];
    final rhythm = lifestyle['circadian_rhythm']?.toString() ?? '';
    if (rhythm.isNotEmpty) {
      tags.add(rhythm.replaceAll('_', ' ').toUpperCase());
    }
    final social = lifestyle['social_threshold']?.toString() ?? '';
    if (social.isNotEmpty) {
      tags.add(social.replaceAll('_', ' ').toUpperCase());
    }
    if (lifestyle['pets_allowed'] == true) tags.add('PET FRIENDLY');
    return tags.take(2).toList();
  }
}