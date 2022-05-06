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
      emit(state.copyWith(loading: true));

      emit(state.copyWith(syncStatus: "start sync"));

      await _syncControllerService.syncAll(syncStatus: (status) {
        _sentryService.addBreadcrumb(category: "sync", message: status);
        emit(state.copyWith(syncStatus: status));
      });

      await refreshTasksFromRepository();

      emit(state.copyWith(loading: false));
    }
  }

  refreshTasksFromRepository() async {
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
    List<Task> tasksUpdated = state.tasks.toList();

    int index = tasksUpdated.indexWhere((t) => t.id == task.id);

    task = task.rebuild((b) => b..selected = !(task.selected ?? false));

    tasksUpdated[index] = task;

    emit(state.copyWith(tasks: tasksUpdated));
  }

  TaskStatusType? lastDoneTaskStatus;

  void markAsDone([Task? task]) async {
    bool isSelectMode =
        task == null || state.tasks.any((t) => t.selected ?? false);

    if (isSelectMode) {
      List<Task> tasksSelected =
          state.tasks.where((t) => t.selected ?? false).toList();

      for (Task taskSelected in tasksSelected) {
        Task updated = taskSelected.rebuild((p0) => p0);

        updated = updated.markAsDone(
          lastDoneTaskStatus: lastDoneTaskStatus,
          onDone: (status) {
            lastDoneTaskStatus = status;
          },
        );

        int index = state.tasks.indexWhere((t) => t.id == updated.id);

        state.tasks[index] = updated;

        await _tasksRepository.updateById(taskSelected.id, data: updated);
      }

      emit(state.copyWith(tasks: state.tasks));
    } else {
      Task updated = task.rebuild((p0) => p0);

      updated = updated.markAsDone(
        lastDoneTaskStatus: lastDoneTaskStatus,
        onDone: (status) {
          lastDoneTaskStatus = status;
        },
      );

      updateUiOfTask(updated);

      await _tasksRepository.updateById(updated.id, data: updated);
    }

    syncTasks();
  }

  Future<void> syncTasks() async {
    await _syncControllerService.syncTasks(
      syncStatus: (status) {
        emit(state.copyWith(syncStatus: status));
      },
    );
  }

  Future<void> duplicate([Task? task]) async {
    DateTime? now = DateTime.now().toUtc();

    List<Task> updated = state.tasks.toList();

    if (task != null) {
      Task duplicated = (task.rebuild(
        (b) => b
          ..id = const Uuid().v4()
          ..updatedAt = now
          ..createdAt = now,
      ));

      updated.addAll([duplicated]);

      await _tasksRepository.add([duplicated]);
    } else {
      List<Task> duplicates = [];

      List<Task> tasksSelected =
          updated.where((t) => t.selected ?? false).toList();

      for (Task task in tasksSelected) {
        duplicates.add(task.rebuild(
          (b) => b
            ..id = const Uuid().v4()
            ..updatedAt = now
            ..createdAt = now,
        ));
      }

      updated.addAll(duplicates);

      await _tasksRepository.add(duplicates);
    }

    emit(state.copyWith(tasks: updated));

    syncTasks();
  }

  Future<void> delete() async {
    List<Task> tasksSelected =
        state.tasks.where((t) => t.selected ?? false).toList();

    List<Task> updated = state.tasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      task = task.delete();

      updated[index] = task;

      await _tasksRepository.updateById(
        updated[index].id,
        data: updated[index],
      );
    }

    emit(state.copyWith(tasks: updated));

    syncTasks();
  }

  void assignLabel(Label label) {
    List<Task> tasksSelected =
        state.tasks.where((t) => t.selected ?? false).toList();

    List<Task> updated = state.tasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      Task updatedTask = task.rebuild(
        (b) => b
          ..listId = label.id
          ..updatedAt = DateTime.now().toUtc(),
      );

      updated[index] = updatedTask;
    }

    emit(state.copyWith(tasks: updated));

    syncTasks();
  }

  void selectPriority() {
    List<Task> tasksSelected =
        state.tasks.where((t) => t.selected ?? false).toList();

    List<Task> updated = state.tasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      int currentPriority = task.priority ?? 0;

      if (currentPriority + 1 > 3) {
        currentPriority = 0;
      } else {
        currentPriority++;
      }

      Task updatedTask = task.rebuild(
        (b) => b
          ..priority = currentPriority
          ..updatedAt = DateTime.now().toUtc(),
      );

      updated[index] = updatedTask;
    }

    emit(state.copyWith(tasks: updated));

    syncTasks();
  }

  void setDeadline({Task? task}) {
    // TODO TasksHelper.setDeadline(task: task);
  }

  void clearSelected() {
    List<Task> updated = state.tasks.toList();

    for (Task task in updated) {
      int index = updated.indexWhere((t) => t.id == task.id);

      updated[index] = task.rebuild((b) => b..selected = false);
    }

    emit(state.copyWith(tasks: updated));
  }

  Future<void> reorder(
    int oldIndex,
    int newIndex, {
    required List<Task> newTasksListOrdered,
    required TaskListSorting sorting,
  }) async {
    List<Task> updated = state.tasks.toList();

    Task task = updated.removeAt(oldIndex);

    updated.insert(newIndex, task);

    DateTime now = DateTime.now().toUtc();
    int millis = now.millisecondsSinceEpoch;

    if (sorting == TaskListSorting.descending) {
      updated = updated.reversed.toList();
    }

    List<Task> ordered = updated
        .map((t) => t.rebuild(
              (b) => b
                ..sorting =
                    millis - (1 * updated.indexWhere((e) => e.id == t.id) + 1)
                ..updatedAt = now
                ..selected = false,
            ))
        .toList();

    for (Task task in ordered) {
      await _tasksRepository.updateById(task.id, data: task);
    }

    syncTasks();
  }

  void updateUiOfTask(Task task) {
    int index = state.tasks.indexWhere((t) => t.id == task.id);

    state.tasks[index] = task;

    List<Task> tasksUpdated = state.tasks.toList();

    emit(state.copyWith(tasks: tasksUpdated));
  }

  Future<void> planFor(
    DateTime? date, {
    DateTime? dateTime,
    required TaskStatusType statusType,
  }) async {
    List<Task> tasksSelected =
        state.tasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasksSelected) {
      int index = state.tasks.indexWhere((t) => t.id == task.id);

      Task updated = task.rebuild(
        (b) => b..updatedAt = DateTime.now().toUtc(),
      );

      updated = updated.planFor(
        date: date,
        dateTime: dateTime,
        status: statusType.id,
      );

      state.tasks[index] = updated;

      await _tasksRepository.updateById(task.id, data: updated);
    }

    clearSelected();

    emit(state.copyWith(tasks: state.tasks));

    syncTasks();
  }
}
