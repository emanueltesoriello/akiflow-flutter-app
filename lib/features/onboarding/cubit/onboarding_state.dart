part of 'onboarding_cubit.dart';

class OnboardingCubitState extends Equatable {
  final bool show;
  final int page;
  final List<Account> gmailAccounts;

  const OnboardingCubitState({
    this.show = true,
    this.page = 0,
    this.gmailAccounts = const [],
  });

  OnboardingCubitState copyWith({
    bool? show,
    int? page,
    List<Account>? gmailAccounts,
  }) {
    return OnboardingCubitState(
      show: show ?? this.show,
      page: page ?? this.page,
      gmailAccounts: gmailAccounts ?? this.gmailAccounts,
    );
  }

  @override
  List<Object?> get props => [show, page, gmailAccounts];
}
