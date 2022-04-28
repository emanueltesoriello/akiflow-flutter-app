part of 'add_task_cubit.dart';

enum AddTaskPlanType { plan, snooze }

class AddTaskCubitState extends Equatable {
  final bool loading;
  final AddTaskPlanType planType;
  final Task newTask;
  final DateTime? selectedDate;
  final double? selectedDuration;
  final bool setDuration;

  const AddTaskCubitState({
    this.loading = false,
    this.planType = AddTaskPlanType.plan,
    required this.newTask,
    this.selectedDate,
    this.selectedDuration,
    this.setDuration = false,
  });

  AddTaskCubitState copyWith({
    bool? loading,
    AddTaskPlanType? planType,
    Task? newTask,
    DateTime? selectedDate,
    double? selectedDuration,
    bool? setDuration,
  }) {
    return AddTaskCubitState(
      loading: loading ?? this.loading,
      planType: planType ?? this.planType,
      newTask: newTask ?? this.newTask,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      setDuration: setDuration ?? this.setDuration,
    );
  }

  @override
  List<Object?> get props =>
      [loading, planType, newTask, selectedDate, selectedDuration, setDuration];
}
