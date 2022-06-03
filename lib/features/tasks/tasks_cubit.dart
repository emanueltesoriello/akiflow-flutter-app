import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/edit_task/ui/change_priority_modal.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/repository/docs_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:mobile/utils/tz_utils.dart';
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

  final StreamController<List<Task>> _editRecurringTasksDialog = StreamController<List<Task>>.broadcast();
  Stream<List<Task>> get editRecurringTasksDialog => _editRecurringTasksDialog.stream;

  final StreamController<void> _scrollTopStreamController = StreamController<void>.broadcast();
  Stream<void> get scrollTopStream => _scrollTopStreamController.stream;

  late final TodayCubit _todayCubit;
  late final SyncCubit _syncCubit;

  LabelCubit? _labelCubit;

  TasksCubit(this._syncCubit) : super(const TasksCubitState()) {
    print("listen tasks sync");

    _syncCubit.syncCompletedStream.listen((_) async {
      await refreshTasksFromRepository();
    });
  }

  attachTodayCubit(TodayCubit todayCubit) {
    _todayCubit = todayCubit;
  }

  attachLabelCubit(LabelCubit labelCubit) {
    _labelCubit = labelCubit;
  }

  syncAllAndRefresh() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      emit(state.copyWith(loading: true));

      emit(state.copyWith(syncStatus: "Syncing..."));

      await _syncCubit.sync([Entity.tasks]);

      emit(state.copyWith(loading: false));
    }
  }

  refreshTasksFromRepository() async {
    Future.wait([
      fetchDocs(),
      fetchInbox(),
      fetchTodayTasks(),
      fetchSelectedDayTasks(_todayCubit.state.selectedDate),
      _labelCubit?.state.selectedLabel != null ? fetchLabelTasks(_labelCubit!.state.selectedLabel!) : Future.value(),
    ]);
  }

  Future fetchInbox() async {
    List<Task> inboxTasks = await _tasksRepository.getInbox();
    emit(state.copyWith(inboxTasks: inboxTasks, syncStatus: "Get today tasks"));
  }

  Future fetchTodayTasks() async {
    List<Task> fixedTodayTasks = await _tasksRepository.getTodayTasks(date: DateTime.now());
    emit(state.copyWith(fixedTodayTasks: fixedTodayTasks));
  }

  Future fetchSelectedDayTasks(DateTime date) async {
    List<Task> todayTasks = await _tasksRepository.getTodayTasks(date: date);
    emit(state.copyWith(selectedDayTasks: todayTasks, syncStatus: "Get labels from repository"));
  }

  Future fetchDocs() async {
    List<Doc> docs = await _docsRepository.get();
    emit(state.copyWith(docs: docs));
  }

  Future<void> fetchLabelTasks(Label selectedLabel) async {
    List<Task> tasks = await _tasksRepository.getLabelTasks(selectedLabel);
    emit(state.copyWith(labelTasks: tasks));
  }

  Future<void> getTodayTasksByDate(DateTime selectedDay) async {
    await fetchSelectedDayTasks(selectedDay.toUtc());
  }

  void select(Task task) {
    emit(
      state.copyWith(
        inboxTasks: state.inboxTasks.map((t) {
          if (t.id == task.id) {
            return task.copyWith(selected: !(task.selected ?? false));
          }
          return t;
        }).toList(),
        selectedDayTasks: state.selectedDayTasks.map((t) {
          if (t.id == task.id) {
            return task.copyWith(selected: !(task.selected ?? false));
          }
          return t;
        }).toList(),
        labelTasks: state.labelTasks.map((t) {
          if (t.id == task.id) {
            return task.copyWith(selected: !(task.selected ?? false));
          }
          return t;
        }).toList(),
      ),
    );
  }

  TaskStatusType? lastDoneTaskStatus;

  void markAsDone() async {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> all = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];

    addToUndoQueue(all, UndoType.markDone);

    for (Task taskSelected in all) {
      Task updated = taskSelected.markAsDone(taskSelected);

      await _tasksRepository.updateById(taskSelected.id, data: updated);
    }

    refreshTasksFromRepository();

    clearSelected();

    _syncCubit.sync([Entity.tasks]);
  }

  Future<void> duplicate() async {
    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

    List<Task> duplicates = [];

    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> all = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];

    List<Task> newInboxTasks = [];
    List<Task> newTodayTasks = [];
    List<Task> newLabelTasks = [];

    for (Task task in all) {
      Task newTaskDuplicated = task.copyWith(
        id: const Uuid().v4(),
        updatedAt: Nullable(now),
        createdAt: now,
        selected: false,
      );

      duplicates.add(newTaskDuplicated);

      if (inboxSelected.contains(task)) {
        newInboxTasks.add(newTaskDuplicated);
      }

      if (todayTasksSelected.contains(task)) {
        newTodayTasks.add(newTaskDuplicated);
      }

      if (labelTasksSelected.contains(task)) {
        newLabelTasks.add(newTaskDuplicated);
      }
    }

    await _tasksRepository.add(duplicates);

    refreshTasksFromRepository();

    clearSelected();

    emit(state.copyWith(inboxTasks: newInboxTasks, selectedDayTasks: newTodayTasks, labelTasks: newLabelTasks));

    _syncCubit.sync([Entity.tasks]);
  }

  Future<void> delete() async {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> allSelected = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];

    addToUndoQueue(allSelected, UndoType.delete);

    bool hasRecurringDataChanges = false;

    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

    for (Task task in allSelected) {
      Task updatedTask = task.copyWith(
        selected: false,
        status: Nullable(TaskStatusType.deleted.id),
        deletedAt: now,
        updatedAt: Nullable(now),
      );

      allSelected = allSelected.map((t) {
        return t.id == task.id ? updatedTask : t;
      }).toList();

      if (hasRecurringDataChanges == false && TaskExt.hasRecurringDataChanges(original: task, updated: updatedTask)) {
        hasRecurringDataChanges = true;
      }
    }

    if (hasRecurringDataChanges) {
      _editRecurringTasksDialog.add(allSelected);
    } else {
      await update(allSelected);
    }
  }

  Future<void> assignLabel(Label label) async {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> allSelected = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];

    bool hasRecurringDataChanges = false;

    DateTime now = DateTime.now();

    for (Task task in allSelected) {
      Task updatedTask = task.copyWith(
        listId: Nullable(label.id),
        selected: false,
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
      );

      allSelected = allSelected.map((t) {
        return t.id == task.id ? updatedTask : t;
      }).toList();

      if (hasRecurringDataChanges == false && TaskExt.hasRecurringDataChanges(original: task, updated: updatedTask)) {
        hasRecurringDataChanges = true;
      }
    }

    if (hasRecurringDataChanges) {
      _editRecurringTasksDialog.add(allSelected);
    } else {
      await update(allSelected);
    }
  }

  Future<void> setPriority(PriorityEnum? priority) async {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> allSelected = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];

    bool hasRecurringDataChanges = false;

    DateTime now = DateTime.now();

    for (Task task in allSelected) {
      Task updatedTask = task.copyWith(
        priority: priority?.value,
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
      );

      allSelected = allSelected.map((t) {
        return t.id == task.id ? updatedTask : t;
      }).toList();

      if (hasRecurringDataChanges == false && TaskExt.hasRecurringDataChanges(original: task, updated: updatedTask)) {
        hasRecurringDataChanges = true;
      }
    }

    if (hasRecurringDataChanges) {
      _editRecurringTasksDialog.add(allSelected);
    } else {
      await update(allSelected);
    }
  }

  Future<void> update(List<Task> tasksUpdated, {bool andFutureTasks = false}) async {
    if (andFutureTasks) {
      List<Task> taskWithRecurrence = tasksUpdated.where((element) => element.recurringId != null).toList();
      List<String> recurringIds = taskWithRecurrence.map((t) => t.recurringId!).toList();
      List<Task> tasks = await _tasksRepository.getByRecurringIds(recurringIds);

      // filter tasks with date > today
      tasks = tasks.where((t) => t.date != null && DateTime.parse(t.date!).isAfter(DateTime.now())).toList();

      List<Task> updatedRecurringTasks = [];

      DateTime now = DateTime.now();

      for (Task task in tasks) {
        Task updatedRecurringTask = task.copyWith(
          listId: Nullable(tasksUpdated.first.listId),
          updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
          priority: tasksUpdated.first.priority,
          duration: Nullable(tasksUpdated.first.duration),
          deletedAt: tasksUpdated.first.deletedAt,
        );

        updatedRecurringTasks.add(updatedRecurringTask);
      }

      for (Task task in updatedRecurringTasks) {
        await _tasksRepository.updateById(task.id!, data: task);
      }
    } else {
      for (Task task in tasksUpdated) {
        await _tasksRepository.updateById(task.id, data: task);
      }
    }

    refreshTasksFromRepository();

    clearSelected();

    _syncCubit.sync([Entity.tasks]);
  }

  Future<void> setDeadline(DateTime? date) async {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> allSelected = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];

    DateTime now = DateTime.now();

    for (Task task in allSelected) {
      Task updated = task.copyWith(
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
        dueDate: Nullable(date?.toIso8601String()),
        selected: false,
      );

      await _tasksRepository.updateById(updated.id, data: updated);
    }

    refreshTasksFromRepository();

    clearSelected();

    _syncCubit.sync([Entity.tasks]);
  }

  void clearSelected() {
    emit(
      state.copyWith(
        inboxTasks: state.inboxTasks.map((e) => e.copyWith(selected: false)).toList(),
        selectedDayTasks: state.selectedDayTasks.map((e) => e.copyWith(selected: false)).toList(),
        labelTasks: state.labelTasks.map((e) => e.copyWith(selected: false)).toList(),
      ),
    );
  }

  Future<void> reorder(
    int oldIndex,
    int newIndex, {
    required List<Task> newTasksListOrdered,
    required TaskListSorting? sorting,
  }) async {
    List<Task> updated = newTasksListOrdered.toList();

    Task task = updated.removeAt(oldIndex);

    updated.insert(newIndex, task);

    DateTime now = DateTime.now().toUtc();
    int millis = now.millisecondsSinceEpoch;

    if (sorting != null && sorting == TaskListSorting.descending) {
      updated = updated.reversed.toList();
    }

    for (int i = 0; i < updated.length; i++) {
      Task updatedTask = updated[i];

      updatedTask = updatedTask.copyWith(
        sorting: millis - (i * 1),
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
        selected: false,
      );

      updated[i] = updatedTask;
    }

    for (int i = 0; i < updated.length; i++) {
      Task updatedTask = updated[i];
      await _tasksRepository.updateById(updatedTask.id, data: updatedTask);
    }

    refreshTasksFromRepository();

    clearSelected();

    _syncCubit.sync([Entity.tasks]);
  }

  void moveToInbox() {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    addToUndoQueue([...inboxSelected, ...todayTasksSelected, ...labelTasksSelected], UndoType.moveToInbox);
    planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
  }

  void planForToday() {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    addToUndoQueue([...inboxSelected, ...todayTasksSelected, ...labelTasksSelected], UndoType.moveToInbox);
    planFor(DateTime.now(), dateTime: null, statusType: TaskStatusType.inbox);
  }

  void editPlanOrSnooze(DateTime? date, {required DateTime? dateTime, required TaskStatusType statusType}) {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    UndoType undoType = statusType == TaskStatusType.planned ? UndoType.moveToInbox : UndoType.snooze;
    addToUndoQueue([...inboxSelected, ...todayTasksSelected, ...labelTasksSelected], undoType);
    planFor(date, dateTime: dateTime, statusType: statusType);
  }

  Future<void> planFor(DateTime? date, {required DateTime? dateTime, required TaskStatusType statusType}) async {
    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> allSelected = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];

    DateTime now = DateTime.now();

    for (Task task in allSelected) {
      Task updated = task.copyWith(
        date: Nullable(date?.toIso8601String()),
        datetime: Nullable(dateTime?.toIso8601String()),
        status: Nullable(statusType.id),
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
        selected: false,
      );

      await _tasksRepository.updateById(task.id, data: updated);
    }

    refreshTasksFromRepository();

    clearSelected();

    _syncCubit.sync([Entity.tasks]);
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

  Future<void> setJustCreatedTask(Task task) async {
    _scrollTopStreamController.add(null);

    emit(state.copyWith(justCreatedTask: Nullable(task)));

    Timer(const Duration(seconds: 3), () {
      emit(state.copyWith(justCreatedTask: Nullable(null)));
    });
  }

  Future<void> undo() async {
    List<UndoTask> queue = state.queue.toList();

    DateTime now = DateTime.now();

    for (var element in queue) {
      Task updated = element.task.copyWith(
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
      );
      await _tasksRepository.updateById(updated.id, data: updated);
    }

    emit(state.copyWith(queue: []));

    refreshTasksFromRepository();

    _syncCubit.sync([Entity.tasks]);
  }

  Future<void> markLabelTasksAsDone() async {
    List<Task> labelTasksSelected = state.labelTasks.toList();

    for (Task task in labelTasksSelected) {
      Task updated = task.markAsDone(task);
      await _tasksRepository.updateById(updated.id, data: updated);
    }

    refreshTasksFromRepository();

    clearSelected();

    _syncCubit.sync([Entity.tasks]);

    emit(state.copyWith(labelTasks: []));
  }
}
