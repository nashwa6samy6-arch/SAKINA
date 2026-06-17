import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/core/theme/app_colors.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;

  bool _showProfile = true;
  bool _showUniversity = true;
  bool _showOnlineStatus = true;
  bool _allowMessages = true;
  bool _shareLifestyle = true;
  bool _dataAnalytics = false;

  String? _privacyId;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final row = await _supabase
          .from('privacy_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (row != null) {
            _privacyId = row['id']?.toString();
            _showProfile = row['show_profile'] ?? true;
            _showUniversity = row['show_university'] ?? true;
            _showOnlineStatus = row['show_online_status'] ?? true;
            _allowMessages = row['allow_messages'] ?? true;
            _shareLifestyle = row['share_lifestyle'] ?? true;
            _dataAnalytics = row['data_analytics'] ?? false;
          }
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

      final data = {
        'user_id': userId,
        'show_profile': _showProfile,
        'show_university': _showUniversity,
        'show_online_status': _showOnlineStatus,
        'allow_messages': _allowMessages,
        'share_lifestyle': _shareLifestyle,
        'data_analytics': _dataAnalytics,
      };

      if (_privacyId != null) {
        await _supabase
            .from('privacy_settings')
            .update(data)
            .eq('id', _privacyId!);
      } else {
        final result = await _supabase
            .from('privacy_settings')
            .insert(data)
            .select('id')
            .single();
        _privacyId = result['id']?.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings saved!')),
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
        title: const Text('Privacy',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('PROFILE VISIBILITY', [
                        _toggle('Show Profile to Public', _showProfile,
                            (v) => setState(() => _showProfile = v)),
                        _toggle('Show University', _showUniversity,
                            (v) => setState(() => _showUniversity = v)),
                        _toggle('Show Online Status', _showOnlineStatus,
                            (v) => setState(() => _showOnlineStatus = v)),
                      ]),
                      const SizedBox(height: 24),
                      _section('COMMUNICATION', [
                        _toggle('Allow Messages from Others', _allowMessages,
                            (v) => setState(() => _allowMessages = v)),
                        _toggle('Share Lifestyle Profile', _shareLifestyle,
                            (v) => setState(() => _shareLifestyle = v)),
                      ]),
                      const SizedBox(height: 24),
                      _section('DATA', [
                        _toggle('Analytics & Improvements', _dataAnalytics,
                            (v) => setState(() => _dataAnalytics = v)),
                      ]),
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
                              : const Text('Save Settings',
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

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF888888))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Color(0xFF2C2416))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.fontColor,
            inactiveTrackColor: const Color(0xFFE4E2DF),
          ),
        ],
      ),
    );
  }
}