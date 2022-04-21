import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/docs_repository.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
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

  Timer? completedDebounce;

  Future<void> setCompleted(Task task) async {
    completedDebounce?.cancel();

    int index = state.tasks.indexOf(task);

    if (task.isCompletedComputed || (task.temporaryDone ?? false)) {
      task = task.rebuild((b) => b..temporaryDone = false);
    } else {
      task = task.rebuild((b) => b..temporaryDone = true);
    }

    List<Task> all = state.tasks.toList();

    all[index] = task;

    emit(state.copyWith(tasks: all));

    // debounce
    completedDebounce = Timer(const Duration(seconds: 2), () async {
      bool temporaryDone = (task.temporaryDone ?? false) == true;

      if (temporaryDone == task.isCompletedComputed) {
        // same original value, not update
        return;
      }

      DateTime? now = DateTime.now().toUtc();

      if (temporaryDone) {
        task = task.rebuild((b) => b
          ..done = true
          ..doneAt = now
          ..updatedAt = now
          ..status = TaskStatusType.completed.id);
      } else {
        task = task.rebuild(
          (b) => b
            ..done = false
            ..doneAt = null
            ..updatedAt = now
            ..status = TaskStatusType.inbox.id,
        );
      }

      await _tasksRepository.updateById(task.id, data: task);

      await _syncControllerService.syncTasks();

      refreshTasks();
    });
  }

  Future<void> addTask(Task task) async {
    DateTime? now = DateTime.now().toUtc();

    task = task.rebuild(
      (b) => b
        ..id = const Uuid().v4()
        ..updatedAt = now
        ..createdAt = now,
    );

    List<Task> all = state.tasks.toList();

    all.add(task);

    emit(state.copyWith(tasks: all));

    await _tasksRepository.add([task]);

    await _syncControllerService.syncTasks();

    refreshTasks();
  }
}
