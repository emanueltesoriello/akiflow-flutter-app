part of 'tasks_cubit.dart';

class TasksCubitState extends Equatable {
  final bool loading;
  final List<Task> tasks;
  final List<Label> labels;

  const TasksCubitState({
    this.loading = false,
    this.tasks = const [],
    this.labels = const [],
  });

  TasksCubitState copyWith({
    bool? loading,
    List<Task>? tasks,
    List<Label>? labels,
  }) {
    return TasksCubitState(
      loading: loading ?? this.loading,
      tasks: tasks ?? this.tasks,
      labels: labels ?? this.labels,
    );
  }

  @override
  List<Object?> get props => [loading, tasks, labels];
}
