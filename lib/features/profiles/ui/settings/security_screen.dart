import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/core/theme/app_colors.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _supabase = Supabase.instance.client;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPass));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
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
        title: const Text('Security',
            style: TextStyle(
                color: Color(0xFF2C2416),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          color: Color(0xFF4C463C), size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email',
                              style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  color: Color(0xFF888888))),
                          Text(
                            _supabase.auth.currentUser?.email ?? '',
                            style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text('CHANGE PASSWORD',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Color(0xFF888888))),
                const SizedBox(height: 12),
                _passwordField('New Password', _newPasswordController,
                    _obscureNew,
                    () => setState(() => _obscureNew = !_obscureNew)),
                const SizedBox(height: 16),
                _passwordField('Confirm Password', _confirmPasswordController,
                    _obscureConfirm,
                    () => setState(() => _obscureConfirm = !_obscureConfirm)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fontColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Update Password',
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

  Widget _passwordField(String label, TextEditingController controller,
      bool obscure, VoidCallback toggle) {
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
          obscureText: obscure,
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline,
                color: Color(0xFF4C463C), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF888888),
                  size: 20),
              onPressed: toggle,
            ),
            filled: true,
            fillColor: Colors.white,
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