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

enum Entity {
  accounts,
  calendars,
  tasks,
  labels,
  events,
}

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

  Account? localAkiflowAccount;

  MainCubit(this._tasksCubit) : super(const MainCubitState()) {
    init();
  }

  init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      await refreshLocalAkiflowAccount();

      if (localAkiflowAccount == null) {
        _dialogService.showMessage("No accounts found");
        return;
      }

      await _sync(Entity.accounts);
      await _sync(Entity.tasks);

      // await _sync(Entity.calendars);
      // await _sync(Entity.labels);
      // await _sync(Entity.events);

      _tasksCubit.refresh();
    }
  }

  Future<void> refreshLocalAkiflowAccount() async {
    if (localAkiflowAccount == null) {
      List<Account> accountsData = await _accountApi.get();

      if (accountsData.isEmpty) {
        return;
      }

      Account akiflowAccount = accountsData
          .firstWhere((account) => account.connectorId == 'akiflow');

      try {
        localAkiflowAccount =
            await _accountsRepository.byId(akiflowAccount.id!);
      } catch (_) {
        await _accountsRepository.add([akiflowAccount]);
        localAkiflowAccount =
            await _accountsRepository.byId(akiflowAccount.id!);
      }
    } else {
      localAkiflowAccount =
          await _accountsRepository.byId(localAkiflowAccount!.id!);
    }
  }

  Future<void> _sync(Entity entity) async {
    switch (entity) {
      case Entity.accounts:
        SyncService service = SyncService(
          akiflowAccount: localAkiflowAccount!,
          api: _accountApi,
          databaseRepository: _accountsRepository,
          lastSyncAt: localAkiflowAccount!.lastAccountsSyncAt,
        );

        await service.start();

        if (service.lastSyncAtUpdated != null) {
          localAkiflowAccount = localAkiflowAccount!.rebuild(
              (b) => b..lastAccountsSyncAt = service.lastSyncAtUpdated);
        }
        break;
      case Entity.calendars:
        SyncService service = SyncService(
          akiflowAccount: localAkiflowAccount!,
          api: _calendarApi,
          databaseRepository: _calendarsRepository,
          lastSyncAt: localAkiflowAccount!.lastCalendarsSyncAt,
        );

        await service.start();

        if (service.lastSyncAtUpdated != null) {
          localAkiflowAccount = localAkiflowAccount!.rebuild(
              (b) => b..lastCalendarsSyncAt = service.lastSyncAtUpdated);
        }
        break;
      case Entity.tasks:
        SyncService service = SyncService(
          akiflowAccount: localAkiflowAccount!,
          api: _taskApi,
          databaseRepository: _tasksRepository,
          lastSyncAt: localAkiflowAccount!.lastTasksSyncAt,
        );

        await service.start();

        if (service.lastSyncAtUpdated != null) {
          localAkiflowAccount = localAkiflowAccount!
              .rebuild((b) => b..lastTasksSyncAt = service.lastSyncAtUpdated);
        }
        break;
      case Entity.labels:
        SyncService service = SyncService(
          akiflowAccount: localAkiflowAccount!,
          api: _labelApi,
          databaseRepository: _labelsRepository,
          lastSyncAt: localAkiflowAccount!.lastLabelsSyncAt,
        );

        await service.start();

        if (service.lastSyncAtUpdated != null) {
          localAkiflowAccount = localAkiflowAccount!
              .rebuild((b) => b..lastLabelsSyncAt = service.lastSyncAtUpdated);
        }
        break;
      case Entity.events:
        SyncService service = SyncService(
          akiflowAccount: localAkiflowAccount!,
          api: _eventApi,
          databaseRepository: _eventsRepository,
          lastSyncAt: localAkiflowAccount!.lastEventsSyncAt,
        );

        await service.start();

        if (service.lastSyncAtUpdated != null) {
          localAkiflowAccount = localAkiflowAccount!
              .rebuild((b) => b..lastEventsSyncAt = service.lastSyncAtUpdated);
        }
        break;
    }

    await _accountsRepository.updateById(localAkiflowAccount!.id!,
        data: localAkiflowAccount);
  }

  void changeHomeView(int index) {
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

  syncClick() async {
    init();
  }

  void logout() {
    localAkiflowAccount = null;
  }
}
