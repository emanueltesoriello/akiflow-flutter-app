part of 'edit_task_cubit.dart';

enum EditTaskPlanType { plan, snooze }

class EditTaskCubitState extends Equatable {
  final bool loading;
  final Task newTask;
  final DateTime? selectedDate;
  final double? selectedDuration;
  final bool setDuration;
  final bool showLabelsList;
  final Label? selectedLabel;

  const EditTaskCubitState({
    this.loading = false,
    required this.newTask,
    this.selectedDate,
    this.selectedDuration,
    this.setDuration = false,
    this.showLabelsList = false,
    this.selectedLabel,
  });

  EditTaskCubitState copyWith({
    bool? loading,
    Task? newTask,
    DateTime? selectedDate,
    double? selectedDuration,
    bool? setDuration,
    bool? showLabelsList,
    Label? selectedLabel,
  }) {
    return EditTaskCubitState(
      loading: loading ?? this.loading,
      newTask: newTask ?? this.newTask,
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
        newTask,
        selectedDate,
        selectedDuration,
        setDuration,
        showLabelsList,
        selectedLabel,
      ];
}
