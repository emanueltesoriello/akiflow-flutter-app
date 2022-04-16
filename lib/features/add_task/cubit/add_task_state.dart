part of 'add_task_cubit.dart';

class AddTaskCubitState extends Equatable {
  final bool loading;

  const AddTaskCubitState({
    this.loading = false,
  });

  AddTaskCubitState copyWith({
    bool? loading,
  }) {
    return AddTaskCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
