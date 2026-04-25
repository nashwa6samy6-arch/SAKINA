import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class LifestyleSurveyScreen extends StatefulWidget {
  const LifestyleSurveyScreen({super.key});

  @override
  State<LifestyleSurveyScreen> createState() => _LifestyleSurveyScreenState();
}

class _LifestyleSurveyScreenState extends State<LifestyleSurveyScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        child: Scaffold(
          backgroundColor: AppColors.themeColor,
          appBar: LifestyleAppBar(),
          body: Column(
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
                    onBack: () => context.read<LifestyleSurveyBloc>().add(
                      PreviousPageRequested(),
                    ),
                    // داخل LifestyleSurveyScreen جوه الـ onNext
                    onNext: () {
                      if (state.currentPage == 4) {
                        // السيرفاي خلصت؟ وديه للهوم بتاع المستأجر
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HomePage(), // الصفحة الرئيسية للـ Tenant
                          ),
                        );
                      } else {
                        context.read<LifestyleSurveyBloc>().add(
                          NextPageRequested(),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
