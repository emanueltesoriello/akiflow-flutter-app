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
    Nullable<User?>? user,
  }) {
    return AuthCubitState(
      loading: loading ?? this.loading,
      user: user != null ? user.value : this.user,
    );
  }

  @override
  List<Object?> get props => [loading, user];
}
