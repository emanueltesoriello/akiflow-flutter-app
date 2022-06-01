part of 'edit_task_cubit.dart';

enum EditTaskPlanType { plan, snooze }

class EditTaskCubitState extends Equatable {
  final bool loading;
  final Task originalTask;
  final Task updatedTask;
  final DateTime? selectedDate;
  final double? selectedDuration;
  final bool setDuration;
  final bool showLabelsList;
  final Label? selectedLabel;

  const EditTaskCubitState({
    this.loading = false,
    this.originalTask = const Task(),
    this.updatedTask = const Task(),
    this.selectedDate,
    this.selectedDuration,
    this.setDuration = false,
    this.showLabelsList = false,
    this.selectedLabel,
  });

  EditTaskCubitState copyWith({
    bool? loading,
    Task? originalTask,
    Task? updatedTask,
    DateTime? selectedDate,
    double? selectedDuration,
    bool? setDuration,
    bool? showLabelsList,
    Label? selectedLabel,
  }) {
    return EditTaskCubitState(
      loading: loading ?? this.loading,
      originalTask: originalTask ?? this.originalTask,
      updatedTask: updatedTask ?? this.updatedTask,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      setDuration: setDuration ?? this.setDuration,
      showLabelsList: showLabelsList ?? this.showLabelsList,
      selectedLabel: selectedLabel ?? this.selectedLabel,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        originalTask,
        updatedTask,
        selectedDate,
        selectedDuration,
        setDuration,
        showLabelsList,
        selectedLabel,
      ];
}
