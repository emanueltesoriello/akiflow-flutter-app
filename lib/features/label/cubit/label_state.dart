part of 'label_cubit.dart';

class LabelCubitState extends Equatable {
  final bool loading;
  final Label? selectedLabel;
  final List<Task>? tasks;

  const LabelCubitState({
    this.loading = false,
    this.selectedLabel,
    this.tasks,
  });

  LabelCubitState copyWith({
    bool? loading,
    Label? selectedLabel,
    List<Task>? tasks,
  }) {
    return LabelCubitState(
      loading: loading ?? this.loading,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [loading, selectedLabel, tasks];
}
