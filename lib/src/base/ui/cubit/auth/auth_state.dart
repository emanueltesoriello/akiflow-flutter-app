part of 'auth_cubit.dart';

class AuthCubitState extends Equatable {
  final bool loading;
  final bool hasValidPlan;
  final User? user;
  final bool authenticated;

  const AuthCubitState({
    this.loading = false,
    this.hasValidPlan = true,
    this.user,
    this.authenticated = false,
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
        authenticated: authenticated ?? this.authenticated);
  }

  @override
  List<Object?> get props => [loading, hasValidPlan, user, authenticated];
}
