part of 'auth_cubit.dart';

class AuthCubitState extends Equatable {
  final bool loading;
  final bool? hasValidPlan;
  final User? user;

  const AuthCubitState({
    this.loading = false,
    this.hasValidPlan,
    this.user,
  });

  AuthCubitState copyWith({
    bool? loading,
    bool? hasValidPlan,
    bool? authenticated,
    Nullable<User?>? user,
  }) {
    return AuthCubitState(
      loading: loading ?? this.loading,
      hasValidPlan: hasValidPlan ?? this.hasValidPlan,
      user: user != null ? user.value : this.user,
    );
  }

  @override
  List<Object?> get props => [loading, hasValidPlan, user];
}
