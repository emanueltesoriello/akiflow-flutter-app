part of 'edit_task_cubit.dart';

enum EditTaskPlanType { plan, snooze }

class EditTaskCubitState extends Equatable {
  final bool loading;
  final Task originalTask;
  final Task updatedTask;
  final DateTime? selectedDate;
  final double? selectedDuration;
  final bool showDuration;
  final bool showLabelsList;

  const EditTaskCubitState({
    this.loading = false,
    this.originalTask = const Task(),
    this.updatedTask = const Task(),
    this.selectedDate,
    this.selectedDuration,
    this.showDuration = false,
    this.showLabelsList = false,
  });

  EditTaskCubitState copyWith({
    bool? loading,
    Task? originalTask,
    Task? updatedTask,
    DateTime? selectedDate,
    double? selectedDuration,
    bool? showDuration,
    bool? showLabelsList,
  }) {
    return EditTaskCubitState(
      loading: loading ?? this.loading,
      originalTask: originalTask ?? this.originalTask,
      updatedTask: updatedTask ?? this.updatedTask,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      showDuration: showDuration ?? this.showDuration,
      showLabelsList: showLabelsList ?? this.showLabelsList,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        originalTask,
        updatedTask,
        selectedDate,
        selectedDuration,
        showDuration,
        showLabelsList,
      ];
}
