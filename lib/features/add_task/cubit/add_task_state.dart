part of 'add_task_cubit.dart';

enum AddTaskPlanType { plan, snooze }

class AddTaskCubitState extends Equatable {
  final bool loading;
  final AddTaskPlanType planType;
  final Task newTask;
  final DateTime? selectedDate;
  final double? selectedDuration;
  final bool setDuration;
  final bool showLabelsList;
  final Label? selectedLabel;

  const AddTaskCubitState({
    this.loading = false,
    this.planType = AddTaskPlanType.plan,
    required this.newTask,
    this.selectedDate,
    this.selectedDuration,
    this.setDuration = false,
    this.showLabelsList = false,
    this.selectedLabel,
  });

  AddTaskCubitState copyWith({
    bool? loading,
    AddTaskPlanType? planType,
    Task? newTask,
    DateTime? selectedDate,
    double? selectedDuration,
    bool? setDuration,
    bool? showLabelsList,
    Label? selectedLabel,
  }) {
    return AddTaskCubitState(
      loading: loading ?? this.loading,
      planType: planType ?? this.planType,
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
        planType,
        newTask,
        selectedDate,
        selectedDuration,
        setDuration,
        showLabelsList,
        selectedLabel,
      ];
}
