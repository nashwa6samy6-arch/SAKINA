import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/features/role/ui/role_screen.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileScreen extends StatefulWidget {
  final String fullName;
  final String bio;
  final String? avatarUrl;

  const EditProfileScreen({
    super.key,
    required this.fullName,
    required this.bio,
    this.avatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;

  static const Color bg = Color(0xFFF5F3EF);
  static const Color card = Color(0xFFEEE9DF);
  static const Color brown = Color(0xFF1B1209);
  static const Color muted = Color(0xFF7A746C);
  static const Color border = Color(0xFFE8E1D7);

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  final _formKey = GlobalKey<FormState>();

  dynamic _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _bioController = TextEditingController(text: widget.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _selectedImage = bytes);
      } else {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      String? avatarUrl;

      if (_selectedImage != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_avatar.jpg';

        if (kIsWeb) {
          await supabase.storage
              .from('avatars')
              .uploadBinary(fileName, _selectedImage);
        } else {
          await supabase.storage
              .from('avatars')
              .upload(fileName, _selectedImage);
        }

        avatarUrl =
            supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      final updateData = <String, dynamic>{
        'full_name': _nameController.text,
        'bio': _bioController.text,
      };

      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      await supabase
          .from('users')
          .update(updateData)
          .eq('user_id', userId);

      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameController.text,
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! ✅'),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF4C463C),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF9A8762),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Supabase.instance.client.auth.signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const RoleScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: brown,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: brown,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100.r,
                            height: 100.r,
                            decoration: BoxDecoration(
                              color: card,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: border,
                                width: 3.r,
                              ),
                            ),
                            child: ClipOval(
                              child: _selectedImage != null
                                  ? (kIsWeb
                                      ? Image.memory(
                                          _selectedImage,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          _selectedImage,
                                          fit: BoxFit.cover,
                                        ))
                                  : widget.avatarUrl != null &&
                                          widget.avatarUrl!.isNotEmpty
                                      ? Image.network(
                                          widget.avatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Icon(
                                            Icons.person,
                                            size: 50.r,
                                            color: muted,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 50.r,
                                          color: muted,
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                color: brown,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16.r,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Bio
                    _buildTextField(
                      controller: _bioController,
                      label: 'About Me',
                      hint: 'Tell students about yourself...',
                      maxLines: 4,
                    ),

                    SizedBox(height: 32.h),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _logout(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                          ),
                          side: const BorderSide(
                            color: muted,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: muted,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: brown,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: brown,
            fontSize: 15.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: card,
            contentPadding: EdgeInsets.all(16.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: brown,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}