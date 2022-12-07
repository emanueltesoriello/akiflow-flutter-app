import 'dart:async';

import 'package:mobile/core/api/account_api.dart';
import 'package:mobile/core/api/calendar_api.dart';
import 'package:mobile/core/api/docs_api.dart';
import 'package:mobile/core/api/event_api.dart';
import 'package:mobile/core/api/integrations/gmail_api.dart';
import 'package:mobile/core/api/integrations/integration_base_api.dart';
import 'package:mobile/core/api/label_api.dart';
import 'package:mobile/core/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/accounts_repository.dart';
import 'package:mobile/core/repository/calendars_repository.dart';
import 'package:mobile/core/repository/docs_repository.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/repository/labels_repository.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/core/services/sync_integration_service.dart';
import 'package:mobile/core/services/sync_service.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';
import 'package:models/nullable.dart';
import 'package:models/user.dart';

enum Entity { accounts, calendars, tasks, labels, events, docs }

enum IntegrationEntity { gmail }

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

  static bool _isSyncing = false;

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
      hasDataToImport: () async {
        AnalyticsService.track('Tasks imported');
      },
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
      AnalyticsService.track("Trigger sync now");

      if (entities == null) {
        await _syncEntity(Entity.accounts);
        await _syncEntity(Entity.tasks);
        await _syncEntity(Entity.labels);
        await _syncEntity(Entity.docs);
      } else {
        for (Entity entity in entities) {
          await _syncEntity(entity);
        }
      }

      syncCompletedController.add(0);

      // check after docs sync to prevent docs duplicates
      try {
        bool hasNewDocs = await _syncIntegration();

        if (hasNewDocs) {
          await _syncEntity(Entity.docs);
          await _syncEntity(Entity.tasks);
        }
      } catch (e, s) {
        _sentryService.captureException(e, stackTrace: s);
      }
    }

    _isSyncing = false;

    syncCompletedController.add(0);
  }

  Future<void> syncIntegrationWithCheckUser() async {
    if (_isSyncing) {
      print("sync integration already in progress");
      return;
    }

    _isSyncing = true;

    User? user = _preferencesRepository.user;

    if (user != null) {
      bool hasNewDocs = await _syncIntegration();

      if (hasNewDocs) {
        await _syncEntity(Entity.docs);
        await _syncEntity(Entity.tasks);
      }
    }

    _isSyncing = false;

    syncCompletedController.add(0);
  }

  /// Return `true` if there are new docs to import
  Future<bool> _syncIntegration() async {
    List<Account> accounts = await _accountsRepository.get();

    if (accounts.isEmpty) {
      print("no accounts to sync");
      return false;
    }

    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

    bool hasNewDocs = false;

    for (Account account in accounts) {
      AccountToken? accountToken = _preferencesRepository.getAccountToken(account.accountId!);

      if (accountToken == null) {
        print("no account token for ${account.accountId}");
        continue;
      } else {
        print("account token for ${account.accountId}");
      }

      GmailApi gmailApi = GmailApi(account, accountToken: accountToken, saveAkiflowLabelId: (String labelId) {
        Map<String, dynamic> details = account.details ?? {};
        details['akiflowLabelId'] = labelId;

        account = account.copyWith(details: details, updatedAt: Nullable(now));

        _accountsRepository.updateById(account.id, data: account);

        print("updated gmail akiflow label: $labelId");
      });

      DateTime? lastSync = _preferencesRepository.lastSyncForAccountId(account.id!);

      print("sync integration for account ${account.accountId}");

      bool hasNewDocsCheck = await _syncEntityIntegration(gmailApi, lastSync, account);

      if (hasNewDocsCheck == true) {
        hasNewDocs = true;
      }

      print("sync integration for account ${account.accountId} done");
    }

    return hasNewDocs;
  }

  Future<void> _syncEntity(Entity entity) async {
    try {
      print("Syncing $entity...");

      SyncService syncService = _syncServices[entity]!;

      DateTime? lastSync = await _getLastSyncFromPreferences[entity]!();

      DateTime? lastSyncUpdated = await syncService.start(lastSync);

      await _setLastSyncPreferences[entity]!(lastSyncUpdated);
    } catch (e, s) {
      print(e);

      _sentryService.captureException(e, stackTrace: s);
    }
  }

  /// Return `true` if there are new docs to import
  Future<bool> _syncEntityIntegration(IIntegrationBaseApi api, DateTime? lastSync, Account account) async {
    try {
      print("Syncing integration $api...");

      Map<String, dynamic>? params;

      if (api.runtimeType.toString() == "GmailApi") {
        params = {
          "accountId": account.accountId,
          "connectorId": account.connectorId,
          "originAccountId": account.originAccountId,
          "syncMode": account.details?["syncMode"],
          "email": account.identifier,
        };
      }

      DateTime? lastSyncUpdated = await SyncIntegrationService(integrationApi: api).start(lastSync, params: params);

      await _syncEntity(Entity.docs);

      if (lastSyncUpdated != null) {
        await _preferencesRepository.setLastSyncForAccountId(account.id!, lastSyncUpdated);
        return true;
      }
    } catch (e, s) {
      print(e);
      _sentryService.captureException(e, stackTrace: s);
    }

    return false;
  }
}
