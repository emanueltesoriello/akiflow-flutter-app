part of 'tasks_cubit.dart';

class TasksCubitState extends Equatable {
  final bool loading;
  final List<Task> tasks;
  final List<Task> updatedTasks;
  final List<Label> labels;
  final List<Doc> docs;
  final String? syncStatus;

  const TasksCubitState({
    this.loading = false,
    this.tasks = const [],
    this.updatedTasks = const [],
    this.labels = const [],
    this.docs = const [],
    this.syncStatus,
  });

  TasksCubitState copyWith({
    bool? loading,
    List<Task>? tasks,
    List<Task>? updatedTasks,
    List<Label>? labels,
    List<Doc>? docs,
    String? syncStatus,
  }) {
    return TasksCubitState(
      loading: loading ?? this.loading,
      tasks: tasks ?? this.tasks,
      updatedTasks: updatedTasks ?? this.updatedTasks,
      labels: labels ?? this.labels,
      docs: docs ?? this.docs,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        tasks,
        updatedTasks,
        labels,
        docs,
        syncStatus,
      ];
}
