part of 'tasks_cubit.dart';

class TasksCubitState extends Equatable {
  final bool loading;
  final List<Task> tasks;
  final List<Label> labels;
  final List<Doc> docs;

  const TasksCubitState({
    this.loading = false,
    this.tasks = const [],
    this.labels = const [],
    this.docs = const [],
  });

  TasksCubitState copyWith({
    bool? loading,
    List<Task>? tasks,
    List<Label>? labels,
    List<Doc>? docs,
  }) {
    return TasksCubitState(
      loading: loading ?? this.loading,
      tasks: tasks ?? this.tasks,
      labels: labels ?? this.labels,
      docs: docs ?? this.docs,
    );
  }

  @override
  List<Object?> get props => [loading, tasks, labels, docs];
}
