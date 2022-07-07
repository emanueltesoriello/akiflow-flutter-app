part of 'onboarding_cubit.dart';

class OnboardingCubitState extends Equatable {
  final bool show;
  final int page;

  const OnboardingCubitState({
    this.show = true,
    this.page = 0,
  });

  OnboardingCubitState copyWith({
    bool? show,
    int? page,
  }) {
    return OnboardingCubitState(
      show: show ?? this.show,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [show, page];
}
