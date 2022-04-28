part of 'add_task_cubit.dart';

enum AddTaskPlanType { plan, snooze }

class AddTaskCubitState extends Equatable {
  final bool loading;
  final AddTaskPlanType planType;

  const AddTaskCubitState({
    this.loading = false,
    this.planType = AddTaskPlanType.plan,
  });

  AddTaskCubitState copyWith({
    bool? loading,
    AddTaskPlanType? planType,
  }) {
    return AddTaskCubitState(
      loading: loading ?? this.loading,
      planType: planType ?? this.planType,
    );
  }

  @override
  List<Object?> get props => [loading, planType];
}
