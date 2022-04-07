part of 'home_cubit.dart';

class HomeCubitState extends Equatable {
  final bool loading;
  final int currentViewIndex;

  const HomeCubitState({
    this.loading = false,
    this.currentViewIndex = 1,
  });

  HomeCubitState copyWith({
    bool? loading,
    int? currentViewIndex,
  }) {
    return HomeCubitState(
      loading: loading ?? this.loading,
      currentViewIndex: currentViewIndex ?? this.currentViewIndex,
    );
  }

  @override
  List<Object?> get props => [loading, currentViewIndex];
}
