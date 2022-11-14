/*part of 'base_cubit.dart';

// NOT USED
class BaseCubitState extends Equatable {
  final bool dialogShown;
  final bool userLogged;
  final bool hasValidPlan;
  final bool isLoading;

  const BaseCubitState({
    this.dialogShown = false,
    this.userLogged = false,
    this.hasValidPlan = false,
    this.isLoading = false,
  });

  BaseCubitState copyWith({
    bool? dialogShown,
    bool? userLogged,
    bool? hasValidPlan,
    bool? isLoading,
  }) {
    return BaseCubitState(
      dialogShown: dialogShown ?? this.dialogShown,
      userLogged: userLogged ?? this.userLogged,
      hasValidPlan: hasValidPlan ?? this.hasValidPlan,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [dialogShown, userLogged, hasValidPlan, isLoading];
}
*/