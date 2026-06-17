import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_bloc.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_event.dart';
import 'package:sakina/features/lifestyle_survey/bloc/lifestyle_survey_state.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/lifestyle_app_bar.dart';
import 'package:sakina/features/lifestyle_survey/ui/widgets/survey_navigation_bar.dart';
import 'package:sakina/pages/home.dart';
import 'steps/step1_intro_screen.dart';
import 'steps/step2_circadian_rhythm.dart';
import 'steps/step3_social_environment.dart';
import 'steps/step4_pets.dart';
import 'steps/step5_study_preferences.dart';

// ─── Value normalizers ────────────────────────────────────────────────────────
// The UI shows display strings; the DB + edge function expect snake_case enums.

String _normalizeCircadian(String v) {
  switch (v.toLowerCase().replaceAll(' ', '_')) {
    case 'early_bird':
      return 'early_bird';
    case 'night_owl':
      return 'night_owl';
    default:
      return 'flexible';
  }
}

String _normalizeSocial(String v) {
  final lower = v.toLowerCase();
  if (lower.contains('introvert') || lower.contains('rarely')) {
    return 'introverted';
  }
  if (lower.contains('extravert') ||
      lower.contains('extrovert') ||
      lower.contains('frequent') ||
      lower.contains('socialite')) {
    return 'extroverted';
  }
  // 'Weekends Only', 'Varies', 'BALANCED', etc.
  return 'balanced';
}

String _normalizeSmoking(String v) {
  final lower = v.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
  if (lower.contains('non')) return 'non_smoker';
  if (lower.contains('outside')) return 'outside_only';
  return 'smoker';
}

String _normalizeEnvironment(double v) {
  // slider is 0.0 → 1.0
  if (v < 0.34) return 'relaxed';
  if (v < 0.67) return 'moderate';
  return 'immaculate';
}

String _normalizeStudyTime(String v) {
  final lower = v.toLowerCase();
  if (lower.contains('morning')) return 'morning';
  if (lower.contains('afternoon')) return 'afternoon';
  if (lower.contains('evening')) return 'evening';
  // 'Late night', 'night', etc.
  return 'night';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LifestyleSurveyScreen extends StatefulWidget {
  const LifestyleSurveyScreen({super.key});

  @override
  State<LifestyleSurveyScreen> createState() => _LifestyleSurveyScreenState();
}

class _LifestyleSurveyScreenState extends State<LifestyleSurveyScreen> {
  final PageController _pageController = PageController();
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Saves (upsert) the lifestyle profile to Supabase, then navigates home.
  Future<void> _submitSurvey(LifestyleSurveyState state) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showError('You must be logged in to save your profile.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profileId = const Uuid().v4();

      await Supabase.instance.client.from('lifestyle_profile').upsert(
        {
          'profile_id': profileId,
          'user_id': userId,
          'circadian_rhythm': _normalizeCircadian(state.circadianRhythm),
          'environmental_order': _normalizeEnvironment(state.environmentalOrder),
          'social_threshold': _normalizeSocial(state.socialThreshold),
          'pets_allowed': state.pets == 'Have',
          'smoking_preferences': _normalizeSmoking(state.smoking),
          'study_hours': state.studyHours.round(),
          'study_time': _normalizeStudyTime(state.studyTime),
        },
        onConflict: 'user_id', // if a row already exists for this user, update it
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Could not save your profile. Please try again.\n$e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LifestyleSurveyBloc(),
      child: BlocListener<LifestyleSurveyBloc, LifestyleSurveyState>(
        listenWhen: (previous, current) =>
            previous.currentPage != current.currentPage,
        listener: (context, state) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.themeColor,
              appBar: LifestyleAppBar(),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            StepIntroScreen(),
                            StepCircadianRhythm(),
                            StepSocialEnvironment(),
                            StepPets(),
                            StepStudyPreferences(),
                          ],
                        ),
                      ),
                      BlocBuilder<LifestyleSurveyBloc, LifestyleSurveyState>(
                        builder: (context, state) {
                          return SurveyNavigationBar(
                            isFirstPage: state.currentPage == 0,
                            isLastPage: state.currentPage == 4,
                            onBack: () => context
                                .read<LifestyleSurveyBloc>()
                                .add(PreviousPageRequested()),
                            onNext: () {
                              if (state.currentPage == 4) {
                                // Last step — save to Supabase then go home
                                _submitSurvey(state);
                              } else {
                                context
                                    .read<LifestyleSurveyBloc>()
                                    .add(NextPageRequested());
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Full-screen loading overlay while saving
            if (_isSaving)
              const ColoredBox(
                color: Color(0x88000000),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Saving your profile…',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Manrope',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}