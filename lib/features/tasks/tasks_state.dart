part of 'tasks_cubit.dart';

class TasksCubitState extends Equatable {
  final bool loading;
  final List<Task> inboxTasks;
  final List<Task> todayTasks;
  final List<Label> labels;
  final List<Doc> docs;
  final String? syncStatus;

  const TasksCubitState({
    this.loading = false,
    this.inboxTasks = const [],
    this.todayTasks = const [],
    this.labels = const [],
    this.docs = const [],
    this.syncStatus,
  });

  TasksCubitState copyWith({
    bool? loading,
    List<Task>? inboxTasks,
    List<Task>? todayTasks,
    List<Label>? labels,
    List<Doc>? docs,
    String? syncStatus,
  }) {
    return TasksCubitState(
      loading: loading ?? this.loading,
      inboxTasks: inboxTasks ?? this.inboxTasks,
      todayTasks: todayTasks ?? this.todayTasks,
      labels: labels ?? this.labels,
      docs: docs ?? this.docs,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        inboxTasks,
        todayTasks,
        labels,
        docs,
        syncStatus,
      ];
}
