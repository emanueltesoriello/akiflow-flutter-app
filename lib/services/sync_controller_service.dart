import 'package:mobile/api/account_api.dart';
import 'package:mobile/api/calendar_api.dart';
import 'package:mobile/api/docs_api.dart';
import 'package:mobile/api/event_api.dart';
import 'package:mobile/api/label_api.dart';
import 'package:mobile/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/repository/calendars_repository.dart';
import 'package:mobile/repository/docs_repository.dart';
import 'package:mobile/repository/events_repository.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:models/user.dart';

enum Entity { accounts, calendars, tasks, labels, events, docs }

class SyncControllerService {
  static final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  static final AccountApi _accountApi = locator<AccountApi>();
  static final TaskApi _taskApi = locator<TaskApi>();
  static final CalendarApi _calendarApi = locator<CalendarApi>();
  static final LabelApi _labelApi = locator<LabelApi>();
  static final EventApi _eventApi = locator<EventApi>();
  static final DocsApi _docsApi = locator<DocsApi>();

  static final AccountsRepository _accountsRepository = locator<AccountsRepository>();
  static final TasksRepository _tasksRepository = locator<TasksRepository>();
  static final CalendarsRepository _calendarsRepository = locator<CalendarsRepository>();
  static final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  static final EventsRepository _eventsRepository = locator<EventsRepository>();
  static final DocsRepository _docsRepository = locator<DocsRepository>();

  final SentryService _sentryService = locator<SentryService>();

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
    Entity.docs: SyncService(
      api: _docsApi,
      databaseRepository: _docsRepository,
    ),
  };

  final Map<Entity, Function()> _getLastSyncFromPreferences = {
    Entity.accounts: () => _preferencesRepository.lastAccountsSyncAt,
    Entity.calendars: () => _preferencesRepository.lastCalendarsSyncAt,
    Entity.tasks: () => _preferencesRepository.lastTasksSyncAt,
    Entity.labels: () => _preferencesRepository.lastLabelsSyncAt,
    Entity.events: () => _preferencesRepository.lastEventsSyncAt,
    Entity.docs: () => _preferencesRepository.lastDocsSyncAt,
  };

  final Map<Entity, Function(DateTime?)> _setLastSyncPreferences = {
    Entity.accounts: _preferencesRepository.setLastAccountsSyncAt,
    Entity.calendars: _preferencesRepository.setLastCalendarsSyncAt,
    Entity.tasks: _preferencesRepository.setLastTasksSyncAt,
    Entity.labels: _preferencesRepository.setLastLabelsSyncAt,
    Entity.events: _preferencesRepository.setLastEventsSyncAt,
    Entity.docs: _preferencesRepository.setLastDocsSyncAt,
  };

  syncAll() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      await _syncEntity(Entity.accounts);
      await _syncEntity(Entity.tasks);
      await _syncEntity(Entity.labels);
      await _syncEntity(Entity.docs);
    }
  }

  Future<void> _syncEntity(Entity entity) async {
    try {
      print("Syncing $entity...");

      SyncService syncService = _syncServices[entity]!;

      DateTime? lastSync = await _getLastSyncFromPreferences[entity]!();

      DateTime? lastSyncUpdated = await syncService.start(lastSync);

      await _setLastSyncPreferences[entity]!(lastSyncUpdated);
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }
}
