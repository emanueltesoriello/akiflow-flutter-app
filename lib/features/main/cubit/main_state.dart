part of 'main_cubit.dart';

enum HomeViewType { inbox, today, calendar, someday, allTasks, label }

class MainCubitState extends Equatable {
  final bool loading;
  final HomeViewType homeViewType;
  final Label? selectedLabel;

  const MainCubitState({
    this.loading = false,
    this.homeViewType = HomeViewType.inbox,
    this.selectedLabel,
  });

  MainCubitState copyWith({
    bool? loading,
    HomeViewType? homeViewType,
    Label? selectedLabel,
  }) {
    return MainCubitState(
      loading: loading ?? this.loading,
      homeViewType: homeViewType ?? this.homeViewType,
      selectedLabel: selectedLabel ?? this.selectedLabel,
    );
  }

  @override
  List<Object?> get props => [loading, homeViewType, selectedLabel];
}
