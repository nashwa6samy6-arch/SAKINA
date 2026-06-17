import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_app_bar.dart';
import 'package:sakina/pages/messages/chat_screen/chat_screen.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class PropertyMatch {
  final String listingId;
  final String title;
  final String imageUrl;
  final double rentPrice;
  final String propertyType;
  final int score;
  final List<String> reasons;

  PropertyMatch({
    required this.listingId,
    required this.title,
    required this.imageUrl,
    required this.rentPrice,
    required this.propertyType,
    required this.score,
    required this.reasons,
  });

  factory PropertyMatch.fromJson(Map<String, dynamic> json) {
    final listing = json['listing'] as Map<String, dynamic>? ?? {};
    return PropertyMatch(
      listingId: listing['listing_id']?.toString() ?? '',
      title: listing['title']?.toString() ?? '',
      imageUrl: listing['image_url']?.toString() ?? '',
      rentPrice: (listing['rent_price'] as num?)?.toDouble() ?? 0,
      propertyType: listing['property_type']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }
}

class RoommateMatch {
  final String tenantId;
  final String fullName;
  final String avatarUrl;
  final String university;
  final int score;
  final List<String> reasons;
  final Map<String, dynamic> breakdown;

  RoommateMatch({
    required this.tenantId,
    required this.fullName,
    required this.avatarUrl,
    required this.university,
    required this.score,
    required this.reasons,
    required this.breakdown,
  });

  factory RoommateMatch.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>? ?? {};
    final rawName = tenant['full_name']?.toString().trim() ?? '';
    final name = (rawName.isEmpty || rawName == 'null') ? 'Student' : rawName;
    final rawAvatar = tenant['avatar_url']?.toString().trim() ?? '';
    final avatar = (rawAvatar == 'null') ? '' : rawAvatar;
    final rawUni = tenant['university']?.toString().trim() ?? '';
    final university = (rawUni == 'null') ? '' : rawUni;
    final id = tenant['user_id']?.toString() ??
        tenant['tenant_id']?.toString() ??
        '';

    return RoommateMatch(
      tenantId: id,
      fullName: name,
      avatarUrl: avatar,
      university: university,
      score: (json['score'] as num?)?.toInt() ?? 0,
      reasons: List<String>.from(json['reasons'] ?? []),
      breakdown: Map<String, dynamic>.from(json['breakdown'] ?? {}),
    );
  }

  List<String> get tags {
    final tags = <String>[];
    final b = breakdown;
    if ((b['circadian'] as num? ?? 0) >= 80) tags.add('Same Sleep Schedule');
    if ((b['social'] as num? ?? 0) >= 80) tags.add('Similar Social Style');
    if ((b['smoking'] as num? ?? 0) >= 90) tags.add('Non-Smoker');
    if ((b['studyTime'] as num? ?? 0) >= 80) tags.add('Same Study Hours');
    if ((b['cleanliness'] as num? ?? 0) >= 80) tags.add('Clean & Tidy');
    if (tags.isEmpty) tags.add('Compatible');
    return tags.take(3).toList();
  }
}

// ─── Repository ───────────────────────────────────────────────────────────────
class AiMatchRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchMatches({double budget = 15000}) async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Not logged in');

    final response = await _supabase.functions.invoke(
      'ai-match',
      body: {'budget': budget},
    );

    if (response.status != 200) {
      throw Exception(response.data?['error'] ?? 'Matching failed');
    }

    final data = response.data as Map<String, dynamic>;

    final roommateMatches = data['roommate_matches'] as List? ?? [];
    final enriched = await Future.wait(
      roommateMatches.map((m) async {
        final match = Map<String, dynamic>.from(m as Map);
        final tenant = Map<String, dynamic>.from(
            match['tenant'] as Map<String, dynamic>? ?? {});

        final currentName = tenant['full_name']?.toString().trim() ?? '';
        final needsName = currentName.isEmpty ||
            currentName == 'Unknown' ||
            currentName == 'null';
        final currentAvatar = tenant['avatar_url']?.toString().trim() ?? '';
        final needsAvatar = currentAvatar.isEmpty || currentAvatar == 'null';

        if (needsName || needsAvatar) {
          final userId = tenant['user_id']?.toString() ??
              tenant['tenant_id']?.toString() ??
              '';
          if (userId.isNotEmpty) {
            try {
              final userRow = await _supabase
                  .from('users')
                  .select('full_name, avatar_url')
                  .eq('user_id', userId)
                  .maybeSingle();
              if (userRow != null) {
                final dbName = userRow['full_name']?.toString().trim() ?? '';
                if (needsName && dbName.isNotEmpty && dbName != 'null') {
                  tenant['full_name'] = dbName;
                }
                final dbAvatar =
                    userRow['avatar_url']?.toString().trim() ?? '';
                if (needsAvatar && dbAvatar.isNotEmpty) {
                  tenant['avatar_url'] = dbAvatar;
                }
              }
            } catch (_) {}
          }
        }

        final finalName = tenant['full_name']?.toString().trim() ?? '';
        if (finalName.isEmpty ||
            finalName == 'Unknown' ||
            finalName == 'null') {
          tenant['full_name'] = 'Student';
        }

        final currentUni = tenant['university']?.toString().trim() ?? '';
        if (currentUni.isEmpty || currentUni == 'null') {
          final userId = tenant['user_id']?.toString() ??
              tenant['tenant_id']?.toString() ??
              '';
          if (userId.isNotEmpty) {
            try {
              final tenantRow = await _supabase
                  .from('tenants')
                  .select('university')
                  .eq('user_id', userId)
                  .maybeSingle();
              final uni = tenantRow?['university']?.toString().trim() ?? '';
              if (uni.isNotEmpty && uni != 'null') {
                tenant['university'] = uni;
              }
            } catch (_) {}
          }
        }

        match['tenant'] = tenant;
        return match;
      }),
    );

    return {...data, 'roommate_matches': enriched};
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class AiMatchScreen extends StatefulWidget {
  const AiMatchScreen({super.key});

  @override
  State<AiMatchScreen> createState() => _AiMatchScreenState();
}

class _AiMatchScreenState extends State<AiMatchScreen> {
  final _repo = AiMatchRepository();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Myappbar(),
      backgroundColor: AppColors.themeColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      snap.error.toString().contains('profile')
                          ? 'Please complete your lifestyle survey first!'
                          : 'Could not load matches. Try again.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        color: Color(0xFF4C463C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _future = _repo.fetchMatches()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C1C1C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snap.data!;
          final propertyMatches =
              (data['property_matches'] as List? ?? [])
                  .map((e) =>
                      PropertyMatch.fromJson(e as Map<String, dynamic>))
                  .toList();
          final roommateMatches =
              (data['roommate_matches'] as List? ?? [])
                  .map((e) =>
                      RoommateMatch.fromJson(e as Map<String, dynamic>))
                  .toList();

          return RefreshIndicator(
            onRefresh: () async =>
                setState(() => _future = _repo.fetchMatches()),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Top Matches',
                        style: TextStyle(
                          color: Color(0xFF120A00),
                          fontSize: 40,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          height: 1.32,
                          letterSpacing: -1.20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${propertyMatches.length} properties · ${roommateMatches.length} roommates found',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Color(0xFF4C463C),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Top rooms',
                        style: TextStyle(
                          color: Color(0xFF120A00),
                          fontSize: 24,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.33,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (propertyMatches.isEmpty)
                        _EmptyState(
                          icon: Icons.home_outlined,
                          message:
                              'No property matches found yet.\nCheck back when more listings are available.',
                        )
                      else
                        ...propertyMatches.map((match) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _RoomCard(match: match),
                            )),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ideal Roommates',
                            style: TextStyle(
                              color: Color(0xFF120A00),
                              fontSize: 24,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                            ),
                          ),
                          Icon(Icons.tune, color: Colors.grey[600], size: 20),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (roommateMatches.isEmpty)
                        _EmptyState(
                          icon: Icons.people_outline,
                          message:
                              'No roommate matches yet.\nMore tenants will appear as they join.',
                        )
                      else
                        ...roommateMatches.map((match) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RoommateCard(match: match),
                            )),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF888888)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Room Card ────────────────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final PropertyMatch match;
  const _RoomCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final hasImage = match.imageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              SizedBox(
                height: 280,
                width: double.infinity,
                child: hasImage
                    ? Image.network(
                        match.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF2C2C2C),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white54, strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _PlaceholderImage(
                            propertyType: match.propertyType),
                      )
                    : _PlaceholderImage(propertyType: match.propertyType),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7E0B6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 14, color: Colors.black),
                      const SizedBox(width: 3),
                      Text(
                        '${match.score}% Match',
                        style: const TextStyle(
                          color: Color(0xFF251A02),
                          fontSize: 12,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: const Color(0xE5FBF9F6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Rent',
                          style: TextStyle(
                              color: Color(0xFF4C463C),
                              fontSize: 12,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500)),
                      Text(
                        'EGP ${match.rentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF120A00),
                          fontSize: 20,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          match.title.isNotEmpty ? match.title : 'Available Property',
          style: const TextStyle(
            color: Color(0xFF120A00),
            fontSize: 20,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        ...match.reasons.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    r.startsWith('⚠️')
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    size: 14,
                    color: r.startsWith('⚠️')
                        ? Colors.orange
                        : const Color(0xFF4A7C59),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      r.replaceAll('⚠️ ', ''),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Color(0xFF4C463C),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ─── Placeholder Image ────────────────────────────────────────────────────────
class _PlaceholderImage extends StatelessWidget {
  final String propertyType;
  const _PlaceholderImage({required this.propertyType});

  @override
  Widget build(BuildContext context) {
    final label = propertyType.isNotEmpty
        ? propertyType[0].toUpperCase() + propertyType.substring(1)
        : 'Property';
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C2C2C), Color(0xFF3D3D3D)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bed_outlined, color: Colors.white24, size: 60),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Roommate Card ────────────────────────────────────────────────────────────
class _RoommateCard extends StatelessWidget {
  final RoommateMatch match;
  const _RoommateCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: match.avatarUrl.isNotEmpty
                    ? Image.network(
                        match.avatarUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            match.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFE6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${match.score}% MATCH',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA07840),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match.university.isNotEmpty
                          ? match.university
                          : 'Student',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: match.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5EFE6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(tag,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF5A4A35))),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _RoommateProfileView(
                    userId: match.tenantId,
                    name: match.fullName,
                    avatarUrl: match.avatarUrl,
                    university: match.university,
                    score: match.score,
                    breakdown: match.breakdown,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('View profile',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE0D5C5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, color: Colors.grey, size: 36),
    );
  }
}

// ─── Roommate Profile View ────────────────────────────────────────────────────
class _RoommateProfileView extends StatefulWidget {
  final String userId;
  final String name;
  final String avatarUrl;
  final String university;
  final int score;
  final Map<String, dynamic> breakdown;

  const _RoommateProfileView({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.university,
    required this.score,
    required this.breakdown,
  });

  @override
  State<_RoommateProfileView> createState() => _RoommateProfileViewState();
}

class _RoommateProfileViewState extends State<_RoommateProfileView> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _bio = '';
  String _circadianRhythm = '';
  String _socialThreshold = '';
  String _smokingPreferences = '';
  String _environmentalOrder = '';
  bool _petsAllowed = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        _supabase
            .from('users')
            .select('bio')
            .eq('user_id', widget.userId)
            .maybeSingle(),
        _supabase
            .from('lifestyle_profile')
            .select(
                'circadian_rhythm, social_threshold, smoking_preferences, environmental_order, pets_allowed')
            .eq('user_id', widget.userId)
            .maybeSingle(),
      ]);

      final user = results[0];
      final lifestyle = results[1];

      if (mounted) {
        setState(() {
          _bio = user?['bio']?.toString() ?? '';
          _circadianRhythm =
              lifestyle?['circadian_rhythm']?.toString() ?? '';
          _socialThreshold =
              lifestyle?['social_threshold']?.toString() ?? '';
          _smokingPreferences =
              lifestyle?['smoking_preferences']?.toString() ?? '';
          _environmentalOrder =
              lifestyle?['environmental_order']?.toString() ?? '';
          _petsAllowed = lifestyle?['pets_allowed'] == true;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openChat(BuildContext context) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? conversationId;

      // Check if conversation exists where current user is owner
      final existing1 = await _supabase
          .from('conversation')
          .select('conversation_id')
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing1 != null) {
        final convId = existing1['conversation_id'] as String;
        final participant = await _supabase
            .from('conversation_participants')
            .select()
            .eq('conversation_id', convId)
            .eq('tenant_id', widget.userId)
            .maybeSingle();
        if (participant != null) conversationId = convId;
      }

      // Check if conversation exists where other user is owner
      if (conversationId == null) {
        final existing2 = await _supabase
            .from('conversation')
            .select('conversation_id')
            .eq('user_id', widget.userId)
            .maybeSingle();

        if (existing2 != null) {
          final convId = existing2['conversation_id'] as String;
          final participant = await _supabase
              .from('conversation_participants')
              .select()
              .eq('conversation_id', convId)
              .eq('tenant_id', currentUserId)
              .maybeSingle();
          if (participant != null) conversationId = convId;
        }
      }

      // No existing conversation — create one
      if (conversationId == null) {
        final newConv = await _supabase
            .from('conversation')
            .insert({'user_id': currentUserId})
            .select('conversation_id')
            .single();

        conversationId = newConv['conversation_id'] as String;

        await _supabase.from('conversation_participants').insert({
          'conversation_id': conversationId,
          'tenant_id': widget.userId,
        });
      }

      if (mounted) {
        Navigator.pop(context); // close loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversationId!,
              otherUserId: widget.userId,
              otherUserName: widget.name,
              otherUserAvatar:
                  widget.avatarUrl.isNotEmpty ? widget.avatarUrl : null,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open chat: $e')),
        );
      }
    }
  }

  String _fmt(String v) => v
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  double _score(String key) {
    final v = widget.breakdown[key];
    if (v == null) return 0;
    final d = (v as num).toDouble();
    return (d > 1 ? d / 100 : d).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF120A00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Roommate Profile',
            style: TextStyle(
                color: Color(0xFF120A00),
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 16)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFFD8D0C0),
                        backgroundImage: widget.avatarUrl.isNotEmpty
                            ? NetworkImage(widget.avatarUrl)
                            : null,
                        child: widget.avatarUrl.isEmpty
                            ? const Icon(Icons.person,
                                size: 52, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(widget.name,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF120A00),
                              fontFamily: 'Manrope')),
                      const SizedBox(height: 4),

                      // University
                      Text(
                          widget.university.isNotEmpty
                              ? widget.university
                              : 'Student',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4C463C),
                              fontFamily: 'Manrope')),
                      const SizedBox(height: 12),

                      // Match badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E0B6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt,
                                size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.score}% Compatibility Match',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF251A02),
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      if (_bio.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_bio,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4C463C),
                                  fontFamily: 'Manrope',
                                  height: 1.6)),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Compatibility bars
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEADEC6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('COMPATIBILITY',
                                style: TextStyle(
                                    color: Color(0xFF6A624F),
                                    fontSize: 10,
                                    fontFamily: 'Manrope',
                                    letterSpacing: 2)),
                            const SizedBox(height: 16),
                            _CompatBar(
                                label: 'Sleep Cycle',
                                progress: _score('circadian')),
                            const SizedBox(height: 10),
                            _CompatBar(
                                label: 'Social Style',
                                progress: _score('social')),
                            const SizedBox(height: 10),
                            _CompatBar(
                                label: 'Cleanliness',
                                progress: _score('cleanliness')),
                            if (widget.breakdown.containsKey('studyTime')) ...[
                              const SizedBox(height: 10),
                              _CompatBar(
                                  label: 'Study Hours',
                                  progress: _score('studyTime')),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Lifestyle chips
                      if (_circadianRhythm.isNotEmpty ||
                          _socialThreshold.isNotEmpty ||
                          _smokingPreferences.isNotEmpty ||
                          _environmentalOrder.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lifestyle',
                                  style: TextStyle(
                                      color: Color(0xFF120A00),
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_circadianRhythm.isNotEmpty)
                                    _Chip(
                                        icon: Icons.nightlight_outlined,
                                        label: _fmt(_circadianRhythm)),
                                  if (_socialThreshold.isNotEmpty)
                                    _Chip(
                                        icon: Icons.people_outline,
                                        label: _fmt(_socialThreshold)),
                                  if (_smokingPreferences.isNotEmpty)
                                    _Chip(
                                        icon: Icons.smoke_free,
                                        label: _fmt(_smokingPreferences)),
                                  if (_environmentalOrder.isNotEmpty)
                                    _Chip(
                                        icon: Icons.cleaning_services_outlined,
                                        label: _fmt(_environmentalOrder)),
                                  if (_petsAllowed)
                                    const _Chip(
                                        icon: Icons.pets, label: 'Pets OK'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Message button — opens real chat
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openChat(context),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: Text('Message ${widget.name}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── Compat Bar ───────────────────────────────────────────────────────────────
class _CompatBar extends StatelessWidget {
  final String label;
  final double progress;
  const _CompatBar({required this.label, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Manrope',
                    color: Color(0xFF4C463C))),
            Text('${(progress * 100).round()}%',
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C463C))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFD4C9B0),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF2C2005)),
          ),
        ),
      ],
    );
  }
}

// ─── Chip ─────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBeig,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4C463C)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: Color(0xFF4C463C),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}