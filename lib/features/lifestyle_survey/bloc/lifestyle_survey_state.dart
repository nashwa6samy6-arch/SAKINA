import 'package:equatable/equatable.dart';

class LifestyleSurveyState extends Equatable {
  final int currentPage;
  final String circadianRhythm; // 'Early Bird', 'Night Owl'
  final double environmentalOrder; // 0.0 to 1.0 (Relaxed to Immaculate)
  final String socialThreshold; // 'BALANCED', 'Rarely', 'Weekends Only', etc.
  final String pets; // 'None', 'Have'
  final String smoking; // 'Non-smoker', 'Smoker'
  final double studyHours; // 1.0 to 16.0
  final String studyTime; // 'Morning', 'Afternoon', etc.

  const LifestyleSurveyState({
    this.currentPage = 0,
    this.circadianRhythm = 'Night Owl', 
    this.environmentalOrder = 0.5,
    this.socialThreshold = 'BALANCED', 
    this.pets = 'None',
    this.smoking = 'Non-smoker', 
    this.studyHours = 8.0,
    this.studyTime = 'Evening',
  });

  LifestyleSurveyState copyWith({
    int? currentPage,
    String? circadianRhythm,
    double? environmentalOrder,
    String? socialThreshold,
    String? pets,
    String? smoking,
    double? studyHours,
    String? studyTime,
  }) {
    return LifestyleSurveyState(
      
      currentPage: currentPage ?? this.currentPage,
      circadianRhythm: circadianRhythm ?? this.circadianRhythm,
      environmentalOrder: environmentalOrder ?? this.environmentalOrder,
      socialThreshold: socialThreshold ?? this.socialThreshold,
      pets: pets ?? this.pets,
      smoking: smoking ?? this.smoking,
      studyHours: studyHours ?? this.studyHours,
      studyTime: studyTime ?? this.studyTime,
    );
  }

  @override
  List<Object> get props => [
        currentPage,
        circadianRhythm,
        environmentalOrder,
        socialThreshold,
        pets,
        smoking,
        studyHours,
        studyTime,
      ];
}