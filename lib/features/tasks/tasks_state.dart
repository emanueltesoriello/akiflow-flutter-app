part of 'tasks_cubit.dart';

enum UndoType { markDone, markUndone, delete, restore, plan, snooze, moveToInbox, updated }

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
      case UndoType.updated:
        return t.task.undoActions.updated;
    }
  }
}

class UndoTask {
  final Task task;
  final UndoType type;

  UndoTask(this.task, this.type);
}

class TasksCubitState extends Equatable {
  final List<Task> inboxTasks;
  final List<Task> selectedDayTasks;
  final List<Task> labelTasks;
  final List<Task> fixedTodayTasks;
  final List<Doc> docs;
  final String? syncStatus;
  final List<UndoTask> queue;
  final Task? justCreatedTask;
  final bool tasksLoaded;
  final bool loading;

  int get todayCount =>
      fixedTodayTasks.where((element) => !element.isCompletedComputed && element.isTodayOrBefore).toList().length;

  const TasksCubitState({
    this.inboxTasks = const [],
    this.selectedDayTasks = const [],
    this.labelTasks = const [],
    this.fixedTodayTasks = const [],
    this.docs = const [],
    this.syncStatus,
    this.queue = const [],
    this.justCreatedTask,
    this.tasksLoaded = false,
    this.loading = false,
  });

  TasksCubitState copyWith({
    List<Task>? inboxTasks,
    List<Task>? selectedDayTasks,
    List<Task>? labelTasks,
    List<Task>? fixedTodayTasks,
    List<Doc>? docs,
    String? syncStatus,
    List<UndoTask>? queue,
    Nullable<Task?>? justCreatedTask,
    bool? tasksLoaded,
    bool? loading,
  }) {
    return TasksCubitState(
      inboxTasks: inboxTasks ?? this.inboxTasks,
      selectedDayTasks: selectedDayTasks ?? this.selectedDayTasks,
      labelTasks: labelTasks ?? this.labelTasks,
      fixedTodayTasks: fixedTodayTasks ?? this.fixedTodayTasks,
      docs: docs ?? this.docs,
      syncStatus: syncStatus ?? this.syncStatus,
      queue: queue ?? this.queue,
      justCreatedTask: justCreatedTask != null ? justCreatedTask.value : this.justCreatedTask,
      tasksLoaded: tasksLoaded ?? this.tasksLoaded,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [
        inboxTasks,
        selectedDayTasks,
        labelTasks,
        fixedTodayTasks,
        docs,
        syncStatus,
        queue,
        justCreatedTask,
        tasksLoaded,
        loading,
      ];
}
