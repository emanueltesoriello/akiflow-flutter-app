part of 'home_cubit.dart';

class HomeCubitState extends Equatable {
  final bool loading;

  const HomeCubitState({
    this.loading = false,
  });

  HomeCubitState copyWith({
    bool? loading,
  }) {
    return HomeCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
