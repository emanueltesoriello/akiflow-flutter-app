part of 'main_cubit.dart';

enum HomeViewType { inbox, today, calendar }

class MainCubitState extends Equatable {
  final bool loading;
  final HomeViewType homeViewType;

  const MainCubitState({
    this.loading = false,
    this.homeViewType = HomeViewType.inbox,
  });

  MainCubitState copyWith({
    bool? loading,
    HomeViewType? homeViewType,
  }) {
    return MainCubitState(
      loading: loading ?? this.loading,
      homeViewType: homeViewType ?? this.homeViewType,
    );
  }

  @override
  List<Object?> get props => [loading, homeViewType];
}
