import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/docs_repository.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
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

  final SyncControllerService _syncControllerService =
      locator<SyncControllerService>();

  TasksCubit() : super(const TasksCubitState()) {
    syncAllAndRefresh();
  }

  syncAllAndRefresh() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      await _syncControllerService.syncAll();
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

  Future<void> addTask(Task task) async {
    DateTime? now = DateTime.now().toUtc();

    List<Task> all = state.tasks.toList();

    Task newTask = task.rebuild(
      (b) => b
        ..id = const Uuid().v4()
        ..updatedAt = now
        ..createdAt = now,
    );

    all.add(newTask);

    emit(state.copyWith(tasks: all));

    await _tasksRepository.add([newTask]);

    await _syncControllerService.syncTasks();

    refreshTasks();
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
      // TODO plan all
    } else {
      // TODO plan selected task only
    }
  }

  void snooze({Task? task}) {
    bool isSelectMode = state.tasks.any((t) => t.selected ?? false);

    if (task == null || isSelectMode) {
      // TODO snooze all
    } else {
      // TODO snooze selected task only
    }
  }

  done([Task? task]) async {
    bool isSelectMode =
        task == null || state.tasks.any((t) => t.selected ?? false);

    if (isSelectMode) {
      List<Task> tasks = state.tasks.where((t) => t.selected ?? false).toList();

      for (Task taskSelected in tasks) {
        Task computedTask = _computePreDone(taskSelected);
        await _updateInRepository(computedTask);
      }
    } else {
      Task computedTask = _computePreDone(task);

      Debouncer.process(ifNotCancelled: () async {
        await _updateInRepository(computedTask);

        await _syncControllerService.syncTasks();

        refreshTasks();
      });
    }
  }

  Task _computePreDone(Task task) {
    int index = state.tasks.indexOf(task);

    bool temporaryDone = task.temporaryDone != null && task.temporaryDone!;

    if (temporaryDone || task.isCompletedComputed) {
      task = task.rebuild((b) => b..temporaryDone = false);
    } else {
      task = task.rebuild((b) => b..temporaryDone = true);
    }

    List<Task> all = state.tasks.toList();

    all[index] = task;

    emit(state.copyWith(tasks: all));

    return task;
  }

  _updateInRepository(Task task) async {
    bool done = task.temporaryDone ?? false;

    if (done == task.isCompletedComputed) {
      return;
    }

    int index = state.tasks.indexOf(task);

    DateTime? now = DateTime.now().toUtc();

    if (done) {
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
          ..status = TaskStatusType.inbox.id,
      );
    }

    List<Task> all = state.tasks.toList();

    all[index] = task;

    emit(state.copyWith(tasks: all));

    await _tasksRepository.updateById(task.id, data: task);
  }
}
