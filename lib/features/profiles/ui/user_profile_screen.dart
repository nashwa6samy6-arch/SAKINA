import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_app_bar.dart';
import 'package:sakina/features/profiles/ui/widgets/account_setting.dart';
import 'package:sakina/features/profiles/ui/widgets/profile_header.dart';
import 'package:sakina/features/profiles/ui/widgets/preferences_section.dart';
import 'package:sakina/features/profiles/ui/widgets/privacy_section.dart';
import 'package:sakina/features/profiles/ui/widgets/split_bill_section.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();

  bool _showProfileToPublic = true;
  bool _electricitySplit = true;
  bool _waterSplit = false;
  bool _isLoading = true;
  bool _isUploading = false;

  String _fullName = '';
  String _university = '';
  String _avatarUrl = '';
  String _bio = '';
  String _circadianRhythm = '';
  String _socialThreshold = '';
  String _smokingPreferences = '';
  String _environmentalOrder = '';
  bool _petsAllowed = false;

  @override
  void initState() {
    super.initState();
    final authUser = _supabase.auth.currentUser;
    _fullName = authUser?.userMetadata?['full_name'] ??
        authUser?.userMetadata?['name'] ??
        authUser?.email?.split('@')[0] ??
        'Unknown';
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final results = await Future.wait([
        _supabase
            .from('users')
            .select('full_name, email, avatar_url, bio, is_verified')
            .eq('user_id', userId)
            .maybeSingle(),
        _supabase
            .from('tenants')
            .select('university')
            .eq('user_id', userId)
            .maybeSingle(),
        _supabase
            .from('lifestyle_profile')
            .select(
                'circadian_rhythm, social_threshold, smoking_preferences, environmental_order, pets_allowed')
            .eq('user_id', userId)
            .maybeSingle(),
      ]);

      final user = results[0];
      final tenant = results[1];
      final lifestyle = results[2];

      if (mounted) {
        setState(() {
          final dbName = user?['full_name']?.toString() ?? '';
          if (dbName.isNotEmpty) _fullName = dbName;
          _avatarUrl = user?['avatar_url'] ?? '';
          _bio = user?['bio'] ?? '';
          _university = tenant?['university'] ?? '';
          _circadianRhythm = lifestyle?['circadian_rhythm'] ?? '';
          _socialThreshold = lifestyle?['social_threshold'] ?? '';
          _smokingPreferences = lifestyle?['smoking_preferences'] ?? '';
          _environmentalOrder = lifestyle?['environmental_order'] ?? '';
          _petsAllowed = lifestyle?['pets_allowed'] ?? false;
          if (_bio.isEmpty) _bio = _buildBio();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _buildBio() {
    final parts = <String>[];
    if (_circadianRhythm.isNotEmpty) {
      parts.add(_circadianRhythm.replaceAll('_', ' '));
    }
    if (_socialThreshold.isNotEmpty) parts.add(_socialThreshold);
    if (_smokingPreferences.isNotEmpty) {
      parts.add(_smokingPreferences.replaceAll('_', ' '));
    }
    if (_petsAllowed) parts.add('pet-friendly');
    if (parts.isEmpty) return '';
    return 'A ${parts.join(', ')} student looking for the right living space and compatible roommates.';
  }

  String _formatLabel(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  Future<void> _editPhoto() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            if (_avatarUrl.isNotEmpty)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == null) return;

    if (action == 'remove') {
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return;
        await _supabase
            .from('users')
            .update({'avatar_url': null}).eq('user_id', userId);
        if (mounted) setState(() => _avatarUrl = '');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove photo: $e')),
          );
        }
      }
      return;
    }

    final source =
        action == 'gallery' ? ImageSource.gallery : ImageSource.camera;
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final bytes = await picked.readAsBytes();
      final fileName = 'avatar_$userId.jpg';

      await _supabase.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
                contentType: 'image/jpeg', upsert: true),
          );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      // Save clean URL to DB
      await _supabase
          .from('users')
          .update({'avatar_url': url}).eq('user_id', userId);

      if (mounted) {
        // Clear Flutter image cache
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
        setState(() {
          _avatarUrl = '$url?t=$timestamp';
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: $e')),
        );
      }
    }
  }

  Future<void> _editBio() async {
    final controller = TextEditingController(text: _bio);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Bio',
            style: TextStyle(
                fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Tell others about yourself…',
            hintStyle: const TextStyle(color: Color(0xFF9A9088)),
            filled: true,
            fillColor: const Color(0xFFF5F3F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF9A8762))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fontColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      await _supabase
          .from('users')
          .update({'bio': result}).eq('user_id', userId);
      if (mounted) setState(() => _bio = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save bio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: Myappbar(
        showProfile: false,
        title: 'Sakina',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AccountSettingsScreen())),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProfile,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_isUploading)
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: const LinearProgressIndicator(),
                          ),
                        ProfileHeader(
                          name: _fullName,
                          university: _university.isNotEmpty
                              ? _university
                              : 'University not set',
                          bio: _bio,
                          imageUrl: _avatarUrl,
                          onEditPhoto: _editPhoto,
                          onEditBio: _editBio,
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBeig,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: Text('Verified Resident',
                              style: TextStyle(
                                color: const Color(0xFF6A624F),
                                fontSize: 14.sp,
                                fontFamily: 'Manrope',
                              )),
                        ),
                        SizedBox(height: 24.h),
                        if (_circadianRhythm.isNotEmpty ||
                            _socialThreshold.isNotEmpty ||
                            _environmentalOrder.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3F0),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lifestyle',
                                    style: TextStyle(
                                      color: const Color(0xFF120A00),
                                      fontSize: 16.sp,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w600,
                                    )),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [
                                    if (_circadianRhythm.isNotEmpty)
                                      _chip(Icons.nightlight_outlined,
                                          _formatLabel(_circadianRhythm)),
                                    if (_socialThreshold.isNotEmpty)
                                      _chip(Icons.people_outline,
                                          _formatLabel(_socialThreshold)),
                                    if (_environmentalOrder.isNotEmpty)
                                      _chip(
                                          Icons.cleaning_services_outlined,
                                          _formatLabel(_environmentalOrder)),
                                    if (_smokingPreferences.isNotEmpty)
                                      _chip(Icons.smoke_free,
                                          _formatLabel(_smokingPreferences)),
                                    if (_petsAllowed)
                                      _chip(Icons.pets, 'Pets OK'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 24.h),
                        const PreferencesSection(),
                        SizedBox(height: 24.h),
                        PrivacySection(
                          showProfileToPublic: _showProfileToPublic,
                          onToggle: (val) =>
                              setState(() => _showProfileToPublic = val),
                        ),
                        SizedBox(height: 24.h),
                        SplitBillSection(
                          electricitySplit: _electricitySplit,
                          waterSplit: _waterSplit,
                          onElectricityToggle: (val) =>
                              setState(() => _electricitySplit = val),
                          onWaterToggle: (val) =>
                              setState(() => _waterSplit = val),
                        ),
                        SizedBox(height: 32.h),
                        Text(
                          'App Version 2.4.0',
                          style: TextStyle(
                            color: const Color(0xFF4C463C)
                                .withValues(alpha: 0.5),
                            fontSize: 12.sp,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        SizedBox(height: 64.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBeig,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: const Color(0xFF4C463C)),
          SizedBox(width: 6.w),
          Text(label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.sp,
                color: const Color(0xFF4C463C),
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}