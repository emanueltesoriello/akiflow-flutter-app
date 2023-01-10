import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/src/base/models/chrono_model.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/change_priority_modal.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

part 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  final TasksCubit _tasksCubit;
  final SyncCubit _syncCubit;

  List<Task> recurrenceTasksToUpdate = [];
  List<Task> recurrenceTasksToCreate = [];

  EditTaskCubit(this._tasksCubit, this._syncCubit) : super(const EditTaskCubitState());

  undoChanges() {
    emit(state.copyWith(updatedTask: state.originalTask));
  }

  void attachTask(Task task) {
    emit(state.copyWith(originalTask: task, updatedTask: task));
  }

  setHasFocusOnTitleOrDescription(bool newVal) {
    emit(state.copyWith(hasFocusOnTitleOrDescription: newVal));
  }

  void setRead() {
    Task task = state.updatedTask;

    if (task.readAt == null) {
      Task updated = state.updatedTask.copyWith(
        readAt: TzUtils.toUtcStringIfNotNull(DateTime.now()),
      );

      emit(state.copyWith(updatedTask: updated));
    }
  }

  Future<void> create() async {
    try {
      if (TaskExt.hasData(state.updatedTask) == false) {
        return;
      }
      DateTime now = DateTime.now();
      Task updated = state.updatedTask.copyWith(
        id: const Uuid().v4(),
        title: state.updatedTask.title,
        description: state.updatedTask.description,
        createdAt: TzUtils.toUtcStringIfNotNull(now),
        readAt: TzUtils.toUtcStringIfNotNull(now),
        sorting: now.toUtc().millisecondsSinceEpoch,
      );

      emit(state.copyWith(updatedTask: updated));
      emit(const EditTaskCubitState());

      _tasksCubit.setJustCreatedTask(updated);
      await _tasksRepository.add([updated]);
      _tasksCubit.refreshTasksUi(updated);
      await _tasksCubit.refreshAllFromRepository();

      AnalyticsService.track("New Task");

      await _syncCubit.sync(entities: [Entity.tasks]);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> planFor(
    DateTime? date, {
    DateTime? dateTime,
    required TaskStatusType statusType,
    bool forceUpdate = false,
  }) async {
    emit(state.copyWith(selectedDate: date, showDuration: false));
    Task task = state.updatedTask;

    Task updated = task.copyWith(
      date: Nullable(date?.toIso8601String()),
      datetime: Nullable(TzUtils.toUtcStringIfNotNull(dateTime)),
      status: Nullable(statusType.id),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    if (statusType == TaskStatusType.snoozed) {
      _tasksCubit.addToUndoQueue([updated], UndoType.snooze);
    } else {
      _tasksCubit.addToUndoQueue([updated], statusType == TaskStatusType.someday ? UndoType.snooze : UndoType.plan);
    }

    emit(state.copyWith(updatedTask: updated));

    _tasksCubit.refreshTasksUi(updated);

    if (forceUpdate) {
      _tasksCubit
          .addToUndoQueue([task], updated.statusType == TaskStatusType.someday ? UndoType.snooze : UndoType.plan);
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.refreshAllFromRepository();
      _syncCubit.sync(entities: [Entity.tasks]);

      if (statusType == TaskStatusType.planned && state.originalTask.statusType == TaskStatusType.planned) {
        AnalyticsService.track("Task Rescheduled");
      } else if (statusType == TaskStatusType.inbox && date == null && dateTime == null) {
        AnalyticsService.track("Task moved to Inbox");
      } else if (statusType == TaskStatusType.planned) {
        AnalyticsService.track("Task planned");
      } else if (statusType == TaskStatusType.snoozed) {
        AnalyticsService.track("Task snoozed");
      }
    }
  }

  void setDuration(int? seconds) {
    if (seconds != null) {
      emit(state.copyWith(selectedDuration: seconds.toDouble(), showDuration: false));

      Task task = state.updatedTask;

      Task updated = task.copyWith(
        duration: seconds != 0 ? Nullable(seconds) : Nullable(null),
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
      );

      emit(state.copyWith(updatedTask: updated));

      AnalyticsService.track("Edit Task Duration");
    }
  }

  void toggleImportance() {
    emit(state.copyWith(showPriority: !state.showPriority, showDuration: false, showLabelsList: false));
  }

  void toggleDuration() {
    emit(state.copyWith(showDuration: !state.showDuration, showPriority: false, showLabelsList: false));
  }

  void toggleLabels() {
    emit(state.copyWith(showLabelsList: !state.showLabelsList, showDuration: false, showPriority: false));
  }

  Future<void> setEmptyLabel() async {
    Task updated = state.updatedTask.copyWith(
      listId: Nullable(null),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  Future<void> setLabel(Label label, {bool forceUpdate = false}) async {
    Task updated = state.updatedTask.copyWith(
      listId: Nullable(label.id),
      sectionId: Nullable(null),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(showLabelsList: false, updatedTask: updated));

    _tasksCubit.refreshTasksUi(updated);

    if (forceUpdate) {
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.refreshAllFromRepository();
      _syncCubit.sync(entities: [Entity.tasks]);
    }

    AnalyticsService.track("Edit Task Label");
  }

  Future<void> markAsDone({bool forceUpdate = false}) async {
    Task task = state.updatedTask;

    Task updated = task.markAsDone(state.originalTask);

    emit(state.copyWith(updatedTask: updated));

    _tasksCubit.refreshTasksUi(updated);

    if (forceUpdate) {
      _tasksCubit.addToUndoQueue([task], updated.isCompletedComputed ? UndoType.markDone : UndoType.markUndone);
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.refreshAllFromRepository();
      _syncCubit.sync(entities: [Entity.tasks]);
    }

    _tasksCubit.handleDocAction([updated]);

    if (updated.isCompletedComputed) {
      AnalyticsService.track("Task Done");
    } else {
      AnalyticsService.track("Task Undone");
    }
  }

  void removeLink(String link) {
    Task updated = state.updatedTask.copyWith(
      links: (state.updatedTask.links ?? []).where((l) => l != link).toList(),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  Future<void> delete() async {
    Task task = state.updatedTask;

    DateTime now = DateTime.now();
    await _tasksCubit.addToUndoQueue([task], UndoType.delete);

    Task updated = task.copyWith(
      status: Nullable(TaskStatusType.trashed.id),
      trashedAt: TzUtils.toUtcStringIfNotNull(now),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
    );

    await _tasksRepository.updateById(task.id, data: updated);

    emit(state.copyWith(updatedTask: updated));

    await _tasksCubit.refreshAllFromRepository();

    _syncCubit.sync(entities: [Entity.tasks]);
  }

  void setDeadline(DateTime? date) {
    Task task = state.updatedTask;

    Task updated = task.copyWith(
      dueDate: Nullable(date?.toIso8601String()),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void toggleDailyGoal() {
    Task task = state.updatedTask;

    int currentDailyGoal = task.dailyGoal ?? 0;

    Task updated = state.updatedTask.copyWith(
      dailyGoal: currentDailyGoal == 0 ? 1 : 0,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated, showDuration: false, showLabelsList: false));
  }

  void setPriority(PriorityEnum? priority, {int? value}) {
    Task updated = state.updatedTask.copyWith(
      priority: priority?.value ?? value,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );
    emit(state.copyWith(updatedTask: updated));
  }

  void removePriority() {
    Task updated = state.updatedTask.copyWith(
      priority: -1,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );
    emit(state.copyWith(updatedTask: updated));
  }

  Future<void> removeLabel() async {
    Task updated = state.updatedTask.copyWith(
      listId: Nullable(null),
      sectionId: Nullable(null),
    );

    emit(state.copyWith(showLabelsList: false, updatedTask: updated));

    _tasksCubit.refreshTasksUi(updated);
  }

  Future<void> setRecurrence(RecurrenceRule? rule) async {
    List<String>? recurrence;

    if (rule != null) {
      recurrence = [rule.toString()];
    }

    Task original = state.originalTask;

    Task updated = state.updatedTask.copyWith(
      recurrence: Nullable(recurrence),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));

    recurrenceTasksToUpdate.clear();
    recurrenceTasksToCreate.clear();

    if ((original.recurrence != null && original.recurrence!.isNotEmpty) &&
        (updated.recurrence == null || updated.recurrence!.isEmpty)) {
      await _removeTasksWithRecurrence(original, updated);
    } else if ((original.recurrence == null || original.recurrence!.isEmpty) &&
        (updated.recurrence != null && updated.recurrence!.isNotEmpty)) {
      updated = await _addTaskWithRecurrence(updated);
    } else {
      await _removeTasksWithRecurrence(original, updated);
      updated = await _addTaskWithRecurrence(updated);
    }

    emit(state.copyWith(updatedTask: updated));

    AnalyticsService.track("Edit Task Priority");
  }

  Future<Task> _addTaskWithRecurrence(Task updated) async {
    RecurrenceRule rule = RecurrenceRule.fromString((updated.recurrence ?? []).join(";"));

    List<Task> tasks = [];

    String recurringId = const Uuid().v4();
    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now().toUtc());

    DateTime taskDate = updated.date != null ? DateTime.parse(updated.date!) : DateTime.now().toUtc();
    DateTime taskDateTime = updated.datetime != null ? DateTime.parse(updated.datetime!) : DateTime.now().toUtc();

    updated = updated.copyWith(
      date: Nullable(taskDate.toIso8601String()),
      recurrence: Nullable([rule.toString()]),
      recurringId: recurringId,
      updatedAt: Nullable(now),
    );

    if (updated.status != TaskStatusType.planned.id) {
      updated = updated.copyWith(status: Nullable(TaskStatusType.planned.id));
    }

    await _tasksRepository.updateById(updated.id, data: updated);

    List<DateTime> dates = rule.getAllInstances(start: taskDateTime);

    for (DateTime date in dates) {
      if (date.isBefore(taskDate) || (isSameDay(date, taskDate))) {
        continue;
      }

      Task newTask = updated.copyWith(
        id: const Uuid().v4(),
        date: Nullable(date.toIso8601String()),
        datetime: updated.datetime != null ? Nullable(TzUtils.toUtcStringIfNotNull(date)) : Nullable(null),
        createdAt: now,
      );

      tasks.add(newTask);
    }

    recurrenceTasksToCreate.addAll(tasks);

    return updated;
  }

  Future<void> _removeTasksWithRecurrence(Task original, Task updated) async {
    List<Task> tasks = await _tasksRepository.getByRecurringId(original.recurringId!);

    DateTime updatedTaskDate = updated.date != null ? DateTime.parse(updated.date!) : DateTime.now();

    DateTime now = DateTime.now();

    for (Task task in tasks) {
      DateTime taskDate = task.date != null ? DateTime.parse(task.date!) : DateTime.now();

      if (task.id == updated.id || taskDate.isBefore(updatedTaskDate)) {
        continue;
      }

      recurrenceTasksToUpdate.add(task.copyWith(
        recurrence: Nullable(null),
        trashedAt: TzUtils.toUtcStringIfNotNull(now),
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
      ));
    }
  }

  Future<void> duplicate() async {
    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

    Task task = state.updatedTask;

    Task newTaskDuplicated = task.copyWith(
      id: const Uuid().v4(),
      updatedAt: Nullable(now),
      createdAt: now,
      doc: Nullable(null),
      connectorId: Nullable(null),
      originId: Nullable(null),
      originAccountId: Nullable(null),
      selected: false,
    );

    print(newTaskDuplicated.doc);
    print('===============================');
    await _tasksRepository.add([newTaskDuplicated]);

    _tasksCubit.refreshAllFromRepository();

    _syncCubit.sync(entities: [Entity.tasks]);
  }

  void onTitleChanged(String value) {
    Task updated = state.updatedTask.copyWith(
      title: value,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  modalDismissed({bool updateAllFuture = false}) async {
    if (recurrenceTasksToUpdate.isNotEmpty) {
      for (Task task in recurrenceTasksToUpdate) {
        await _tasksRepository.updateById(task.id, data: task);
      }
    }

    if (recurrenceTasksToCreate.isNotEmpty) {
      await _tasksRepository.add(recurrenceTasksToCreate);
    }

    if (updateAllFuture && state.updatedTask.recurringId != null) {
      List<Task> tasks = await _tasksRepository.getByRecurringId(state.updatedTask.recurringId!);

      DateTime? taskDate = state.updatedTask.date != null ? DateTime.parse(state.updatedTask.date!) : null;

      // Tasks selected and future
      tasks = tasks
          .where((element) =>
              element.date != null &&
              taskDate != null &&
              (isSameDay(taskDate, DateTime.parse(element.date!)) || DateTime.parse(element.date!).isAfter(taskDate)))
          .toList();

      List<Task> updatedRecurringTasks = [];

      String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

      for (Task task in tasks) {
        Task updatedRecurringTask = state.updatedTask.copyWith(
          id: task.id,
          date: Nullable(task.date),
          datetime: Nullable(task.datetime),
          status: Nullable(task.status),
          createdAt: (task.createdAt),
          trashedAt: (task.trashedAt),
          globalCreatedAt: (task.globalCreatedAt),
          globalUpdatedAt: (task.globalUpdatedAt),
          readAt: (task.readAt),
          updatedAt: Nullable(now),
        );

        updatedRecurringTasks.add(updatedRecurringTask);
      }

      for (Task task in updatedRecurringTasks) {
        await _tasksRepository.updateById(task.id!, data: task);

        _tasksCubit.refreshTasksUi(task);
      }
    } else {
      Task original = state.originalTask;
      Task updated = state.updatedTask;

      if (TaskExt.hasDataChanges(original: original, updated: updated)) {
        _tasksCubit.addToUndoQueue([original], UndoType.updated);
      }

      await _tasksRepository.updateById(updated.id!, data: updated);

      _tasksCubit.refreshTasksUi(updated);
    }

    _tasksCubit.refreshAllFromRepository();

    _syncCubit.sync(entities: [Entity.tasks]);

    AnalyticsService.track("Edit Task");
  }

  void updateTitle(String value, {List<ChronoModel>? chrono}) {
    Task updated = state.updatedTask.copyWith(
      title: value,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));

    // if (chrono != null && chrono.isNotEmpty) {
    //   _planWithChrono(chrono.first);
    // } else {
    //   planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
    // }
  }

  void _planWithChrono(ChronoModel chrono) {
    DateTime? date = chrono.impliedDate;

    if (date == null) return;

    DateTime? datetime;

    if (chrono.start?.knownValues?.hour != null && chrono.start?.knownValues?.minute != null) {
      datetime = date;
    }

    Task updated = state.updatedTask;

    TaskStatusType type = updated.statusType == TaskStatusType.planned || updated.statusType == TaskStatusType.snoozed
        ? updated.statusType!
        : TaskStatusType.planned;

    planFor(date, dateTime: datetime, statusType: type);
  }

  void updateDescription(String html) {
    Task updated = state.updatedTask.copyWith(
      description: html,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void addLink(String newLink) {
    List<String> links = state.updatedTask.links ?? [];

    links.add(newLink);

    Task updated = state.updatedTask.copyWith(
      links: links,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void linksTap() {
    emit(state.copyWith(showDuration: false, showLabelsList: false));
  }

  void deadlineTap() {
    emit(state.copyWith(showDuration: false, showLabelsList: false));
  }

  void priorityTap() {
    emit(state.copyWith(showDuration: false, showLabelsList: false));
  }

  void menuTap() {
    emit(state.copyWith(showDuration: false, showLabelsList: false));
  }

  void planTap() {
    emit(state.copyWith(showDuration: false, showLabelsList: false));
  }

  void recurrenceTap() {
    emit(state.copyWith(showDuration: false, showLabelsList: false));
  }
}
