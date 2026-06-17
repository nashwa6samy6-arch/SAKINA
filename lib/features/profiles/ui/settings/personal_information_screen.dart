import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/core/theme/app_colors.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _universityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _universityController = TextEditingController();

    final authUser = _supabase.auth.currentUser;
    _nameController.text = authUser?.userMetadata?['full_name'] ??
        authUser?.userMetadata?['name'] ??
        authUser?.email?.split('@')[0] ??
        '';
    _emailController.text = authUser?.email ?? '';

    _fetchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final results = await Future.wait([
        _supabase
            .from('users')
            .select('full_name, email')
            .eq('user_id', userId)
            .maybeSingle(),
        _supabase
            .from('tenants')
            .select('university')
            .eq('user_id', userId)
            .maybeSingle(),
      ]);

      final user = results[0];
      final tenant = results[1];

      if (mounted) {
        setState(() {
          if (user?['full_name']?.toString().isNotEmpty == true) {
            _nameController.text = user!['full_name'];
          }
          _universityController.text = tenant?['university'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Save name to users table
      await _supabase
          .from('users')
          .update({'full_name': _nameController.text.trim()})
          .eq('user_id', userId);

      // Update university — insert if row doesn't exist yet
      final existing = await _supabase
          .from('tenants')
          .select('tenant_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('tenants')
            .update({'university': _universityController.text.trim()})
            .eq('user_id', userId);
      } else {
        await _supabase.from('tenants').insert({
          'user_id': userId,
          'university': _universityController.text.trim(),
        });
      }

      // Update auth metadata so name shows everywhere immediately
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': _nameController.text.trim()},
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information updated!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2416)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Personal Information',
            style: TextStyle(
                color: Color(0xFF2C2416),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _field('Full Name', _nameController,
                          Icons.person_outline),
                      const SizedBox(height: 16),
                      _field('Email', _emailController,
                          Icons.email_outlined,
                          enabled: false),
                      const SizedBox(height: 16),
                      _field('University', _universityController,
                          Icons.school_outlined),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fontColor,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Save Changes',
                                  style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF888888))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 15),
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, color: const Color(0xFF4C463C), size: 20),
            filled: true,
            fillColor:
                enabled ? Colors.white : const Color(0xFFF0EBE3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}