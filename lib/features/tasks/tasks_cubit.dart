import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/docs_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
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
  final DocsRepository _docsRepository = locator<DocsRepository>();

  final SyncControllerService _syncControllerService = locator<SyncControllerService>();

  TasksCubit() : super(const TasksCubitState()) {
    syncAllAndRefresh();
  }

  syncAllAndRefresh({DateTime? selectedTodayDate}) async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      emit(state.copyWith(loading: true));

      emit(state.copyWith(syncStatus: "Syncing..."));

      await syncAll();

      await refreshTasksFromRepository(selectedTodayDate: selectedTodayDate);

      emit(state.copyWith(loading: false));
    }
  }

  Future<void> syncAll() async {
    emit(state.copyWith(loading: true, syncStatus: ''));

    await _syncControllerService.syncAll();

    emit(state.copyWith(loading: false));
  }

  refreshTasksFromRepository({DateTime? selectedTodayDate}) async {
    emit(state.copyWith(loading: true, syncStatus: "Get tasks from repository"));

    await fetchDocs();
    await fetchInbox();
    await fetchTodayTasks(selectedTodayDate ?? DateTime.now());

    emit(state.copyWith(loading: false));
  }

  Future fetchInbox() async {
    List<Task> inboxTasks = await _tasksRepository.getInbox();
    emit(state.copyWith(inboxTasks: inboxTasks, syncStatus: "Get today tasks"));
  }

  Future fetchTodayTasks(DateTime date) async {
    List<Task> todayTasks = await _tasksRepository.getTodayTasks(date: date);
    emit(state.copyWith(todayTasks: todayTasks, syncStatus: "Get labels from repository"));
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
    emit(
      state.copyWith(
        inboxTasks: state.inboxTasks.map((t) {
          if (t.id == task.id) {
            return task.copyWith(selected: true);
          }
          return t;
        }).toList(),
        todayTasks: state.todayTasks.map((t) {
          if (t.id == task.id) {
            return task.copyWith(selected: true);
          }
          return t;
        }).toList(),
      ),
    );
  }

  TaskStatusType? lastDoneTaskStatus;

  void markAsDone() async {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    tasksSelected.addAll(state.todayTasks.where((t) => t.selected ?? false).toList());

    addToUndoQueue(tasksSelected, UndoType.markDone);

    for (Task taskSelected in tasksSelected) {
      Task updated = taskSelected.markAsDone(taskSelected);

      updateUiOfTask(updated);

      await _tasksRepository.updateById(taskSelected.id, data: updated);
    }

    emit(state.copyWith(inboxTasks: state.inboxTasks));
    clearSelected();

    syncAll();
  }

  Future<void> duplicate() async {
    DateTime? now = DateTime.now().toUtc();

    List<Task> updated = state.inboxTasks.toList();

    List<Task> duplicates = [];

    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasksSelected) {
      Task newTaskDuplicated = task.copyWith(
        id: const Uuid().v4(),
        updatedAt: Nullable(now.toIso8601String()),
        createdAt: (now.toIso8601String()),
        selected: false,
      );

      duplicates.add(newTaskDuplicated);
    }

    updated.addAll(duplicates);

    await _tasksRepository.add(duplicates);

    clearSelected();

    emit(state.copyWith(inboxTasks: updated));

    syncAll();
  }

  Future<void> delete() async {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    addToUndoQueue(tasksSelected, UndoType.delete);

    List<Task> updated = state.inboxTasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      task = task.copyWith(
        selected: false,
        status: Nullable(TaskStatusType.deleted.id),
        deletedAt: (DateTime.now().toUtc().toIso8601String()),
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      updated[index] = task;

      updateUiOfTask(task);

      await _tasksRepository.updateById(
        updated[index].id,
        data: updated[index],
      );
    }

    emit(state.copyWith(inboxTasks: updated));

    syncAll();
  }

  Future<void> assignLabel(Label label) async {
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

    syncAll();
  }

  Future<void> selectPriority() async {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    List<Task> updated = state.inboxTasks.toList();

    for (Task task in tasksSelected) {
      int index = updated.indexWhere((t) => t.id == task.id);

      Task updatedTask = task.changePriority();

      updated[index] = updatedTask;

      updateUiOfTask(updated[index]);

      await _tasksRepository.updateById(updated[index].id, data: updated[index]);
    }

    emit(state.copyWith(inboxTasks: updated));

    syncAll();
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

    syncAll();
  }

  void clearSelected() {
    emit(
      state.copyWith(
        inboxTasks: state.inboxTasks.map((e) => e.copyWith(selected: false)).toList(),
        todayTasks: state.todayTasks.map((e) => e.copyWith(selected: false)).toList(),
      ),
    );
  }

  Future<void> reorder(
    int oldIndex,
    int newIndex, {
    required List<Task> newTasksListOrdered,
    required TaskListSorting sorting,
  }) async {
    List<Task> updated = newTasksListOrdered.toList();

    Task task = updated.removeAt(oldIndex);

    updated.insert(newIndex, task);

    DateTime now = DateTime.now().toUtc();
    int millis = now.millisecondsSinceEpoch;

    if (sorting == TaskListSorting.descending) {
      updated = updated.reversed.toList();
    }

    for (int i = 0; i < updated.length; i++) {
      Task updatedTask = updated[i];

      updatedTask = updatedTask.copyWith(
        sorting: millis - (i * 1),
        updatedAt: Nullable(now.toIso8601String()),
        selected: false,
      );

      updated[i] = updatedTask;

      updateUiOfTask(updatedTask);
    }

    clearSelected();

    for (int i = 0; i < updated.length; i++) {
      Task updatedTask = updated[i];
      await _tasksRepository.updateById(updatedTask.id, data: updatedTask);
    }

    syncAll();
  }

  void updateUiOfTask(Task task) {
    bool inboxHasTask = state.inboxTasks.any((t) => t.id == task.id);
    bool todayHasTask = state.todayTasks.any((t) => t.id == task.id);

    List<Task> updatedInbox = List.from(state.inboxTasks);
    if (inboxHasTask) {
      int index = updatedInbox.indexWhere((t) => t.id == task.id);
      updatedInbox[index] = task;
    } else {
      updatedInbox.add(task);
    }

    List<Task> updatedToday = List.from(state.todayTasks);
    if (todayHasTask) {
      int index = updatedToday.indexWhere((t) => t.id == task.id);
      updatedToday[index] = task;
    } else {
      updatedToday.add(task);
    }

    emit(state.copyWith(
      inboxTasks: updatedInbox,
      todayTasks: updatedToday,
    ));
  }

  void moveToInbox() {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    addToUndoQueue(tasksSelected, UndoType.moveToInbox);
    planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
  }

  void planForToday() {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    addToUndoQueue(tasksSelected, UndoType.moveToInbox);
    planFor(DateTime.now(), dateTime: null, statusType: TaskStatusType.inbox);
  }

  void editPlanOrSnooze(DateTime? date, {required DateTime? dateTime, required TaskStatusType statusType}) {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    UndoType undoType = statusType == TaskStatusType.planned ? UndoType.moveToInbox : UndoType.snooze;
    addToUndoQueue(tasksSelected, undoType);
    planFor(date, dateTime: dateTime, statusType: statusType);
  }

  Future<void> planFor(DateTime? date, {required DateTime? dateTime, required TaskStatusType statusType}) async {
    List<Task> tasksSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();

    for (Task task in tasksSelected) {
      Task updated = task.copyWith(
        date: Nullable(date?.toIso8601String()),
        datetime: Nullable(dateTime?.toIso8601String()),
        status: Nullable(statusType.id),
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
        selected: false,
      );

      updateUiOfTask(updated);

      await _tasksRepository.updateById(task.id, data: updated);
    }

    clearSelected();

    emit(state.copyWith(inboxTasks: state.inboxTasks));

    syncAll();
  }

  Timer? _undoTimerDebounce;

  Future<void> addToUndoQueue(List<Task> originalTasks, UndoType type) async {
    if (_undoTimerDebounce != null) {
      _undoTimerDebounce?.cancel();
    }

    List<UndoTask> queue = List.from(state.queue);

    for (var task in originalTasks) {
      queue.add(UndoTask(task, type));
    }

    emit(state.copyWith(queue: queue));

    _undoTimerDebounce = Timer(const Duration(seconds: 3), () {
      emit(state.copyWith(queue: []));
    });
  }

  Future<void> undo() async {
    List<UndoTask> queue = state.queue.toList();

    List<Task> inbox = List.from(state.inboxTasks);
    List<Task> today = List.from(state.todayTasks);

    for (var element in queue) {
      inbox = inbox.map((t) => t.id == element.task.id ? element.task : t).toList();
      today = today.map((t) => t.id == element.task.id ? element.task : t).toList();
    }

    emit(state.copyWith(inboxTasks: inbox, todayTasks: today, queue: []));

    for (var element in queue) {
      Task updated = element.task.copyWith(
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );
      await _tasksRepository.updateById(updated.id, data: updated);
    }

    syncAll();
  }
}
