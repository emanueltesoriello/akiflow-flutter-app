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
  final List<Task> calendarTasks;
  final List<Task> allTasks;
  final List<UndoTask> queue;
  final Task? justCreatedTask;
  final bool tasksLoaded;
  final bool loading;
  final DateTime? lastTaskDoneAt;
  final DateTime? lastDayInboxZero;
  final DateTime? lastDayTodayZero;

  int get todayCount =>
      fixedTodayTasks.where((element) => !element.isCompletedComputed && element.isTodayOrBefore).toList().length;

  const TasksCubitState({
    this.inboxTasks = const [],
    this.selectedDayTasks = const [],
    this.labelTasks = const [],
    this.fixedTodayTasks = const [],
    this.calendarTasks = const [],
    this.allTasks = const [],
    this.queue = const [],
    this.justCreatedTask,
    this.tasksLoaded = false,
    this.loading = false,
    this.lastTaskDoneAt,
    this.lastDayInboxZero,
    this.lastDayTodayZero,
  });

  TasksCubitState copyWith({
    List<Task>? inboxTasks,
    List<Task>? selectedDayTasks,
    List<Task>? labelTasks,
    List<Task>? fixedTodayTasks,
    List<Task>? calendarTasks,
    List<Task>? allTasks,
    List<UndoTask>? queue,
    Nullable<Task?>? justCreatedTask,
    bool? tasksLoaded,
    bool? loading,
    DateTime? lastTaskDoneAt,
    DateTime? lastDayInboxZero,
    DateTime? lastDayTodayZero,
  }) {
    return TasksCubitState(
      inboxTasks: inboxTasks ?? this.inboxTasks,
      selectedDayTasks: selectedDayTasks ?? this.selectedDayTasks,
      labelTasks: labelTasks ?? this.labelTasks,
      fixedTodayTasks: fixedTodayTasks ?? this.fixedTodayTasks,
      calendarTasks: calendarTasks ?? this.calendarTasks,
      allTasks: allTasks ?? this.allTasks,
      queue: queue ?? this.queue,
      justCreatedTask: justCreatedTask != null ? justCreatedTask.value : this.justCreatedTask,
      tasksLoaded: tasksLoaded ?? this.tasksLoaded,
      loading: loading ?? this.loading,
      lastTaskDoneAt: lastTaskDoneAt ?? this.lastTaskDoneAt,
      lastDayInboxZero: lastDayInboxZero ?? this.lastDayInboxZero,
      lastDayTodayZero: lastDayTodayZero ?? this.lastDayTodayZero,
    );
  }

  @override
  List<Object?> get props => [
        inboxTasks,
        selectedDayTasks,
        labelTasks,
        fixedTodayTasks,
        calendarTasks,
        allTasks,
        queue,
        justCreatedTask,
        tasksLoaded,
        loading,
        lastTaskDoneAt,
        lastDayInboxZero,
        lastDayTodayZero,
      ];
}
