import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/docs_repository.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/debouncer.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';
import 'package:uuid/uuid.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  final DocsRepository _docsRepository = locator<DocsRepository>();
  final SentryService _sentryService = locator<SentryService>();

  final SyncControllerService _syncControllerService =
      locator<SyncControllerService>();

  TasksCubit() : super(const TasksCubitState()) {
    syncAllAndRefresh();
  }

  syncAllAndRefresh() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      emit(state.copyWith(syncStatus: "start sync"));

      await _syncControllerService.syncAll(syncStatus: (status) {
        _sentryService.addBreadcrumb(category: "sync", message: status);
        emit(state.copyWith(syncStatus: status));
      });

      await refreshTasks();
    }
  }

  refreshTasks() async {
    List<Task> tasks = await _tasksRepository.get();
    emit(state.copyWith(tasks: tasks));

    List<Label> labels = await _labelsRepository.get();
    emit(state.copyWith(labels: labels));

    List<Doc> docs = await _docsRepository.get();
    emit(state.copyWith(docs: docs));
  }

  void logout() {
    emit(state.copyWith(tasks: []));
  }

  void select(Task task) {
    int index = state.tasks.indexOf(task);

    task = task.rebuild((b) => b..selected = !(task.selected ?? false));

    List<Task> all = state.tasks.toList();

    all[index] = task;

    emit(state.copyWith(tasks: all));
  }

  void plan({Task? task}) {
    bool isSelectMode = state.tasks.any((t) => t.selected ?? false);

    if (task == null || isSelectMode) {
      // TODO: EDIT TASK - plan all
    } else {
      // plan selected task only
    }
  }

  void snooze({Task? task}) {
    bool isSelectMode = state.tasks.any((t) => t.selected ?? false);

    if (task == null || isSelectMode) {
      // TODO: EDIT TASK - snooze all
    } else {
      // snooze selected task only
    }
  }

  markAsDone([Task? task]) async {
    bool isSelectMode =
        task == null || state.tasks.any((t) => t.selected ?? false);

    if (isSelectMode) {
      List<Task> tasks = state.tasks.where((t) => t.selected ?? false).toList();

      for (Task taskSelected in tasks) {
        _computeDone(taskSelected);
      }

      _updateWith(debounce: false);
    } else {
      _computeDone(task);

      _updateWith(debounce: true);
    }
  }

  void _updateWith({required bool debounce}) {
    if (debounce) {
      Debouncer.process(ifNotCancelled: () async {
        _update();
      });
    } else {
      _update();
    }
  }

  Future<void> _update() async {
    List<Task> updatedTasks = state.updatedTasks;

    if (updatedTasks.isNotEmpty) {
      await _updateInRepository();

      refreshTasks();

      await _syncControllerService.syncTasks(
        syncStatus: (status) {
          emit(state.copyWith(syncStatus: status));
        },
      );
    } else {
      print('No tasks to update');
    }
  }

  TaskStatusType? lastDoneTaskStatus;

  void _computeDone(Task task) {
    bool done = task.isCompletedComputed;

    if (task.status != TaskStatusType.completed.id) {
      lastDoneTaskStatus = TaskStatusTypeExt.fromId(task.status);
    }

    DateTime? now = DateTime.now().toUtc();

    if (!done) {
      task = task.rebuild(
        (b) => b
          ..done = true
          ..doneAt = now
          ..updatedAt = now
          ..status = TaskStatusType.completed.id,
      );
    } else {
      task = task.rebuild(
        (b) => b
          ..done = false
          ..doneAt = null
          ..updatedAt = now
          ..status = lastDoneTaskStatus?.id,
      );
    }

    List<Task> updatedTasks = state.updatedTasks.toList();

    int index =
        state.updatedTasks.indexWhere((element) => element.id == task.id);

    if (index != -1) {
      updatedTasks[index] = task;
    } else {
      updatedTasks.add(task);
    }

    emit(state.copyWith(updatedTasks: updatedTasks));
  }

  Future<void> _updateInRepository() async {
    List<Task> updatedTasks = state.updatedTasks;

    for (Task task in updatedTasks) {
      await _tasksRepository.updateById(task.id, data: task);

      emit(state.copyWith(updatedTasks: []));
    }
  }

  void open(Task task) {
    // TODO: EDIT TASK - open task edit page
  }

  void clearSelected() {
    List<Task> all = state.tasks.toList();

    for (Task task in all) {
      int index = all.indexOf(task);

      all[index] = task.rebuild((b) => b..selected = false);
    }

    emit(state.copyWith(tasks: all));
  }

  void reorder(
    int oldIndex,
    int newIndex, {
    required List<Task> newTasksListOrdered,
    required TaskListSorting sorting,
  }) {
    // move element to position
    Task task = newTasksListOrdered.removeAt(oldIndex);

    newTasksListOrdered.insert(newIndex, task);

    DateTime now = DateTime.now().toUtc();
    int millis = now.millisecondsSinceEpoch;

    if (sorting == TaskListSorting.descending) {
      newTasksListOrdered = newTasksListOrdered.reversed.toList();
    }

    List<Task> ordered = newTasksListOrdered
        .map((t) => t.rebuild(
              (b) => b
                ..sorting = millis - (1 * newTasksListOrdered.indexOf(t) + 1)
                ..selected = false,
            ))
        .toList();

    emit(state.copyWith(tasks: ordered));

    List<Task> updated = ordered
        .map((t) => t.rebuild(
              (b) => b..updatedAt = now,
            ))
        .toList();

    emit(state.copyWith(updatedTasks: updated));

    _updateWith(debounce: false);
  }

  void moveToInbox() {
    List<Task> tasks = state.tasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasks) {
      int index = tasks.indexOf(task);

      tasks[index] = task.rebuild(
        (b) => b
          ..status = TaskStatusType.inbox.id
          ..date = null
          ..updatedAt = DateTime.now().toUtc(),
      );
    }

    emit(state.copyWith(tasks: tasks, updatedTasks: tasks));

    _updateWith(debounce: false);
  }

  void planForToday() {
    List<Task> tasks = state.tasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasks) {
      int index = tasks.indexOf(task);

      tasks[index] = task.rebuild(
        (b) => b
          ..status = TaskStatusType.planned.id
          ..date = DateTime.now().toUtc()
          ..updatedAt = DateTime.now().toUtc(),
      );
    }

    emit(state.copyWith(tasks: tasks, updatedTasks: tasks));

    _updateWith(debounce: false);
  }

  Future<void> duplicate() async {
    List<Task> tasks = state.tasks.where((t) => t.selected ?? false).toList();

    List<Task> duplicates = [];

    DateTime? now = DateTime.now().toUtc();

    for (Task task in tasks) {
      duplicates.add(task.rebuild(
        (b) => b
          ..id = const Uuid().v4()
          ..updatedAt = now
          ..createdAt = now,
      ));
    }

    tasks.addAll(duplicates);

    await _tasksRepository.add(duplicates);

    emit(state.copyWith(tasks: tasks, updatedTasks: tasks));

    _updateWith(debounce: false);
  }

  void delete() {
    List<Task> tasks = state.tasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasks) {
      int index = tasks.indexOf(task);

      tasks[index] = task.rebuild(
        (b) => b
          ..status = TaskStatusType.deleted.id
          ..deletedAt = DateTime.now().toUtc()
          ..updatedAt = DateTime.now().toUtc(),
      );
    }

    emit(state.copyWith(tasks: tasks, updatedTasks: tasks));

    _updateWith(debounce: false);
  }

  void assignLabel({Task? task}) {
    // TODO: EDIT TASK - assign label to task
  }

  void selectPriority({Task? task}) {
    // TODO: EDIT TASK - select priority for task
  }

  void setDeadline({Task? task}) {
    // TODO: EDIT TASK - set deadline for task
  }
}
