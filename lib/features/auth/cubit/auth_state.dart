part of 'auth_cubit.dart';

class AuthCubitState extends Equatable {
  final bool loading;

  const AuthCubitState({
    this.loading = false,
  });

  AuthCubitState copyWith({
    bool? loading,
  }) {
    return AuthCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
