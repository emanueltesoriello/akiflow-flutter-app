import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/api/account_api.dart';
import 'package:mobile/api/calendar_api.dart';
import 'package:mobile/api/event_api.dart';
import 'package:mobile/api/label_api.dart';
import 'package:mobile/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/repository/calendars_repository.dart';
import 'package:mobile/repository/events_repository.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:models/account/account.dart';
import 'package:models/user.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final DialogService _dialogService = locator<DialogService>();

  final AccountApi _accountApi = locator<AccountApi>();
  final TaskApi _taskApi = locator<TaskApi>();
  final CalendarApi _calendarApi = locator<CalendarApi>();
  final LabelApi _labelApi = locator<LabelApi>();
  final EventApi _eventApi = locator<EventApi>();

  final AccountsRepository _accountsRepository = locator<AccountsRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final CalendarsRepository _calendarsRepository =
      locator<CalendarsRepository>();
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  final EventsRepository _eventsRepository = locator<EventsRepository>();

  final TasksCubit _tasksCubit;

  MainCubit(this._tasksCubit) : super(const MainCubitState()) {
    _init();
  }

  _init() {
    User? user = _preferencesRepository.user;

    if (user != null) {
      _syncTasks();
    }
  }

  Future<void> refresh() async {
    await _syncTasks();
  }

  Future<void> _syncTasks() async {
    List<Account> accountsData = await _accountApi.get();

    if (accountsData.isEmpty) {
      _dialogService.showMessage("No accounts found");
      return;
    }

    Account akiflowAccount =
        accountsData.firstWhere((account) => account.connectorId == 'akiflow');

    Account localAkiflowAccount;

    try {
      localAkiflowAccount = await _accountsRepository.byId(akiflowAccount.id!);
    } catch (_) {
      await _accountsRepository.add([akiflowAccount]);
      localAkiflowAccount = await _accountsRepository.byId(akiflowAccount.id!);
    }

    SyncService accounts = SyncService(
      api: _accountApi,
      databaseRepository: _accountsRepository,
      getLastUpdate: () => localAkiflowAccount.localDetails?.lastAccountsSyncAt,
      setLastUpdate: (lastUpdate) async => _accountsRepository.updateById(
          localAkiflowAccount.id,
          data: localAkiflowAccount
              .rebuild((b) => b..localDetails.lastAccountsSyncAt = lastUpdate)),
    );

    SyncService tasks = SyncService(
      api: _taskApi,
      databaseRepository: _tasksRepository,
      getLastUpdate: () => localAkiflowAccount.localDetails?.lastTasksSyncAt,
      setLastUpdate: (lastUpdate) async => _accountsRepository.updateById(
          localAkiflowAccount.id,
          data: localAkiflowAccount
              .rebuild((b) => b..localDetails.lastTasksSyncAt = lastUpdate)),
    );

    SyncService calendars = SyncService(
      api: _calendarApi,
      databaseRepository: _calendarsRepository,
      getLastUpdate: () =>
          localAkiflowAccount.localDetails?.lastCalendarsSyncAt,
      setLastUpdate: (lastUpdate) async => _accountsRepository.updateById(
          localAkiflowAccount.id,
          data: localAkiflowAccount.rebuild(
              (b) => b..localDetails.lastCalendarsSyncAt = lastUpdate)),
    );

    SyncService labels = SyncService(
      api: _labelApi,
      databaseRepository: _labelsRepository,
      getLastUpdate: () => localAkiflowAccount.localDetails?.lastLabelsSyncAt,
      setLastUpdate: (lastUpdate) async => _accountsRepository.updateById(
          localAkiflowAccount.id,
          data: localAkiflowAccount
              .rebuild((b) => b..localDetails.lastLabelsSyncAt = lastUpdate)),
    );

    SyncService events = SyncService(
      api: _eventApi,
      databaseRepository: _eventsRepository,
      getLastUpdate: () => localAkiflowAccount.localDetails?.lastEventsSyncAt,
      setLastUpdate: (lastUpdate) async => _accountsRepository.updateById(
          localAkiflowAccount.id,
          data: localAkiflowAccount
              .rebuild((b) => b..localDetails.lastEventsSyncAt = lastUpdate)),
    );

    await accounts.start();
    await tasks.start();
    await calendars.start();
    await labels.start();
    await events.start();

    _tasksCubit.refresh();
  }

  void bottomBarViewClick(int index) {
    switch (index) {
      case 1:
        emit(state.copyWith(homeViewType: HomeViewType.inbox));
        break;
      case 2:
        emit(state.copyWith(homeViewType: HomeViewType.today));
        break;
      case 3:
        emit(state.copyWith(homeViewType: HomeViewType.calendar));
        break;
    }
  }

  addTask() async {
    _syncTasks();
  }
}
