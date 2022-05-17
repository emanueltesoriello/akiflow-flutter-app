part of 'label_cubit.dart';

class LabelCubitState extends Equatable {
  final bool loading;
  final User? user;

  const LabelCubitState({
    this.loading = false,
    this.user,
  });

  LabelCubitState copyWith({
    bool? loading,
    Nullable<User?>? user,
  }) {
    return LabelCubitState(
      loading: loading ?? this.loading,
      user: user != null ? user.value : this.user,
    );
  }

  @override
  List<Object?> get props => [loading, user];
}
