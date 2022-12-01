part of 'main_cubit.dart';

enum HomeViewType {
  inbox,
  today,
  availability,
  someday,
  allTasks,
  label,
  calendar,
}

class MainCubitState extends Equatable {
  final bool loading;
  final HomeViewType homeViewType;
  final HomeViewType lastHomeViewType;

  const MainCubitState({
    this.loading = false,
    this.homeViewType = HomeViewType.inbox,
    this.lastHomeViewType = HomeViewType.inbox,
  });

  MainCubitState copyWith({
    bool? loading,
    HomeViewType? homeViewType,
    HomeViewType? lastHomeViewType,
  }) {
    return MainCubitState(
      loading: loading ?? this.loading,
      homeViewType: homeViewType ?? this.homeViewType,
      lastHomeViewType: lastHomeViewType ?? this.lastHomeViewType,
    );
  }

  @override
  List<Object?> get props => [loading, homeViewType, lastHomeViewType];
}
