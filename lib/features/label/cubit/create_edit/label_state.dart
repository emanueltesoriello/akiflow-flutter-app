part of 'label_cubit.dart';

class LabelCubitState extends Equatable {
  final bool loading;
  final Label? selectedLabel;
  final List<Task>? tasks;
  final TaskListSorting sorting;

  const LabelCubitState({
    this.loading = false,
    this.selectedLabel,
    this.tasks,
    this.sorting = TaskListSorting.descending,
  });

  LabelCubitState copyWith({
    bool? loading,
    Label? selectedLabel,
    List<Task>? tasks,
    TaskListSorting? sorting,
  }) {
    return LabelCubitState(
      loading: loading ?? this.loading,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      tasks: tasks ?? this.tasks,
      sorting: sorting ?? this.sorting,
    );
  }

  @override
  List<Object?> get props => [loading, selectedLabel, tasks, sorting];
}
