part of 'add_task_cubit.dart';

enum AddTaskPlanType { plan, snooze }

class AddTaskCubitState extends Equatable {
  final bool loading;
  final AddTaskPlanType planType;
  final Task newTask;

  const AddTaskCubitState({
    this.loading = false,
    this.planType = AddTaskPlanType.plan,
    required this.newTask,
  });

  AddTaskCubitState copyWith({
    bool? loading,
    AddTaskPlanType? planType,
    Task? newTask,
  }) {
    return AddTaskCubitState(
      loading: loading ?? this.loading,
      planType: planType ?? this.planType,
      newTask: newTask ?? this.newTask,
    );
  }

  @override
  List<Object?> get props => [loading, planType, newTask];
}
