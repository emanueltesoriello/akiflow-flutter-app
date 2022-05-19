import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
import 'package:uuid/uuid.dart';

part 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  final TasksCubit _tasksCubit;
  final LabelsCubit _labelsCubit;

  EditTaskCubit(
    this._tasksCubit,
    this._labelsCubit, {
    Task? task,
    TaskStatusType? taskStatusType,
    DateTime? date,
    Label? label,
    Label? section,
  }) : super(EditTaskCubitState(
          originalTask: _buildTask(task, taskStatusType, date, label, section),
          updatedTask: _buildTask(task, taskStatusType, date, label, section),
          selectedLabel: label,
        ));

  static Task _buildTask(
    Task? task,
    TaskStatusType? taskStatusType,
    DateTime? date,
    Label? label,
    Label? section,
  ) {
    return task ??
        const Task().copyWith(
          status: Nullable(taskStatusType != null ? taskStatusType.id : task?.status),
          date: Nullable((taskStatusType == TaskStatusType.planned && date != null) ? date.toIso8601String() : null),
          listId: label?.id,
          sectionId: section?.id,
        );
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

  Future<void> create({
    required String title,
    required String description,
  }) async {
    DateTime now = DateTime.now().toUtc();

    Task updated = state.updatedTask.copyWith(
      id: const Uuid().v4(),
      title: title,
      description: description,
      updatedAt: Nullable(now.toIso8601String()),
      createdAt: (now.toIso8601String()),
      listId: state.selectedLabel?.id,
      readAt: now.toIso8601String(),
    );

    emit(state.copyWith(updatedTask: updated));
    _labelsCubit.updateUiOfTask(updated);

    await _tasksRepository.add([updated]);

    _tasksCubit.updateUiOfTask(updated);

    _tasksCubit.syncAll();
    _labelsCubit.syncAllAndRefresh();
  }

  Future<void> planFor(
    DateTime? date, {
    DateTime? dateTime,
    required TaskStatusType statusType,
    bool forceUpdate = false,
  }) async {
    emit(state.copyWith(selectedDate: date));

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
      _tasksCubit.updateUiOfTask(updated);
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.syncAll();
    }
  }

  void setDuration(double value) {
    emit(state.copyWith(selectedDuration: value));

    Task task = state.updatedTask;

    double seconds = value * 3600;

    Task updated = task.copyWith(
      duration: Nullable(seconds.toInt()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void toggleDuration() {
    emit(state.copyWith(setDuration: !state.setDuration));

    if (state.setDuration == false) {
      Task updated = state.updatedTask.copyWith(
        duration: Nullable(null),
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      emit(state.copyWith(updatedTask: updated));
    }
  }

  void toggleLabels() {
    emit(state.copyWith(showLabelsList: !state.showLabelsList));
  }

  Future<void> setLabel(Label label, {bool forceUpdate = false}) async {
    Task updated = state.updatedTask.copyWith(
      listId: label.id,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(
      selectedLabel: label,
      showLabelsList: false,
      updatedTask: updated,
    ));

    if (forceUpdate) {
      _tasksCubit.updateUiOfTask(updated);
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.syncAll();
    }
  }

  Future<void> markAsDone({bool forceUpdate = false}) async {
    Task task = state.updatedTask;

    Task updated = task.markAsDone(state.originalTask);

    emit(state.copyWith(updatedTask: updated));

    if (forceUpdate) {
      _tasksCubit.addToUndoQueue([task], updated.isCompletedComputed ? UndoType.markDone : UndoType.markUndone);
      _tasksCubit.updateUiOfTask(updated);
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.syncAll();
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

    emit(state.copyWith(updatedTask: updated));
  }

  void changePriority() {
    Task updated = state.updatedTask.changePriority();

    emit(state.copyWith(updatedTask: updated));
  }

  void setRecurrence(RecurrenceRule? rule) {
    List<String>? recurrence = [];

    if (rule != null) {
      String recurrenceString = rule.toString();
      recurrence = recurrenceString.split(';');
    }

    Task updated = state.updatedTask.copyWith(
      recurrence: Nullable(recurrence),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
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

    _tasksCubit.updateUiOfTask(newTaskDuplicated);

    await _tasksRepository.add([newTaskDuplicated]);

    _tasksCubit.syncAll();
  }

  void onTitleChanged(String value) {
    Task updated = state.updatedTask.copyWith(
      title: value,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void onDescriptionChanged(String value) {
    Task updated = state.updatedTask.copyWith(
      description: value,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  modalDismissed({String? recurringId}) async {
    if (recurringId != null) {
      List<Task> tasks = await _tasksRepository.getByRecurringId(recurringId);

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

        _tasksCubit.updateUiOfTask(updatedRecurringTask);

        updatedRecurringTasks.add(updatedRecurringTask);
      }

      for (Task task in updatedRecurringTasks) {
        await _tasksRepository.updateById(task.id!, data: task);
      }
    } else {
      Task original = state.originalTask;
      Task updated = state.updatedTask;

      _tasksCubit.addToUndoQueue([original], UndoType.updated);

      _tasksCubit.updateUiOfTask(updated);

      await _tasksRepository.updateById(updated.id!, data: updated);
    }

    _tasksCubit.syncAll();

    // _labels.refresh();
  }
}
