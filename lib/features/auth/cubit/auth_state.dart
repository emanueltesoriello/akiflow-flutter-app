part of 'auth_cubit.dart';

class AuthCubitState extends Equatable {
  final bool loading;
  final User? user;

  const AuthCubitState({
    this.loading = false,
    this.user,
  });

  AuthCubitState copyWith({
    bool? loading,
    User? user,
  }) {
    return AuthCubitState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [loading, user];
}
