part of 'main_cubit.dart';

enum HomeViewType { inbox, today, calendar, someday, allTasks, label }

class MainCubitState extends Equatable {
  final bool loading;
  final HomeViewType homeViewType;
  final HomeViewType lastHomeViewType;
  final Label? selectedLabel;

  const MainCubitState({
    this.loading = false,
    this.homeViewType = HomeViewType.inbox,
    this.lastHomeViewType = HomeViewType.inbox,
    this.selectedLabel,
  });

  MainCubitState copyWith({
    bool? loading,
    HomeViewType? homeViewType,
    HomeViewType? lastHomeViewType,
    Nullable<Label?>? selectedLabel,
  }) {
    return MainCubitState(
      loading: loading ?? this.loading,
      homeViewType: homeViewType ?? this.homeViewType,
      lastHomeViewType: lastHomeViewType ?? this.lastHomeViewType,
      selectedLabel: selectedLabel == null ? this.selectedLabel : selectedLabel.value,
    );
  }

  @override
  List<Object?> get props => [loading, homeViewType, lastHomeViewType, selectedLabel];
}
