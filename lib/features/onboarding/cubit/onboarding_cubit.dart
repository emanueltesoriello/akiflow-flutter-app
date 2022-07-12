import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';

part 'onboarding_state.dart';

enum OnboardingNextAction { none, reset, next, close }

class OnboardingCubit extends Cubit<OnboardingCubitState> {
  static const int onboardingSteps = 3;

  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  OnboardingCubit() : super(const OnboardingCubitState()) {
    bool onboardingCompleted = _preferencesRepository.onboardingCompleted;

    if (onboardingCompleted == false) {
      emit(state.copyWith(show: true));
    }
  }

  void back() {
    if (state.page == 0) {
      return;
    }

    emit(state.copyWith(page: state.page - 1));

    next(reset: true);
  }

  OnboardingNextAction next({bool reset = false}) {
    if (state.page == onboardingSteps + 1) {
      return OnboardingNextAction.none;
    }

    if (reset == false) {
      emit(state.copyWith(page: state.page + 1));
    } else {
      return OnboardingNextAction.reset;
    }

    if (state.page == onboardingSteps + 1) {
      emit(state.copyWith(show: false));
      return OnboardingNextAction.close;
    } else {
      return OnboardingNextAction.next;
    }
  }

  void onboardingCompleted() {
    _preferencesRepository.setOnboardingCompleted(true);
  }

  void skipAll() {
    emit(state.copyWith(show: false));
    onboardingCompleted();
  }
}
