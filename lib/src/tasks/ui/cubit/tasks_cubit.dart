import 'dart:async';

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/core/api/integrations/gmail_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/accounts_repository.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/base/models/gmail_mark_as_done_type.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/doc_action.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/change_priority_modal.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final SentryService _sentryService = locator<SentryService>();
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();

  final StreamController<List<Task>> _editRecurringTasksDialog = StreamController<List<Task>>.broadcast();
  Stream<List<Task>> get editRecurringTasksDialog => _editRecurringTasksDialog.stream;

  final StreamController<void> _scrollListStreamController = StreamController<void>.broadcast();
  Stream<void> get scrollListStream => _scrollListStreamController.stream;

  final StreamController<List<GmailDocAction>> _docActionsController =
      StreamController<List<GmailDocAction>>.broadcast();
  Stream<List<GmailDocAction>> get docActionsStream => _docActionsController.stream;

  final SyncCubit _syncCubit;

  AuthCubit? _authCubit;
  LabelsCubit? _labelsCubit;
  TodayCubit? _todayCubit;

  TasksCubit(this._syncCubit) : super(const TasksCubitState()) {
    print("listen tasks sync");

    bool firstTimeLoaded = _preferencesRepository.firstTimeLoaded;
    emit(state.copyWith(loading: firstTimeLoaded == false));

    refreshAllFromRepository();

    _syncCubit.syncCompletedStream.listen((_) async {
      await refreshAllFromRepository();

      if (firstTimeLoaded == false) {
        _preferencesRepository.setFirstTimeLoaded(true);
        emit(state.copyWith(loading: false));
      }

      _syncCubit.emit(_syncCubit.state.copyWith(loading: false));
    });
  }

  attachAuthCubit(AuthCubit authCubit) {
    _authCubit = authCubit;
  }

  attachTodayCubit(TodayCubit todayCubit) {
    _todayCubit = todayCubit;
  }

  attachLabelCubit(LabelsCubit labelsCubit) {
    _labelsCubit = labelsCubit;
  }

  syncAllAndRefresh() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      await _syncCubit.sync(entities: [Entity.tasks]);
      NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
    }
  }

  void refreshTasksUi(Task task) {
    emit(state.copyWith(
      inboxTasks: state.inboxTasks.map((task) => task.id == task.id ? task : task).toList(),
      selectedDayTasks: state.selectedDayTasks.map((task) => task.id == task.id ? task : task).toList(),
      labelTasks: state.labelTasks.map((task) => task.id == task.id ? task : task).toList(),
      fixedTodayTasks: state.fixedTodayTasks.map((task) => task.id == task.id ? task : task).toList(),
    ));
  }

  Future refreshAllFromRepository() async {
    await Future.wait([
      fetchInbox(),
      fetchTodayTasks(),
      _todayCubit != null ? fetchSelectedDayTasks(_todayCubit!.state.selectedDate) : Future.value(),
      _labelsCubit?.state.selectedLabel != null ? fetchLabelTasks(_labelsCubit!.state.selectedLabel!) : Future.value(),
    ]);

    emit(state.copyWith(tasksLoaded: true));
  }

  Future fetchInbox() async {
    try {
      List<Task> inboxTasks = await _tasksRepository.getInbox();
      emit(state.copyWith(inboxTasks: inboxTasks));
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }

  Future fetchTodayTasks() async {
    try {
      List<Task> fixedTodayTasks = await _tasksRepository.getTodayTasks(date: DateTime.now());
      emit(state.copyWith(fixedTodayTasks: fixedTodayTasks));
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }

  CancelableOperation<List<Task>>? cancellableOperation;

  Future<List<Task>> fromCancelable(Future<List<Task>> future) async {
    if (cancellableOperation != null) {
      cancellableOperation!.cancel();
    }
    cancellableOperation = CancelableOperation<List<Task>>.fromFuture(future);
    return cancellableOperation!.value;
  }

  Future fetchSelectedDayTasks(DateTime date) async {
    try {
      List<Task> todayTasks = await fromCancelable(_tasksRepository.getTodayTasks(date: date));
      emit(state.copyWith(selectedDayTasks: todayTasks));
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }

  Future<void> fetchLabelTasks(Label selectedLabel) async {
    try {
      List<Task> tasks = await _tasksRepository.getLabelTasks(selectedLabel);
      emit(state.copyWith(labelTasks: tasks));
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }

  Future<void> getTodayTasksByDate(DateTime selectedDay) async {
    try {
      await fetchSelectedDayTasks(selectedDay);
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
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

    List<Task> tasksChanged = [];

    for (Task taskSelected in all) {
      Task updated = taskSelected.markAsDone(taskSelected);

      await _tasksRepository.updateById(taskSelected.id, data: updated);

      refreshTasksUi(updated);

      tasksChanged.add(updated);
    }

    refreshAllFromRepository();

    clearSelected();

    _syncCubit.sync(entities: [Entity.tasks]);

    handleDocAction(tasksChanged);
    NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
  }

  Future<void> duplicate() async {
    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

    List<Task> duplicates = [];

    List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
    List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
    List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();

    List<Task> all = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];
    all = all.toSet().toList();

    for (Task task in all) {
      Task newTaskDuplicated = task.copyWith(
        id: const Uuid().v4(),
        updatedAt: Nullable(now),
        createdAt: now,
        selected: false,
        doc: Nullable(null),
        connectorId: Nullable(null),
        originId: Nullable(null),
        originAccountId: Nullable(null),
      );
      duplicates.add(newTaskDuplicated);
    }

    await _tasksRepository.add(duplicates);

    refreshAllFromRepository();

    clearSelected();

    _syncCubit.sync(entities: [Entity.tasks]);
    NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
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
        status: Nullable(TaskStatusType.trashed.id),
        trashedAt: now,
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

    AnalyticsService.track("Tasks deleted");
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

  Future<void> update(List<Task> tasksSelected, {bool andFutureTasks = false}) async {
    if (andFutureTasks) {
      List<Task> inboxTasksWithRecurrence = state.inboxTasks.where((element) => element.recurringId != null).toList();
      List<Task> todayTasksWithRecurrence =
          state.selectedDayTasks.where((element) => element.recurringId != null).toList();
      List<Task> allWithRecurrence = [...inboxTasksWithRecurrence, ...todayTasksWithRecurrence];

      List<String> recurringIds = allWithRecurrence.map((t) => t.recurringId!).toList();
      List<Task> tasksWithRecurringIds = await _tasksRepository.getByRecurringIds(recurringIds);

      // filter tasks with date > today
      tasksWithRecurringIds = tasksWithRecurringIds
          .where((t) => t.date != null && DateTime.parse(t.date!).isAfter(DateTime.now()))
          .toList();

      List<Task> allSelectedAndWithRecurrenceId = [...tasksWithRecurringIds, ...tasksSelected];

      List<Task> updatedRecurringTasks = [];

      DateTime now = DateTime.now();

      for (Task task in allSelectedAndWithRecurrenceId) {
        Task updatedRecurringTask = task.copyWith(
          listId: Nullable(allSelectedAndWithRecurrenceId.first.listId),
          updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
          priority: allSelectedAndWithRecurrenceId.first.priority,
          duration: Nullable(allSelectedAndWithRecurrenceId.first.duration),
          trashedAt: TzUtils.toUtcStringIfNotNull(now),
        );

        updatedRecurringTasks.add(updatedRecurringTask);
      }

      for (Task task in updatedRecurringTasks) {
        await _tasksRepository.updateById(task.id!, data: task);
        refreshTasksUi(task);
      }
    } else {
      for (Task task in tasksSelected) {
        await _tasksRepository.updateById(task.id, data: task);
        refreshTasksUi(task);
      }
    }

    refreshAllFromRepository();

    clearSelected();

    _syncCubit.sync(entities: [Entity.tasks]);
    NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
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

      refreshTasksUi(updated);
    }

    refreshAllFromRepository();

    clearSelected();

    _syncCubit.sync(entities: [Entity.tasks]);

    if (date != null) {
      AnalyticsService.track("Tasks deadline set");
    } else {
      AnalyticsService.track("Tasks deadline unset");
    }
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
    required HomeViewType homeViewType,
  }) async {
    List<Task> updated = newTasksListOrdered.toList();

    Task task = updated.removeAt(oldIndex);

    updated.insert(newIndex, task);

    if (homeViewType == HomeViewType.inbox) {
      emit(state.copyWith(inboxTasks: updated));
    } else if (homeViewType == HomeViewType.today) {
      emit(state.copyWith(selectedDayTasks: updated));
    } else if (homeViewType == HomeViewType.label) {
      emit(state.copyWith(labelTasks: updated));
    }

    DateTime now = DateTime.now().toUtc();
    Nullable<String?>? nowString = Nullable(TzUtils.toUtcStringIfNotNull(now));
    int millis = now.millisecondsSinceEpoch;

    if (sorting != null &&
        (sorting == TaskListSorting.sortingAscending || sorting == TaskListSorting.sortingLabelAscending)) {
      updated = updated.reversed.toList();
    }

    for (int i = 0; i < updated.length; i++) {
      Task updatedTask = updated[i];

      switch (sorting) {
        case TaskListSorting.sortingLabelAscending:
          updatedTask = updatedTask.copyWith(
            sortingLabel: millis - (i * 1),
            updatedAt: nowString,
            selected: false,
          );
          break;
        default:
          updatedTask = updatedTask.copyWith(
            sorting: millis - (i * 1),
            updatedAt: nowString,
            selected: false,
          );
          break;
      }

      updated[i] = updatedTask;
    }

    for (int i = 0; i < updated.length; i++) {
      Task updatedTask = updated[i];

      await _tasksRepository.updateById(updatedTask.id, data: updatedTask);
    }

    refreshAllFromRepository();

    clearSelected();

    _syncCubit.sync(entities: [Entity.tasks]);
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
    planFor(DateTime.now(), dateTime: null, statusType: TaskStatusType.planned);
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

    addToUndoQueue(allSelected, statusType == TaskStatusType.planned ? UndoType.plan : UndoType.snooze);

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

      refreshTasksUi(updated);
    }

    refreshAllFromRepository();

    clearSelected();

    _syncCubit.sync(entities: [Entity.tasks]);
    NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());

    if (statusType == TaskStatusType.inbox && date == null && dateTime == null) {
      AnalyticsService.track("Tasks unplanned");
    } else if (statusType == TaskStatusType.snoozed) {
      AnalyticsService.track("Tasks snoozed");
    } else if (statusType == TaskStatusType.planned) {
      AnalyticsService.track("Tasks planned");
    }
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

  void setJustCreatedTask(Task task) {
    _scrollListStreamController.add(null);

    //emit(state.copyWith(justCreatedTask: Nullable(task)));

    //Timer(const Duration(seconds: 3), () {
    emit(state.copyWith(justCreatedTask: Nullable(null)));
    //});
  }

  Future<void> undo() async {
    List<UndoTask> queue = state.queue.toList();

    DateTime now = DateTime.now();

    for (var element in queue) {
      Task updated = element.task.copyWith(
        updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(now)),
      );

      await _tasksRepository.updateById(updated.id, data: updated);

      refreshTasksUi(updated);
    }

    emit(state.copyWith(queue: []));

    refreshAllFromRepository();

    _syncCubit.sync(entities: [Entity.tasks]);
    NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());

    switch (queue.first.type) {
      case UndoType.restore:
        AnalyticsService.track("Task Restored");
        break;
      default:
    }
  }

  Future<void> markLabelTasksAsDone() async {
    List<Task> labelTasksSelected = state.labelTasks.toList();

    for (Task task in labelTasksSelected) {
      Task updated = task.markAsDone(task);

      await _tasksRepository.updateById(updated.id, data: updated);

      refreshTasksUi(updated);
    }

    refreshAllFromRepository();

    clearSelected();

    _syncCubit.sync(entities: [Entity.tasks]);
    NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());

    emit(state.copyWith(labelTasks: []));
  }

  Future<void> handleDocAction(List<Task> tasks) async {
    List<Task> all;

    if (tasks.isNotEmpty) {
      all = tasks;
    } else {
      List<Task> inboxSelected = state.inboxTasks.where((t) => t.selected ?? false).toList();
      List<Task> todayTasksSelected = state.selectedDayTasks.where((t) => t.selected ?? false).toList();
      List<Task> labelTasksSelected = state.labelTasks.where((t) => t.selected ?? false).toList();
      all = [...inboxSelected, ...todayTasksSelected, ...labelTasksSelected];
    }

    List<Task> gmailTasks = [];

    for (var task in all) {
      if (task.connectorId != null && task.connectorId!.value! == 'gmail' && task.doc != null) {
        gmailTasks.add(task);
      }
    }

    List<GmailDocAction> docActions = [];

    for (Task task in gmailTasks) {
      String? markAsDoneKey = _authCubit!.state.user?.settings?['popups']['gmail.unstar'];
      GmailMarkAsDoneType gmailMarkAsDoneType = GmailMarkAsDoneType.fromKey(markAsDoneKey);

      List<Account> accounts = await _accountsRepository.get();
      Account account = accounts.firstWhere((a) => a.originAccountId == task.originAccountId?.value!);

      switch (gmailMarkAsDoneType) {
        case GmailMarkAsDoneType.unstarTheEmail:
          docActions.add(GmailDocAction(
            markAsDoneType: GmailMarkAsDoneType.unstarTheEmail,
            task: task,
            account: account,
          ));
          break;
        case GmailMarkAsDoneType.goToGmail:
          docActions.add(GmailDocAction(
            markAsDoneType: GmailMarkAsDoneType.goToGmail,
            task: task,
            account: account,
          ));
          break;
        case GmailMarkAsDoneType.askMeEveryTime:
          docActions.add(GmailDocAction(
            markAsDoneType: GmailMarkAsDoneType.askMeEveryTime,
            task: task,
            account: account,
          ));
          break;
        default:
      }
    }

    GmailMarkAsDoneType gmailMarkAsDoneType = GmailMarkAsDoneType.fromKey(
      _authCubit!.state.user?.settings?['popups']['gmail.unstar'],
    );

    switch (gmailMarkAsDoneType) {
      case GmailMarkAsDoneType.unstarTheEmail:
        for (GmailDocAction docAction in docActions) {
          await unstarGmail(docAction);
        }
        break;
      case GmailMarkAsDoneType.goToGmail:
        for (GmailDocAction docAction in docActions) {
          await launchUrl(Uri.parse(docAction.task.doc!.value!.url!), mode: LaunchMode.externalApplication);
        }
        break;
      case GmailMarkAsDoneType.askMeEveryTime:
        if (docActions.isNotEmpty) {
          _docActionsController.add(docActions);
        }
        break;
      default:
    }
  }

  Future<void> unstarGmail(GmailDocAction action) async {
    Account account = action.account;
    AccountToken? accountToken =
        _preferencesRepository.getAccountToken(account.accountId!.replaceAll("google", "gmail"))!;

    GmailApi gmailApi = GmailApi(account, accountToken: accountToken, saveAkiflowLabelId: (String labelId) {});

    await gmailApi.unstar(action.task.originId!.value!);
  }

  Future<void> goToGmail(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
