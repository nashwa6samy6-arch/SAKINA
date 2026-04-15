import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_text_rich.dart';
import 'package:sakina/features/dalia/login/ui/widgets/custom_auth_field.dart';
import 'package:sakina/features/dalia/sign_up/ui/sign_up_screen.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  LocaleKeys.header.tr(),
                  style: const TextStyle(fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKeys.title.tr(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKeys.subtitle.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email Field
                CustomAuthField(
                  label: LocaleKeys.email_label.tr(),
                  hintText: LocaleKeys.email_placeholder.tr(),
                ),
                const SizedBox(height: 20),

                // Password Field
                CustomAuthField(
                  label: LocaleKeys.password_label.tr(),
                  hintText: "********",
                  isPassword: true,
                  suffixIcon: const Icon(Icons.visibility_outlined, size: 20),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      LocaleKeys.forgot_password.tr(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D240E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.login_button.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Center(
                  child: Text(
                    LocaleKeys.divider_text.tr(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // --- NEW: Social Buttons Implementation ---
                Row(
                  children: [
                    Expanded(
                      child: _socialButton(
                        LocaleKeys.google_auth.tr(),
                        Icons.g_mobiledata,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _socialButton(
                        LocaleKeys.apple_auth.tr(),
                        Icons.apple,
                      ),
                    ),
                  ],
                ),
                // ------------------------------------------

                const SizedBox(height: 40),

                // Footer Section
                Center(
                  child: Customtextrich(
                    tapped: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    textTitle: LocaleKeys.footer_text.tr(),
                    textButton: LocaleKeys.apply_for_residency.tr(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Google/Apple Buttons
  Widget _socialButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {
      },
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Colors.grey, width: 0.5), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}