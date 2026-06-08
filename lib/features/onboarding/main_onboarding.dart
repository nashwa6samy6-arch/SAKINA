import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sakina/features/onboarding/ui/widget/custom_onboarding.dart';
import 'package:sakina/generated/locale_keys.g.dart';

class MainOnboarding extends StatefulWidget {
  const MainOnboarding({super.key});

  @override
  State<MainOnboarding> createState() => _MainOnboardingState();
}

class _MainOnboardingState extends State<MainOnboarding> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> onboardingList = [
      CustomOnboarding(
        url: "assets/pictures/onboarding1.png",
        title: LocaleKeys.right_place.tr(),
        description: LocaleKeys.search_description.tr(),
        stepPath: "assets/icons/step1.svg",
        backButton: false,
        nextButton: true,
        getStartButton: false,
        nextTapped: _nextPage,
      ),
      CustomOnboarding(
        url: "assets/pictures/onboarding2.png",
        title: LocaleKeys.verified_safe.tr(),
        description: LocaleKeys.verified_description.tr(),
        stepPath: "assets/icons/step2.svg",
        backButton: true,
        nextButton: true,
        getStartButton: false,
        nextTapped: _nextPage,
        backTapped: _previousPage,
      ),
      CustomOnboarding(
        url: "assets/pictures/onboarding3.png",
        title: LocaleKeys.discover_services.tr(),
        description: LocaleKeys.services_description.tr(),
        stepPath: "assets/icons/step3.svg",
        backButton: true,
        nextButton: true,
        getStartButton: false,
        nextTapped: _nextPage,
        backTapped: _previousPage,
      ),
      CustomOnboarding(
        url: "assets/pictures/onboarding4.png",
        title: LocaleKeys.get_started.tr(),
        description: LocaleKeys.get_started_description.tr(),
        stepPath: "assets/icons/step3.svg",
        backButton: true,
        nextButton: false,
        getStartButton: true,
        backTapped: _previousPage,
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: onboardingList,
      ),
    );
  }
}
