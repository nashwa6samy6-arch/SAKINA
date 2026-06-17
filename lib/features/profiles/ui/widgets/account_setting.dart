import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/features/role/ui/role_screen.dart';
import 'package:sakina/features/profiles/ui/settings/personal_information_screen.dart';
import 'package:sakina/features/profiles/ui/settings/security_screen.dart';
import 'package:sakina/features/profiles/ui/settings/privacy_screen.dart';
import 'package:sakina/features/profiles/ui/settings/notifications_settings_screen.dart';
import 'package:sakina/features/profiles/ui/settings/translation_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out',
            style: TextStyle(
                fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        content: const Text(
          'Are you sure you want to log out?',
          style:
              TextStyle(fontFamily: 'Manrope', color: Color(0xFF4C463C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF9A8762))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
        MaterialPageRoute(builder: (_) => const RoleScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.person_outline, 'label': 'Personal information', 'route': 0},
      {'icon': Icons.shield_outlined, 'label': 'Security', 'route': 1},
      {'icon': Icons.lock_outline, 'label': 'Privacy', 'route': 2},
      {'icon': Icons.notifications_none_outlined, 'label': 'Notifications', 'route': 3},
      {'icon': Icons.credit_card_outlined, 'label': 'Payments', 'route': -1},
      {'icon': Icons.translate_outlined, 'label': 'Translation', 'route': 4},
      {'icon': Icons.accessibility_new_outlined, 'label': 'Accessibility', 'route': -1},
      {'icon': Icons.switch_account_outlined, 'label': 'Switch account', 'route': -1},
    ];

    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2416)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Account settings',
            style: TextStyle(
                color: Color(0xFF2C2416),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 56,
                    endIndent: 16,
                    color: Color(0xFFD4C4A8),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      leading: Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFF2C2416),
                        size: 22,
                      ),
                      title: Text(
                        item['label'] as String,
                        style: const TextStyle(
                            color: Color(0xFF2C2416),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      trailing: item['route'] == -1
                          ? const Text('Soon',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFAA9880),
                                  fontFamily: 'Manrope'))
                          : const Icon(Icons.chevron_right,
                              color: Color(0xFFAA9880), size: 20),
                      onTap: () {
                        final route = item['route'] as int;
                        if (route == -1) return;
                        final screens = [
                          PersonalInformationScreen(),
                          SecurityScreen(),
                          PrivacySettingsScreen(),
                          NotificationsSettingsScreen(),
                          TranslationScreen(),
                        ];
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => screens[route]),
                        );
                      },
                    );
                  },
                ),
              ),

              // ── Logout button ───────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Log Out',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'VERSION 26.13 (204595)',
                  style: TextStyle(
                      color: const Color(0xFF8B7355),
                      fontSize: 11,
                      letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}