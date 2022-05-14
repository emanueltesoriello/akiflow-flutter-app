part of 'tasks_cubit.dart';

enum UndoType { markDone, markUndone, delete, restore, plan, snooze, moveToInbox }

extension UndoTypeExtension on UndoType {
  String get text {
    switch (this) {
      case UndoType.markDone:
        return t.task.undoActions.markDone;
      case UndoType.markUndone:
        return t.task.undoActions.markUndone;
      case UndoType.delete:
        return t.task.undoActions.deleted;
      case UndoType.restore:
        return t.task.undoActions.restored;
      case UndoType.plan:
        return t.task.undoActions.planned;
      case UndoType.snooze:
        return t.task.undoActions.snoozed;
      case UndoType.moveToInbox:
        return t.task.undoActions.movedToInbox;
    }
  }
}

class UndoTask {
  final Task task;
  final UndoType type;

  UndoTask(this.task, this.type);
}

class TasksCubitState extends Equatable {
  final bool loading;
  final List<Task> inboxTasks;
  final List<Task> todayTasks;
  final List<Label> labels;
  final List<Doc> docs;
  final String? syncStatus;
  final List<UndoTask> queue;

  const TasksCubitState({
    this.loading = false,
    this.inboxTasks = const [],
    this.todayTasks = const [],
    this.labels = const [],
    this.docs = const [],
    this.syncStatus,
    this.queue = const [],
  });

  TasksCubitState copyWith({
    bool? loading,
    List<Task>? inboxTasks,
    List<Task>? todayTasks,
    List<Label>? labels,
    List<Doc>? docs,
    String? syncStatus,
    List<UndoTask>? queue,
  }) {
    return TasksCubitState(
      loading: loading ?? this.loading,
      inboxTasks: inboxTasks ?? this.inboxTasks,
      todayTasks: todayTasks ?? this.todayTasks,
      labels: labels ?? this.labels,
      docs: docs ?? this.docs,
      syncStatus: syncStatus ?? this.syncStatus,
      queue: queue ?? this.queue,
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
        queue,
      ];
}
