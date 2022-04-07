part of 'tasks_cubit.dart';

class TasksCubitState extends Equatable {
  final bool loading;
  final List<Task> tasks;

  const TasksCubitState({
    this.loading = false,
    this.tasks = const [],
  });

  TasksCubitState copyWith({
    bool? loading,
    List<Task>? tasks,
  }) {
    return TasksCubitState(
      loading: loading ?? this.loading,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [loading, tasks];
}
