import 'dart:async';

import 'package:collection/collection.dart';
import 'package:mobile/api/account_api.dart';
import 'package:mobile/api/account_v2_api.dart';
import 'package:mobile/api/calendar_api.dart';
import 'package:mobile/api/docs_api.dart';
import 'package:mobile/api/event_api.dart';
import 'package:mobile/api/integrations/gmail_api.dart';
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
import 'package:mobile/services/sync_integration_service.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:models/account/account.dart';
import 'package:models/user.dart';

enum Entity { accountsV2, accounts, calendars, tasks, labels, events, docs }

enum IntegrationEntity { gmail }

class SyncControllerService {
  static final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  static final AccountV2Api _accountV2Api = locator<AccountV2Api>();
  static final AccountApi _accountApi = locator<AccountApi>();
  static final TaskApi _taskApi = locator<TaskApi>();
  static final CalendarApi _calendarApi = locator<CalendarApi>();
  static final LabelApi _labelApi = locator<LabelApi>();
  static final EventApi _eventApi = locator<EventApi>();
  static final DocsApi _docsApi = locator<DocsApi>();

  static final GmailApi _gmailApi = locator<GmailApi>();

  static final AccountsRepository _accountsRepository = locator<AccountsRepository>();
  static final TasksRepository _tasksRepository = locator<TasksRepository>();
  static final CalendarsRepository _calendarsRepository = locator<CalendarsRepository>();
  static final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  static final EventsRepository _eventsRepository = locator<EventsRepository>();
  static final DocsRepository _docsRepository = locator<DocsRepository>();

  final SentryService _sentryService = locator<SentryService>();

  static bool _isSyncing = false;

  final Map<Entity, SyncService> _syncServices = {
    Entity.accountsV2: SyncService(
      api: _accountV2Api,
      databaseRepository: _accountsRepository,
    ),
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

  final Map<dynamic, Function()> _getLastSyncFromPreferences = {
    Entity.accountsV2: () => _preferencesRepository.lastAccountsV2SyncAt,
    Entity.accounts: () => _preferencesRepository.lastAccountsSyncAt,
    Entity.calendars: () => _preferencesRepository.lastCalendarsSyncAt,
    Entity.tasks: () => _preferencesRepository.lastTasksSyncAt,
    Entity.labels: () => _preferencesRepository.lastLabelsSyncAt,
    Entity.events: () => _preferencesRepository.lastEventsSyncAt,
    Entity.docs: () => _preferencesRepository.lastDocsSyncAt,
    IntegrationEntity.gmail: () => _preferencesRepository.lastGmailSyncAt,
  };

  final Map<dynamic, Function(DateTime?)> _setLastSyncPreferences = {
    Entity.accountsV2: _preferencesRepository.setLastAccountsV2SyncAt,
    Entity.accounts: _preferencesRepository.setLastAccountsSyncAt,
    Entity.calendars: _preferencesRepository.setLastCalendarsSyncAt,
    Entity.tasks: _preferencesRepository.setLastTasksSyncAt,
    Entity.labels: _preferencesRepository.setLastLabelsSyncAt,
    Entity.events: _preferencesRepository.setLastEventsSyncAt,
    Entity.docs: _preferencesRepository.setLastDocsSyncAt,
    IntegrationEntity.gmail: _preferencesRepository.setLastGmailSyncAt,
  };

  final Map<IntegrationEntity, SyncIntegrationService> _syncIntegrationServices = {
    IntegrationEntity.gmail: SyncIntegrationService(integrationApi: _gmailApi),
  };

  Map<IntegrationEntity, Account?>? _syncIntegrationServicesAccount;

  final StreamController syncCompletedController = StreamController.broadcast();
  Stream get syncCompletedStream => syncCompletedController.stream;

  sync([List<Entity>? entities]) async {
    if (_isSyncing) {
      print("sync already in progress");
      return;
    }

    _isSyncing = true;

    User? user = _preferencesRepository.user;

    if (user != null) {
      if (entities == null) {
        await _syncEntity(Entity.accountsV2);
        await _syncEntity(Entity.accounts);
        await _syncEntity(Entity.tasks);
        await _syncEntity(Entity.labels);
        await _syncEntity(Entity.docs);
      } else {
        for (Entity entity in entities) {
          await _syncEntity(entity);
        }
      }
    }

    _isSyncing = false;

    syncCompletedController.add(0);

    // TODO test -> syncIntegration();
  }

  syncIntegration([List<IntegrationEntity>? entities]) async {
    if (_isSyncing) {
      print("sync already in progress");
      return;
    }

    _isSyncing = true;

    List<Account> accounts = await _accountsRepository.get();

    _syncIntegrationServicesAccount = {
      IntegrationEntity.gmail: accounts.firstWhereOrNull((element) => element.connectorId == "gmail")
    };

    User? user = _preferencesRepository.user;

    if (user != null) {
      if (entities == null) {
        await _syncIntegration(IntegrationEntity.gmail);
      } else {
        for (IntegrationEntity entity in entities) {
          await _syncIntegration(entity);
        }
      }
    }

    _isSyncing = false;

    syncCompletedController.add(0);
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

  Future<void> _syncIntegration(IntegrationEntity integrationEntity) async {
    try {
      print("Syncing integration $integrationEntity...");

      SyncIntegrationService syncService = _syncIntegrationServices[integrationEntity]!;
      Account? account = _syncIntegrationServicesAccount?[integrationEntity]!;

      if (account == null) {
        print("no $integrationEntity account found");
        return;
      }

      DateTime? lastSync = await _getLastSyncFromPreferences[integrationEntity]!();

      Map<String, dynamic>? params;

      if (integrationEntity == IntegrationEntity.gmail) {
        params = {
          "accountId": account.accountId,
          "connectorId": account.connectorId,
          "originAccountId": account.originAccountId,
          "syncMode": account.details?["syncMode"],
          "email": account.identifier,
        };
      }

      DateTime? lastSyncUpdated = await syncService.start(lastSync, params: params);

      await _setLastSyncPreferences[integrationEntity]!(lastSyncUpdated);
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }
}
