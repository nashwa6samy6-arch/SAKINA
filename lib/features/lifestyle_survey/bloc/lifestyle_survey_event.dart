import 'package:equatable/equatable.dart';

abstract class LifestyleSurveyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NextPageRequested extends LifestyleSurveyEvent {}

class PreviousPageRequested extends LifestyleSurveyEvent {}

class CircadianRhythmChanged extends LifestyleSurveyEvent {
  final String value;
  CircadianRhythmChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class EnvironmentalOrderChanged extends LifestyleSurveyEvent {
  final double value;
  EnvironmentalOrderChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SocialThresholdChanged extends LifestyleSurveyEvent {
  final String value;
  SocialThresholdChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PetsChanged extends LifestyleSurveyEvent {
  final String value;
  PetsChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SmokingChanged extends LifestyleSurveyEvent {
  final String value;
  SmokingChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class StudyHoursChanged extends LifestyleSurveyEvent {
  final double value;
  StudyHoursChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class StudyTimeChanged extends LifestyleSurveyEvent {
  final String value;
  StudyTimeChanged(this.value);
  @override
  List<Object?> get props => [value];
}
