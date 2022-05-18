part of 'label_cubit.dart';

class LabelCubitState extends Equatable {
  final bool loading;
  final Label? selectedLabel;
  final List<Task>? tasks;
  final TaskListSorting sorting;
  final bool showDone;

  const LabelCubitState({
    this.loading = false,
    this.selectedLabel,
    this.tasks,
    this.sorting = TaskListSorting.descending,
    this.showDone = false,
  });

  LabelCubitState copyWith({
    bool? loading,
    Label? selectedLabel,
    List<Task>? tasks,
    TaskListSorting? sorting,
    bool? showDone,
  }) {
    return LabelCubitState(
      loading: loading ?? this.loading,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      tasks: tasks ?? this.tasks,
      sorting: sorting ?? this.sorting,
      showDone: showDone ?? this.showDone,
    );
  }

  @override
  List<Object?> get props => [loading, selectedLabel, tasks, sorting, showDone];
}
