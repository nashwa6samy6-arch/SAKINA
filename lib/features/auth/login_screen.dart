import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/core/widgets/custom_app_button.dart';
import 'package:sakina/core/widgets/custom_text_form_field.dart';
import 'package:sakina/core/widgets/custom_text_rich.dart';
import 'package:sakina/features/auth/bloc/auth_bloc.dart';
import 'package:sakina/features/auth/bloc/auth_event.dart';
import 'package:sakina/features/auth/bloc/auth_state.dart';
import 'package:sakina/features/auth/repository/auth_repository.dart';
import 'package:sakina/features/auth/widgets/social_auth_buttons.dart';
import 'package:sakina/features/auth/sign_up_screen.dart';
import 'package:sakina/generated/locale_keys.g.dart';
import 'package:sakina/pages/home.dart';
import 'package:sakina/landlord/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(AuthRepository()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
               builder: (context) => widget.role == 'landlord'
               ? const DashboardScreen()  // landlord goes here
               : const HomePage(),       // tenant goes here
  ),
);
          } else if (state is AuthFailure) {
            Navigator.pop(context); // close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.themeColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    Text(
                      LocaleKeys.header.tr(),
                      style: TextStyle(fontSize: 12.sp, letterSpacing: 1.2),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      LocaleKeys.title.tr(),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      LocaleKeys.subtitle.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 40.h),

                    // email
                    CustomTextFormField(
                      controller: emailController,
                      hintText: LocaleKeys.email_placeholder.tr(),
                      labelText: LocaleKeys.email_label.tr(),
                      keyboardType: TextInputType.emailAddress,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),

                    SizedBox(height: 22.h),

                    // password
                    CustomTextFormField(
                      controller: passwordController,
                      hintText: ".......",
                      labelText: LocaleKeys.password_label.tr(),
                      secured: true,
                      keyboardType: TextInputType.visiblePassword,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 20.sp),
                      validators: (value) {
                        if (value == null || value.isEmpty) {
                          return LocaleKeys.please_enter_password.tr();
                        }
                        return null;
                      },
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

                    SizedBox(height: 20.h),

                    // login button
                    Builder(
                      builder: (context) => CustomAppButton(
                        text: LocaleKeys.title.tr(),
                        onPressed: () {
                          context.read<AuthBloc>().add(LoginRequested(
                            email: emailController.text,
                            password: passwordController.text,
                            role: widget.role,
                          ));
                        },
                      ),
                    ),

                    SizedBox(height: 40.h),

                    SocialAuthButtons(
                      googleLabel: LocaleKeys.google_auth.tr(),
                      appleLabel: LocaleKeys.apple_auth.tr(),
                      onGoogleTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Google Login Tapped!")),
                        );
                      },
                      onAppleTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Apple Login Tapped!")),
                        );
                      },
                    ),

                    SizedBox(height: 40.h),

                    // footer
                    Center(
                      child: Customtextrich(
                        tapped: () {
                          Navigator.push(
                           context,
                             MaterialPageRoute(
                              builder: (context) => SignUpScreen(role: widget.role),
                             ),
                          );
                        },
                        textTitle: LocaleKeys.footer_text.tr(),
                        textButton: LocaleKeys.apply_for_residency.tr(),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
