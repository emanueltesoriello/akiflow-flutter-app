part of 'home_cubit.dart';

enum HomeViewType { inbox, today, calendar }

class HomeCubitState extends Equatable {
  final bool loading;
  final HomeViewType homeViewType;

  const HomeCubitState({
    this.loading = false,
    this.homeViewType = HomeViewType.inbox,
  });

  HomeCubitState copyWith({
    bool? loading,
    HomeViewType? homeViewType,
  }) {
    return HomeCubitState(
      loading: loading ?? this.loading,
      homeViewType: homeViewType ?? this.homeViewType,
    );
  }

  @override
  List<Object?> get props => [loading, homeViewType];
}
