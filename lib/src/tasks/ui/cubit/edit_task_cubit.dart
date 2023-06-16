import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/change_priority_modal.dart';
import 'package:models/label/label.dart';
import 'package:models/nlp/nlp_date_time.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile/core/services/sentry_service.dart';

import '../../../../common/style/colors.dart';
import '../../../../common/utils/stylable_text_editing_controller.dart';
import '../../../../core/services/sync_controller_service.dart';

part 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final TasksCubit _tasksCubit;
  final SyncCubit _syncCubit;

  List<Task> recurrenceTasksToUpdate = [];
  List<Task> recurrenceTasksToCreate = [];

  late StylableTextEditingController simpleTitleController;

  EditTaskCubit(this._tasksCubit, this._syncCubit) : super(const EditTaskCubitState()) {
    simpleTitleController = getInitializedController();
  }

  StylableTextEditingController getInitializedController() {
    return StylableTextEditingController({}, (String? value) {
      MapType? type = simpleTitleController.removeMappingByValue(value);
      if (type == null) {
        print('Null case');
      } else {
        switch (type.type) {
          case 0:
            planFor(null, statusType: TaskStatusType.inbox);
            break;
          case 1:
            setEmptyLabel();
            break;
          case 2:
            setPriority(PriorityEnum.none);
            break;
          case 3:
            setDuration(0);
            break;
          default:
        }
      }
    }, {});
  }

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

  void onOpen() {
    simpleTitleController = getInitializedController();
    simpleTitleController.text = state.originalTask.title ?? '';
  }

  Future<void> create() async {
    try {
      if (TaskExt.hasData(state.updatedTask) == false) {
        return;
      }
      DateTime now = DateTime.now();
      String? date;
      try {
        var format = DateFormat("yyyy-MM-dd");

        DateTime dtDate = DateTime.parse(state.updatedTask.date!);
        date = format.format(dtDate);
      } catch (e) {
        print(e);
      }

      Task updated = state.updatedTask.copyWith(
        id: const Uuid().v4(),
        date: Nullable(date),
        title: state.updatedTask.title,
        description: state.updatedTask.description,
        createdAt: TzUtils.toUtcStringIfNotNull(now),
        readAt: TzUtils.toUtcStringIfNotNull(now),
        sorting: now.toUtc().millisecondsSinceEpoch,
      );

      await _tasksRepository.add([updated]);
      print('completed add');
      //show a toast for the just created task for 3 seconds
      _tasksCubit.setJustCreatedTask(updated);

      _tasksCubit.refreshAllFromRepository();

      emit(const EditTaskCubitState());

      _syncCubit.sync(entities: [Entity.tasks]);
      AnalyticsService.track("New Task");
    } catch (e) {
      print(e.toString());
      locator<SentryService>().addBreadcrumb(message: e.toString(), timestamp: DateTime.now());
    }
  }

  Future forceSync() async {
    await _syncCubit.sync(entities: [Entity.tasks]).catchError((e) {
      locator<SentryService>().addBreadcrumb(message: e.toString(), timestamp: DateTime.now());
    });
  }

  Future<void> planFor(
    DateTime? date, {
    DateTime? dateTime,
    required TaskStatusType statusType,
    bool forceUpdate = false,
    bool fromNlp = false,
  }) async {
    emit(state.copyWith(selectedDate: date));
    Task task = state.updatedTask;

    Task updated = task.copyWith(
      date: Nullable(date?.toIso8601String()),
      datetime: Nullable(TzUtils.toUtcStringIfNotNull(dateTime)),
      status: Nullable(statusType.id),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));

    _tasksCubit.refreshTasksUi(updated);
    if (!fromNlp) {
      if (statusType == TaskStatusType.snoozed) {
        _tasksCubit.addToUndoQueue([updated], UndoType.snooze);
      } else {
        _tasksCubit.addToUndoQueue([updated], statusType == TaskStatusType.someday ? UndoType.snooze : UndoType.plan);
      }

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
  }

  Future<void> changeDateTimeFromCalendar({required DateTime? date, required DateTime? dateTime}) async {
    emit(state.copyWith(selectedDate: date, showDuration: false));
    Task task = state.updatedTask;

    Task updated = task.copyWith(
      date: Nullable(date?.toIso8601String()),
      datetime: Nullable(TzUtils.toUtcStringIfNotNull(dateTime)),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));

    _tasksCubit.addToUndoQueue([task], UndoType.plan);

    await _tasksRepository.updateById(updated.id!, data: updated);

    _tasksCubit.refreshTasksUi(updated);
    _syncCubit.sync(entities: [Entity.tasks]);

    AnalyticsService.track("Task Rescheduled");
  }

  void setDuration(int? seconds, {bool fromModal = false}) {
    if (seconds != null) {
      emit(state.copyWith(selectedDuration: seconds.toDouble()));

      Task task = state.updatedTask;

      Task updated = task.copyWith(
        duration: seconds != 0 ? Nullable(seconds) : Nullable(null),
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
      );

      emit(state.copyWith(
        updatedTask: updated,
        showDuration: false,
        openedDurationfromNLP: false,
      ));

      AnalyticsService.track("Edit Task Duration");
    }
  }

  void toggleImportance({bool openedFromNLP = false}) {
    emit(state.copyWith(
        openedPrirorityfromNLP: openedFromNLP,
        showPriority: !state.showPriority,
        showDuration: false,
        showLabelsList: false));
  }

  void toggleDuration({bool openedFromNLP = false}) {
    emit(state.copyWith(
        showDuration: !state.showDuration,
        openedDurationfromNLP: openedFromNLP,
        showPriority: false,
        showLabelsList: false));
  }

  void toggleLabels({bool openedFromNLP = false}) {
    emit(state.copyWith(
        openedLabelfromNLP: openedFromNLP,
        showLabelsList: !state.showLabelsList,
        showDuration: false,
        showPriority: false));
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

    emit(state.copyWith(updatedTask: updated, showLabelsList: false));

    if (forceUpdate) {
      await _tasksRepository.updateById(updated.id!, data: updated);
      _tasksCubit.refreshAllFromRepository();
      _syncCubit.sync(entities: [Entity.tasks]);
    }

    AnalyticsService.track("Edit Task Label");
  }

  Future<void> markAsDone(
      {bool forceUpdate = false, bool forceMarkAsDoneRemote = false, bool forceArchiveRemote = false}) async {
    Task task = state.updatedTask;

    Task updated = task.markAsDone(state.originalTask);

    bool markAsDoneRemote = forceMarkAsDoneRemote ? true : await _tasksCubit.shouldMarkAsDoneRemote(updated);
    if (markAsDoneRemote) {
      dynamic content = updated.content ?? {};
      content['shouldMarkAsDoneRemote'] = updated.done!;
      updated = updated.copyWith(content: content);
    }

    if (task.connectorId?.value == 'trello') {
      bool shouldArchiveRemote = forceArchiveRemote ? true : await _tasksCubit.shouldArchiveRemote(updated);
      if (shouldArchiveRemote) {
        dynamic content = updated.content ?? {};
        content['shouldArchiveRemote'] = true;
        updated = updated.copyWith(content: content);
      }
    }

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
      _tasksCubit.setLastTaskDoneAt();
    }

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

  void onDispose() {
    simpleTitleController.done();
    simpleTitleController = getInitializedController();
  }

  void setPriority(PriorityEnum? priority, {int? value, bool fromModal = true}) {
    Task updated = state.updatedTask.copyWith(
      priority: priority?.value ?? value,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );
    emit(state.copyWith(updatedTask: updated, showPriority: false));
  }

  void removePriority() {
    Task updated = state.updatedTask.copyWith(
      priority: -1,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );
    emit(state.copyWith(updatedTask: updated, showPriority: false));
  }

  Future<void> removeLabel() async {
    Task updated = state.updatedTask.copyWith(
      listId: Nullable(null),
      sectionId: Nullable(null),
    );

    emit(state.copyWith(showLabelsList: false, updatedTask: updated));

    _tasksCubit.refreshTasksUi(updated);
  }

  Future<Task> _addTaskWithRecurrence(Task updated) async {
    RecurrenceRule rule = RecurrenceRule.fromString((updated.recurrence ?? []).join(";"));

    List<Task> tasks = [];

    String? recurringId = updated.id;
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
        status: Nullable(TaskStatusType.permanentlyDeleted.id),
        deletedAt: TzUtils.toUtcStringIfNotNull(now),
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
      ));
    }
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

  onListIdOrSectionIdChanges({required Task original, required Task updated}) {
    Task newUpdatedTask;
    if (TaskExt.hasDataChanges(original: original, updated: updated, includeListIdAndSectionId: false)) {
      newUpdatedTask = state.updatedTask.copyWith(
        updatedAt: Nullable(original.updatedAt),
        globalListIdUpdatedAt: Nullable(DateTime.now().toIso8601String()),
      );
    } else {
      newUpdatedTask = state.updatedTask.copyWith(
        updatedAt: Nullable(original.updatedAt),
        globalListIdUpdatedAt: Nullable(DateTime.now().toIso8601String()),
      );
    }
    emit(state.copyWith(updatedTask: newUpdatedTask));
  }

  modalDismissed({bool updateAllFuture = false, bool hasEditedListIdOrSectionId = false}) async {
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
        late Task updatedRecurringTask;
        if (hasEditedListIdOrSectionId) {
          updatedRecurringTask = state.updatedTask.copyWith(
            id: task.id,
            date: Nullable(task.date),
            datetime: Nullable(task.datetime),
            status: Nullable(task.status),
            createdAt: (task.createdAt),
            trashedAt: (task.trashedAt),
            globalCreatedAt: (task.globalCreatedAt),
            globalUpdatedAt: (task.globalUpdatedAt),
            readAt: (task.readAt),
            globalListIdUpdatedAt: Nullable(now),
          );
        } else {
          updatedRecurringTask = state.updatedTask.copyWith(
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
        }
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

  void updateTitle(String value, {Map<String, MapType>? mapping, String? textWithoutDate}) {
    Task updated = state.updatedTask.copyWith(
      title: value,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );
    if (textWithoutDate != null && textWithoutDate.isNotEmpty) {
      updated = state.updatedTask.copyWith(title: textWithoutDate);
    }
    emit(state.copyWith(updatedTask: updated));

    if (mapping != null) {
      List<MapEntry<String, MapType>> mappings = mapping.entries.toList();

      for (var map in mappings) {
        if (map.value.type == 0) {
          if (value.contains(map.key) == false) {
            planFor(null, statusType: TaskStatusType.inbox);
          }
        }
      }
    }
  }

  void planWithNLP(NLPDateTime nlpDateTime) async {
    late DateTime date;
    if (nlpDateTime.getDate() == null) {
      DateTime now = DateTime.now().toLocal();
      date = DateTime(now.year, now.month, now.day, nlpDateTime.hour ?? 0, nlpDateTime.minute ?? 0);
    } else {
      date = DateTime(nlpDateTime.year ?? 1, nlpDateTime.month ?? 1, nlpDateTime.day ?? 1, nlpDateTime.hour ?? 0,
          nlpDateTime.minute ?? 0);
    }

    await planFor(date,
        dateTime: (date.minute > 0 || date.hour > 0) ? date : null, statusType: TaskStatusType.planned, fromNlp: true);
  }

  setToInbox() {
    print('called setToInbox');
    Task task = state.updatedTask;

    Task updated = task.copyWith(
      date: Nullable(state.originalTask.date),
      datetime: Nullable(state.originalTask.datetime),
      status: Nullable(state.originalTask.status),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));

    _tasksCubit.refreshTasksUi(updated);
  }

  onDateDetected(BuildContext context, NLPDateTime nlpDateTime) {
    if (nlpDateTime.hasDate! || nlpDateTime.hasTime! && !simpleTitleController.isRemoved(nlpDateTime.textWithDate!)) {
      simpleTitleController.removeMapping(0);
      simpleTitleController.addMapping({
        nlpDateTime.textWithDate!: MapType(
            0,
            TextStyle(
              color: ColorsExt.akiflow200(context),
            )),
      });

      planWithNLP(nlpDateTime);
    } else if (!simpleTitleController.isRemoved(nlpDateTime.textWithDate!)) {
      simpleTitleController.addMapping({
        nlpDateTime.textWithDate!: MapType(
            0,
            TextStyle(
              color: ColorsExt.akiflow200(context),
            )),
      });
      planWithNLP(nlpDateTime);
    }
  }

  void updateDescription(String html) {
    Task updated = state.updatedTask.copyWith(
      description: html,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    emit(state.copyWith(updatedTask: updated));
  }

  void onModalClose() {
    print('onModalClose');
    emit(state.copyWith(showDuration: false, showLabelsList: false, showPriority: false));
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
