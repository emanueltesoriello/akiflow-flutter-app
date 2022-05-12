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
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';
import 'package:uuid/uuid.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  final DocsRepository _docsRepository = locator<DocsRepository>();
  final SentryService _sentryService = locator<SentryService>();

  final SyncControllerService _syncControllerService = locator<SyncControllerService>();

  TasksCubit() : super(const TasksCubitState()) {
    syncAllAndRefresh();
  }

  syncAllAndRefresh() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      emit(state.copyWith(loading: true));

      emit(state.copyWith(syncStatus: "Syncing..."));

      await syncTasks();

      await refreshTasksFromRepository();

      emit(state.copyWith(loading: false));
    }
  }

  Future<void> syncTasks() async {
    await _syncControllerService.syncTasks(
      syncStatus: (status) {
        _sentryService.addBreadcrumb(category: "sync", message: status);
        emit(state.copyWith(syncStatus: status));
      },
    );
  }

  refreshTasksFromRepository() async {
    emit(state.copyWith(syncStatus: "Get tasks from repository"));

    await fetchLabels();
    await fetchDocs();
    await fetchInbox();
    await fetchTodayTasks(DateTime.now().toUtc());

    emit(state.copyWith(loading: false));
  }

  Future fetchInbox() async {
    List<Task> inboxTasks = await _tasksRepository.getUndone();
    emit(state.copyWith(inboxTasks: inboxTasks, syncStatus: "Get today tasks"));
  }

  Future fetchTodayTasks(DateTime date) async {
    List<Task> todayTasks = await _tasksRepository.getTodayTasks(date: date);
    emit(state.copyWith(todayTasks: todayTasks, syncStatus: "Get labels from repository"));
  }

  Future fetchLabels() async {
    List<Label> labels = await _labelsRepository.get();
    emit(state.copyWith(labels: labels, syncStatus: "Get docs from repository"));
  }

  Future fetchDocs() async {
    List<Doc> docs = await _docsRepository.get();
    emit(state.copyWith(docs: docs));
  }

  Future<void> getTodayTasksByDate(DateTime selectedDay) async {
    await fetchTodayTasks(selectedDay.toUtc());
  }

  void logout() {
    emit(state.copyWith(inboxTasks: []));
  }

  void select(Task task) {
    List<Task> tasksUpdated = state.inboxTasks.toList();

    int index = tasksUpdated.indexWhere((t) => t.id == task.id);

    task = task.copyWith(selected: !(task.selected ?? false));

    tasksUpdated[index] = task;

    emit(state.copyWith(inboxTasks: tasksUpdated));
  }

  TaskStatusType? lastDoneTaskStatus;

  void markAsDone([Task? task]) async {
    bool isSelectMode = task == null || state.inboxTasks.any((t) => t.selected ?? false);

    if (isSelectMode) {
      List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

      for (Task taskSelected in tasksSelected) {
        Task updated = taskSelected.copyWith();

        updated = updated.markAsDone(
          lastDoneTaskStatus: lastDoneTaskStatus,
          onDone: (status) {
            lastDoneTaskStatus = status;
          },
        );

        updateUiOfTask(updated);

        await _tasksRepository.updateById(taskSelected.id, data: updated);
      }

      emit(state.copyWith(inboxTasks: state.inboxTasks));
    } else {
      Task updated = task.copyWith();

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

  Future<void> duplicate([Task? task]) async {
    DateTime? now = DateTime.now().toUtc();

    List<Task> updated = state.inboxTasks.toList();

    if (task != null) {
      Task newTaskDuplicated = task.copyWith(
        id: const Uuid().v4(),
        updatedAt: Nullable(now.toIso8601String()),
        createdAt: (now.toIso8601String()),
      );

      updated.addAll([newTaskDuplicated]);

      await _tasksRepository.add([newTaskDuplicated]);
    } else {
      List<Task> duplicates = [];

      List<Task> tasksSelected = updated.where((t) => t.selected ?? false).toList();

      for (Task task in tasksSelected) {
        Task newTaskDuplicated = task.copyWith(
          id: const Uuid().v4(),
          updatedAt: Nullable(now.toIso8601String()),
          createdAt: (now.toIso8601String()),
        );

        duplicates.add(newTaskDuplicated);
      }

      updated.addAll(duplicates);

      await _tasksRepository.add(duplicates);
    }

    emit(state.copyWith(inboxTasks: updated));

    syncTasks();
  }

  Future<void> delete() async {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    List<Task> updated = state.inboxTasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      task = task.delete();

      updated[index] = task;

      updateUiOfTask(task);

      await _tasksRepository.updateById(
        updated[index].id,
        data: updated[index],
      );
    }

    emit(state.copyWith(inboxTasks: updated));

    syncTasks();
  }

  Future<void> assignLabel(Label label, {Task? task}) async {
    if (task != null) {
      task = task.copyWith(selected: true);
      int index = state.inboxTasks.indexWhere((t) => t.id == task!.id);
      state.inboxTasks[index] = task;
    }

    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    List<Task> updated = state.inboxTasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      Task updatedTask = task.copyWith(
        listId: label.id,
        selected: false,
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      updated[index] = updatedTask;

      updateUiOfTask(updated[index]);

      await _tasksRepository.updateById(updated[index].id, data: updated[index]);
    }

    clearSelected();

    emit(state.copyWith(inboxTasks: updated));

    syncTasks();
  }

  Future<void> selectPriority() async {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    List<Task> updated = state.inboxTasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      int currentPriority = task.priority ?? 0;

      if (currentPriority + 1 > 3) {
        currentPriority = -1;
      } else {
        if (currentPriority < 1) {
          currentPriority = 1;
        } else {
          currentPriority++;
        }
      }

      Task updatedTask = task.copyWith(
        priority: currentPriority,
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      updated[index] = updatedTask;

      updateUiOfTask(updated[index]);

      await _tasksRepository.updateById(updated[index].id, data: updated[index]);
    }

    emit(state.copyWith(inboxTasks: updated));

    syncTasks();
  }

  Future<void> setDeadline(DateTime? date) async {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasksSelected) {
      Task updated = task.copyWith(
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
        dueDate: Nullable(date?.toIso8601String()),
        selected: false,
      );

      updateUiOfTask(updated);

      await _tasksRepository.updateById(task.id, data: updated);
    }

    clearSelected();

    syncTasks();
  }

  void clearSelected() {
    List<Task> updated = state.inboxTasks.toList();

    for (Task task in updated) {
      int index = updated.indexWhere((t) => t.id == task.id);
      updated[index] = task.copyWith(selected: false);
    }

    emit(state.copyWith(inboxTasks: updated));
  }

  Future<void> reorder(
    int oldIndex,
    int newIndex, {
    required List<Task> newTasksListOrdered,
    required TaskListSorting sorting,
  }) async {
    List<Task> updated = state.inboxTasks.toList();

    Task task = updated.removeAt(oldIndex);

    updated.insert(newIndex, task);

    DateTime now = DateTime.now().toUtc();
    int millis = now.millisecondsSinceEpoch;

    if (sorting == TaskListSorting.descending) {
      updated = updated.reversed.toList();
    }

    List<Task> ordered = updated
        .map((t) => t.copyWith(
              sorting: millis - (1 * updated.indexWhere((e) => e.id == t.id) + 1),
              updatedAt: Nullable(now.toIso8601String()),
              selected: false,
            ))
        .toList();

    for (Task task in ordered) {
      await _tasksRepository.updateById(task.id, data: task);
    }

    syncTasks();
  }

  void updateUiOfTask(Task task) {
    emit(
      state.copyWith(
        inboxTasks: state.inboxTasks.map((t) {
          if (t.id == task.id) {
            return task;
          } else {
            return t;
          }
        }).toList(),
        todayTasks: state.todayTasks.map((t) {
          if (t.id == task.id) {
            return task;
          } else {
            return t;
          }
        }).toList(),
      ),
    );
  }

  Future<void> planFor(
    DateTime? date, {
    required DateTime? dateTime,
    required TaskStatusType statusType,
    Task? task,
  }) async {
    if (task != null) {
      task = task.copyWith(selected: true);
      int index = state.inboxTasks.indexWhere((t) => t.id == task!.id);
      state.inboxTasks[index] = task;
    }

    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasksSelected) {
      Task updated = task.copyWith(
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      updated = updated.planFor(
        date: date,
        dateTime: dateTime,
        status: statusType.id,
      );

      updated = updated.copyWith(selected: false);

      updateUiOfTask(updated);

      await _tasksRepository.updateById(task.id, data: updated);
    }

    clearSelected();

    emit(state.copyWith(inboxTasks: state.inboxTasks));

    syncTasks();
  }
}
