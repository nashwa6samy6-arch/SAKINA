import 'package:sakina/core/utils/app_dialogs.dart';
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
import 'package:sakina/features/auth/login_screen.dart';
import 'package:sakina/features/lifestyle_survey/ui/screens/lifestyle_survey_screen.dart';
import 'package:sakina/generated/locale_keys.g.dart';
import 'package:sakina/landlord/dashboard_screen.dart';
import 'package:sakina/features/auth/widgets/custom_gender_dropdown.dart';
import 'package:sakina/utils/universities.dart';



class SignUpScreen extends StatefulWidget {
  final String role;
  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();

  String? selectedGender;
  String? selectedUniversity;
  bool get isTenant => widget.role == 'tenant';
  bool get isLandlord => widget.role == 'landlord';
  bool isAgreed = false;

  @override
  void dispose() {
    nameController.dispose();
    universityController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nationalIdController.dispose();
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
                    ? const DashboardScreen() // landlord goes here
                    : const LifestyleSurveyScreen(), // tenant goes here
              ),
            );
          } else if (state is AuthFailure) {
            Navigator.pop(context); // close loading dialog
            showErrorDialog(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.themeColor,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        Text(
                          LocaleKeys.signup_header.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            letterSpacing: 1.2,
                            color: AppColors.primaryBrown,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          LocaleKeys.signup_title.tr(),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // RichedText
                        Customtextrich(
                          tapped: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(role: widget.role),
                            ),
                          ),
                          textTitle: LocaleKeys.signup_subtitle.tr(),
                          textButton: LocaleKeys.signup_signin_link.tr(),
                        ),

                        SizedBox(height: 30.h),

                        // full name
                        CustomTextFormField(
                          controller: nameController,
                          hintText: LocaleKeys.signup_full_name_placeholder.tr(),
                          labelText: LocaleKeys.signup_full_name_label.tr(),
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                        SizedBox(height: 20.h),

                        // gender dropdown
                        CustomGenderDropdown(
                          value: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                        ),
                        SizedBox(height: 20.h),

                        if (isTenant) ...[
                          CustomTextFormField(
                            hintText: LocaleKeys.signup_university_placeholder.tr(),
                            labelText: LocaleKeys.signup_university_label.tr(),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedUniversity,
                              onChanged: (value) {
                                setState(() {
                                  selectedUniversity = value;
                                  universityController.text = value ?? '';
                                });
                              },
                              dropdownColor: AppColors.themeColor,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                              decoration: InputDecoration(
                                fillColor: AppColors.textFieldBackground,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: -7.3.w, vertical: 12.h),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: AppColors.primaryBeig),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: AppColors.primaryBrown),
                                ),
                              ),
                              items: egyptianUniversities.map((uni) {
                                return DropdownMenuItem<String>(
                                  value: uni,
                                  child: Text(
                                    uni,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          CustomTextFormField(
                            controller: emailController,
                            hintText:
                                LocaleKeys.signup_university_email_placeholder.tr(),
                            labelText:
                                LocaleKeys.signup_university_email_label.tr(),
                            keyboardType: TextInputType.emailAddress,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],

                        if (isLandlord) ...[
                          CustomTextFormField(
                            controller: emailController,
                            hintText: LocaleKeys.email_placeholder.tr(),
                            labelText: LocaleKeys.email_label.tr(),
                            keyboardType: TextInputType.emailAddress,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          CustomTextFormField(
                            controller: nationalIdController,
                            hintText: 'enter you national id',
                            labelText: 'NATIONAL ID',
                            keyboardType: TextInputType.number,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                            validators: (value) {
                              if (value == null || value.isEmpty) {
                                return 'enter your national id';
                              }
                              if (value.length != 14) {
                                return 'national id should be 14 numbers';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                        ],

                        // password
                        CustomTextFormField(
                          controller: passwordController,
                          hintText: "........",
                          labelText: LocaleKeys.signup_password_label.tr(),
                          secured: true,
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 20.sp),
                        ),

                        SizedBox(height: 15.h),
                        

                      
                        // terms & conditions checkbox
    Row(
      children: [
        Checkbox(
          value: isAgreed,
          activeColor: AppColors.primaryBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          onChanged: (value) {
            setState(() {
              isAgreed = value!;
            });
          },
        ),
        Expanded(
          child: Text(
            LocaleKeys.signup_terms_text.tr(),
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    ),

    SizedBox(height: 25.h),

    // sign up button
    Builder(
      builder: (context) => CustomAppButton(
        text: LocaleKeys.signup_title.tr(),
        onPressed: isAgreed
            ? () {
                context.read<AuthBloc>().add(
                  SignUpRequested(
                    email: emailController.text,
                    password: passwordController.text,
                    fullName: nameController.text,
                    university: universityController.text,
                    role: widget.role,
                    gender: selectedGender ?? '',
                  ),
                );
              }
            : () {},
      ),
    ),

                        SizedBox(height: 30.h),

                        SocialAuthButtons(
                          googleLabel: LocaleKeys.google_auth.tr(),
                          appleLabel: LocaleKeys.apple_auth.tr(),
                          onGoogleTap: () {
                            AuthRepository().signInWithGoogle(role: widget.role);
                          },
                          onAppleTap: () {
                            AuthRepository().signInWithMicrosoft(role: widget.role);
                          },
                        ),

                        SizedBox(height: 30.h),

                        // Footer (Copyright)
                        Center(
                          child: Text(
                            LocaleKeys.signup_copyright.tr(),
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
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
        ),
      ),
    );
  }
}