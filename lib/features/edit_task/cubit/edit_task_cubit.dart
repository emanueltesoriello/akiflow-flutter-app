import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/edit_task/ui/change_priority_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/task_extension.dart';
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

  void attachTaskAndLabel(Task task, {Label? label}) {
    emit(state.copyWith(originalTask: task, updatedTask: task, selectedLabel: label));
  }

  void setRead() {
    Task task = state.updatedTask;

    if (task.readAt == null) {
      DateTime now = DateTime.now().toUtc();

      Task updated = state.updatedTask.copyWith(
        readAt: now.toIso8601String(),
      );

      emit(state.copyWith(updatedTask: updated));
    }
  }

  Future<void> create() async {
    DateTime now = DateTime.now().toUtc();

    Task updated = state.updatedTask.copyWith(
      id: const Uuid().v4(),
      createdAt: (now.toIso8601String()),
      listId: state.selectedLabel?.id,
      readAt: now.toIso8601String(),
      sorting: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    emit(state.copyWith(updatedTask: updated));

    _tasksCubit.setJustCreatedTask(updated);

    await _tasksRepository.add([updated]);

    _tasksCubit.refreshTasksFromRepository();

    _syncCubit.sync([Entity.tasks]);

    emit(const EditTaskCubitState());
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
      datetime: Nullable(dateTime?.toIso8601String()),
      status: Nullable(statusType.id),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));

    if (forceUpdate) {
      _tasksCubit.addToUndoQueue([task], updated.status == TaskStatusType.planned.id ? UndoType.plan : UndoType.snooze);
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.refreshTasksFromRepository();
      _syncCubit.sync([Entity.tasks]);
    }
  }

  void setDuration(double value) {
    emit(state.copyWith(selectedDuration: value, showDuration: false));

    Task task = state.updatedTask;

    Task updated = task.copyWith(
      duration: value != 0 ? Nullable((value * 3600).toInt()) : Nullable(null),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void toggleDuration() {
    emit(state.copyWith(showDuration: !state.showDuration));
  }

  void toggleLabels() {
    emit(state.copyWith(showLabelsList: !state.showLabelsList, showDuration: false));
  }

  Future<void> setLabel(Label label, {bool forceUpdate = false}) async {
    Task updated = state.updatedTask.copyWith(
      listId: label.id,
      sectionId: Nullable(null),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(
      selectedLabel: label,
      showLabelsList: false,
      updatedTask: updated,
    ));

    if (forceUpdate) {
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.refreshTasksFromRepository();
      _syncCubit.sync([Entity.tasks]);
    }
  }

  Future<void> markAsDone({bool forceUpdate = false}) async {
    Task task = state.updatedTask;

    Task updated = task.markAsDone(state.originalTask);

    emit(state.copyWith(updatedTask: updated));

    if (forceUpdate) {
      _tasksCubit.addToUndoQueue([task], updated.isCompletedComputed ? UndoType.markDone : UndoType.markUndone);
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.refreshTasksFromRepository();
      _syncCubit.sync([Entity.tasks]);
    }
  }

  void removeLink(String link) {
    Task updated = state.updatedTask.copyWith(
      links: (state.updatedTask.links ?? []).where((l) => l != link).toList(),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  Future<void> delete() async {
    Task task = state.updatedTask;

    Task updated = task.copyWith(
      status: Nullable(TaskStatusType.deleted.id),
      deletedAt: (DateTime.now().toUtc().toIso8601String()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void setDeadline(DateTime? date) {
    Task task = state.updatedTask;

    Task updated = task.copyWith(
      dueDate: Nullable(date?.toIso8601String()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void toggleDailyGoal() {
    Task task = state.updatedTask;

    int currentDailyGoal = task.dailyGoal ?? 0;

    Task updated = state.updatedTask.copyWith(
      dailyGoal: currentDailyGoal == 0 ? 1 : 0,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated, showDuration: false, showLabelsList: false));
  }

  void setPriority(PriorityEnum? priority) {
    Task updated = state.updatedTask.copyWith(
      priority: priority?.value,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  Future<void> setRecurrence(RecurrenceRule? rule) async {
    List<String>? recurrence;

    if (rule != null) {
      recurrence = [rule.toString()];
    }

    Task original = state.originalTask;

    Task updated = state.updatedTask.copyWith(
      recurrence: Nullable(recurrence),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
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
  }

  Future<Task> _addTaskWithRecurrence(Task updated) async {
    RecurrenceRule rule = RecurrenceRule.fromString((updated.recurrence ?? []).join(";"));

    List<DateTime> dates = rule.getAllInstances(start: DateTime.now().toUtc());

    List<Task> tasks = [];

    String recurringId = const Uuid().v4();
    DateTime updatedAt = DateTime.now().toUtc();

    updated = updated.copyWith(
      recurrence: Nullable([rule.toString()]),
      recurringId: recurringId,
      updatedAt: Nullable(updatedAt.toIso8601String()),
    );

    await _tasksRepository.updateById(updated.id, data: updated);

    DateTime taskDate = updated.date != null ? DateTime.parse(updated.date!) : DateTime.now().toUtc();

    for (DateTime date in dates) {
      if (date.isBefore(taskDate) || (isSameDay(date, taskDate))) {
        continue;
      }

      Task newTask = updated.copyWith(
        id: const Uuid().v4(),
        date: Nullable(date.toIso8601String()),
        createdAt: updatedAt.toIso8601String(),
      );

      tasks.add(newTask);
    }

    recurrenceTasksToCreate.addAll(tasks);

    return updated;
  }

  Future<void> _removeTasksWithRecurrence(Task original, Task updated) async {
    List<Task> tasks = await _tasksRepository.getByRecurringId(original.recurringId!);

    DateTime updatedTaskDate = updated.date != null ? DateTime.parse(updated.date!) : DateTime.now().toUtc();

    for (Task task in tasks) {
      DateTime taskDate = task.date != null ? DateTime.parse(task.date!) : DateTime.now().toUtc();

      if (task.id == updated.id || taskDate.isBefore(updatedTaskDate)) {
        continue;
      }

      recurrenceTasksToUpdate.add(task.copyWith(
        recurrence: Nullable(null),
        deletedAt: DateTime.now().toUtc().toIso8601String(),
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      ));
    }
  }

  Future<void> duplicate() async {
    DateTime? now = DateTime.now().toUtc();

    Task task = state.updatedTask;

    Task newTaskDuplicated = task.copyWith(
      id: const Uuid().v4(),
      updatedAt: Nullable(now.toIso8601String()),
      createdAt: (now.toIso8601String()),
      selected: false,
    );

    await _tasksRepository.add([newTaskDuplicated]);

    _tasksCubit.refreshTasksFromRepository();

    _syncCubit.sync([Entity.tasks]);
  }

  void onTitleChanged(String value) {
    Task updated = state.updatedTask.copyWith(
      title: value,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void onDescriptionChanged(String value) {
    String html = value.replaceAll("\n", "<br>");
    Task updated = state.updatedTask.copyWith(
      description: html,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
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

      for (Task task in tasks) {
        Task updatedRecurringTask = state.updatedTask.copyWith(
          id: task.id,
          date: Nullable(task.date),
          datetime: Nullable(task.datetime),
          status: Nullable(task.status),
          createdAt: (task.createdAt),
          deletedAt: (task.deletedAt),
          globalCreatedAt: (task.globalCreatedAt),
          globalUpdatedAt: (task.globalUpdatedAt),
          readAt: (task.readAt),
          updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
        );

        updatedRecurringTasks.add(updatedRecurringTask);
      }

      for (Task task in updatedRecurringTasks) {
        await _tasksRepository.updateById(task.id!, data: task);
      }
    } else {
      Task original = state.originalTask;
      Task updated = state.updatedTask;

      _tasksCubit.addToUndoQueue([original], UndoType.updated);

      await _tasksRepository.updateById(updated.id!, data: updated);
    }

    _tasksCubit.refreshTasksFromRepository();

    _syncCubit.sync([Entity.tasks]);
  }

  void updateTitle(String value) {
    Task updated = state.updatedTask.copyWith(
      title: value,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void updateDescription(String value) {
    String html = value.replaceAll("\n", "<br>");

    Task updated = state.updatedTask.copyWith(
      description: html,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void addLink(String newLink) {
    List<String> links = state.updatedTask.links ?? [];

    links.add(newLink);

    Task updated = state.updatedTask.copyWith(
      links: links,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
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
