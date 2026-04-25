import 'package:flutter_bloc/flutter_bloc.dart';
import 'lifestyle_survey_event.dart';
import 'lifestyle_survey_state.dart';

class LifestyleSurveyBloc extends Bloc<LifestyleSurveyEvent, LifestyleSurveyState> {
  LifestyleSurveyBloc() : super(const LifestyleSurveyState()) {
    
    // الانتقال للصفحة التالية
    on<NextPageRequested>((event, emit) {
      if (state.currentPage < 4) {
        emit(state.copyWith(currentPage: state.currentPage + 1));
      }
    });

    // العودة للصفحة السابقة
    on<PreviousPageRequested>((event, emit) {
      if (state.currentPage > 0) {
        emit(state.copyWith(currentPage: state.currentPage - 1));
      }
    });

    // تحديث نظام الساعة البيولوجية
    on<CircadianRhythmChanged>((event, emit) {
      emit(state.copyWith(circadianRhythm: event.value));
    });

    // تحديث ترتيب البيئة المحيطة
    on<EnvironmentalOrderChanged>((event, emit) {
      emit(state.copyWith(environmentalOrder: event.value));
    });

    // تحديث مستوى التفاعل الاجتماعي (BALANCED وغيرها)
    on<SocialThresholdChanged>((event, emit) {
      emit(state.copyWith(socialThreshold: event.value));
    });

    // تحديث حالة الحيوانات الأليفة
    on<PetsChanged>((event, emit) {
      emit(state.copyWith(pets: event.value));
    });

    // تحديث حالة التدخين
    on<SmokingChanged>((event, emit) {
      emit(state.copyWith(smoking: event.value));
    });

    // تحديث عدد ساعات المذاكرة
    on<StudyHoursChanged>((event, emit) {
      emit(state.copyWith(studyHours: event.value));
    });

    // تحديث وقت المذاكرة المفضل
    on<StudyTimeChanged>((event, emit) {
      emit(state.copyWith(studyTime: event.value));
    });
  }
}