import 'package:i18n/strings.g.dart';
import 'package:mobile/api/account_api.dart';
import 'package:mobile/api/calendar_api.dart';
import 'package:mobile/api/event_api.dart';
import 'package:mobile/api/label_api.dart';
import 'package:mobile/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/repository/calendars_repository.dart';
import 'package:mobile/repository/events_repository.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:models/account/account.dart';
import 'package:models/user.dart';

enum Entity { accounts, calendars, tasks, labels, events }

class SyncControllerService {
  static final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final DialogService _dialogService = locator<DialogService>();

  static final AccountApi _accountApi = locator<AccountApi>();
  static final TaskApi _taskApi = locator<TaskApi>();
  static final CalendarApi _calendarApi = locator<CalendarApi>();
  static final LabelApi _labelApi = locator<LabelApi>();
  static final EventApi _eventApi = locator<EventApi>();

  static final AccountsRepository _accountsRepository =
      locator<AccountsRepository>();
  static final TasksRepository _tasksRepository = locator<TasksRepository>();
  static final CalendarsRepository _calendarsRepository =
      locator<CalendarsRepository>();
  static final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  static final EventsRepository _eventsRepository = locator<EventsRepository>();

  final Map<Entity, SyncService> _syncServices = {
    Entity.accounts: SyncService(
      api: _accountApi,
      databaseRepository: _accountsRepository,
    ),
    Entity.calendars: SyncService(
      api: _calendarApi,
      databaseRepository: _calendarsRepository,
    ),
    Entity.tasks: SyncService(
      api: _taskApi,
      databaseRepository: _tasksRepository,
    ),
    Entity.labels: SyncService(
      api: _labelApi,
      databaseRepository: _labelsRepository,
    ),
    Entity.events: SyncService(
      api: _eventApi,
      databaseRepository: _eventsRepository,
    ),
  };

  final Map<Entity, Function()> _getLastSyncFromPreferences = {
    Entity.accounts: () => _preferencesRepository.lastAccountsSyncAt,
    Entity.calendars: () => _preferencesRepository.lastCalendarsSyncAt,
    Entity.tasks: () => _preferencesRepository.lastTasksSyncAt,
    Entity.labels: () => _preferencesRepository.lastLabelsSyncAt,
    Entity.events: () => _preferencesRepository.lastEventsSyncAt,
  };

  final Map<Entity, Function(DateTime?)> _setLastSyncPreferences = {
    Entity.accounts: _preferencesRepository.setLastAccountsSyncAt,
    Entity.calendars: _preferencesRepository.setLastCalendarsSyncAt,
    Entity.tasks: _preferencesRepository.setLastTasksSyncAt,
    Entity.labels: _preferencesRepository.setLastLabelsSyncAt,
    Entity.events: _preferencesRepository.setLastEventsSyncAt,
  };

  sync() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      await _syncEntity(Entity.accounts);

      List<Account> accounts = await _accountsRepository.get();

      if (accounts.isEmpty) {
        _dialogService.showMessage(t.errors.noAccountsFound);
        return;
      }

      await _syncEntity(Entity.tasks);
      await _syncEntity(Entity.labels);

      // await _sync(Entity.calendars);
      // await _sync(Entity.events);

    }
  }

  Future<void> _syncEntity(Entity entity) async {
    SyncService syncService = _syncServices[entity]!;

    DateTime? lastSync = await _getLastSyncFromPreferences[entity]!();

    DateTime? lastSyncUpdated = await syncService.start(lastSync);

    await _setLastSyncPreferences[entity]!(lastSyncUpdated);
  }
}
