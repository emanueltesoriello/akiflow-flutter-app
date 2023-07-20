import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:mobile/core/api/account_api.dart';
import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/api/calendar_api.dart';
import 'package:mobile/core/api/contacts_api.dart';
import 'package:mobile/core/api/client_api.dart';
import 'package:mobile/core/api/event_api.dart';
import 'package:mobile/core/api/event_modifiers_api.dart';
import 'package:mobile/core/api/integrations/gmail_api.dart';
import 'package:mobile/core/api/integrations/integration_base_api.dart';
import 'package:mobile/core/api/label_api.dart';
import 'package:mobile/core/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/accounts_repository.dart';
import 'package:mobile/core/repository/calendars_repository.dart';
import 'package:mobile/core/repository/contacts_repository.dart';
import 'package:mobile/core/repository/event_modifiers_repository.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/repository/labels_repository.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/core/services/sync_integration_service.dart';
import 'package:mobile/core/services/sync_service.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';
import 'package:models/client/client.dart';
import 'package:models/nullable.dart';
import 'package:models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

enum Entity { accounts, calendars, contacts, tasks, labels, events, eventModifiers }

enum IntegrationEntity { gmail }

class SyncControllerService {
  static final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  static final AccountApi _accountApi = locator<AccountApi>();
  static final TaskApi _taskApi = locator<TaskApi>();
  static final CalendarApi _calendarApi = locator<CalendarApi>();
  static final LabelApi _labelApi = locator<LabelApi>();
  static final EventApi _eventApi = locator<EventApi>();
  static final EventModifiersApi _eventModifiersApi = locator<EventModifiersApi>();
  static final ContactsApi _contactsApi = locator<ContactsApi>();

  static final AccountsRepository _accountsRepository = locator<AccountsRepository>();
  static final TasksRepository _tasksRepository = locator<TasksRepository>();
  static final CalendarsRepository _calendarsRepository = locator<CalendarsRepository>();
  static final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  static final EventsRepository _eventsRepository = locator<EventsRepository>();
  static final CalendarCubit _calendarCubit = locator<CalendarCubit>();
  static final EventModifiersRepository _eventModifiersRepository = locator<EventModifiersRepository>();
  static final ContactsRepository _contactsRepository = locator<ContactsRepository>();

  static final SentryService _sentryService = locator<SentryService>();

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
        // AnalyticsService.track('Tasks imported');
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
    Entity.eventModifiers: SyncService(
      api: _eventModifiersApi,
      databaseRepository: _eventModifiersRepository,
    ),
    Entity.contacts: SyncService(
      api: _contactsApi,
      databaseRepository: _contactsRepository,
    ),
  };

  final Map<Entity, Function()> getLastSyncFromPreferences = {
    Entity.accounts: () => _preferencesRepository.lastAccountsSyncAt,
    Entity.calendars: () => _preferencesRepository.lastCalendarsSyncAt,
    Entity.tasks: () => _preferencesRepository.lastTasksSyncAt,
    Entity.labels: () => _preferencesRepository.lastLabelsSyncAt,
    Entity.events: () => _preferencesRepository.lastEventsSyncAt,
    Entity.eventModifiers: () => _preferencesRepository.lastEventModifiersSyncAt,
    Entity.contacts: () => _preferencesRepository.lastContactsSyncAt
  };

  final Map<Entity, Function(DateTime?)> _setLastSyncPreferences = {
    Entity.accounts: _preferencesRepository.setLastAccountsSyncAt,
    Entity.calendars: _preferencesRepository.setLastCalendarsSyncAt,
    Entity.tasks: _preferencesRepository.setLastTasksSyncAt,
    Entity.labels: _preferencesRepository.setLastLabelsSyncAt,
    Entity.events: _preferencesRepository.setLastEventsSyncAt,
    Entity.eventModifiers: _preferencesRepository.setLastEventModifiersSyncAt,
    Entity.contacts: _preferencesRepository.setLastContactsSyncAt,
  };

  final String _getDeviceUUID = _preferencesRepository.deviceUUID;
  _setDeviceUUID(newId) => _preferencesRepository.setDeviceUUID(newId);

  final int _getRecurringBackgroundSyncCounter = _preferencesRepository.recurringBackgroundSyncCounter;
  _setRecurringBackgroundSyncCounter(val) => _preferencesRepository.setRecurringBackgroundSyncCounter(val);

  final int _getRecurringNotificationsSyncCounter = _preferencesRepository.recurringNotificationsSyncCounter;
  _setRecurringNotificationsSyncCounter(val) => _preferencesRepository.setRecurringNotificationsSyncCounter(val);

  final String _getLastSavedTimeZone = _preferencesRepository.getLastSavedTimeZone;
  _setLastSavedTimeZone(val) => _preferencesRepository.setLastSavedTimeZone(val);

  final StreamController syncCompletedController = StreamController.broadcast();
  Stream get syncCompletedStream => syncCompletedController.stream;

  Timer? debounce;

  scheduleNotifications() {
    EventExt.eventNotifications(_eventsRepository, _calendarCubit.state.calendars).then(
      (eventNotifications) async {
        NotificationsService.scheduleEvents(_preferencesRepository, eventNotifications).then((_) async {
          NotificationsService.scheduleEventsTasksAndOthers(null);
        });
      },
    );
  }

  @pragma('vm:entry-point')
  sync() async {
    await FlutterIsolate.spawn(backgroundProcesses, backgroundSyncFromNotification);
  }

  isolateSync([List<Entity>? entities]) async {
    print("started sync");

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
        await _syncEntity(Entity.calendars);
        await _syncEntity(Entity.events);
        await _syncEntity(Entity.eventModifiers);
        await _syncEntity(Entity.contacts);
      } else {
        for (Entity entity in entities) {
          await _syncEntity(entity);
        }
      }
      _isSyncing = false;
      syncCompletedController.add(0);

      try {
        postClient();
      } catch (e, s) {
        _sentryService.captureException(e, stackTrace: s);
      }
      try {
        scheduleNotifications();
      } catch (e, s) {
        _sentryService.captureException(e, stackTrace: s);
      }

      // check after docs sync to prevent docs duplicates
      try {
        await _syncIntegration();
        // bool hasNewDocs = await _syncIntegration();

        // if (hasNewDocs) {
        //   await _syncEntity(Entity.tasks);
        // }
      } catch (e, s) {
        _sentryService.captureException(e, stackTrace: s);
      }
    }

    _isSyncing = false;

    return;
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
        _syncEntity(Entity.tasks);
      }
    }

    _isSyncing = false;

    syncCompletedController.add(0);
  }

  /// Return `true` if there are new docs to import
  Future<bool> _syncIntegration() async {
    List<Account> accounts = await _accountsRepository.getAccounts();

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
      print(hasNewDocsCheck);

      if (hasNewDocsCheck == true) {
        hasNewDocs = true;
      }

      print("sync integration for account ${account.accountId} done");
    }

    return hasNewDocs;
  }

  Future postClient() async {
    try {
      ApiClient api = ClientApi();

      DateTime? lastSyncTasks = await getLastSyncFromPreferences[Entity.tasks]!();
      DateTime? lastSyncAccounts = await getLastSyncFromPreferences[Entity.accounts]!();
      DateTime? lastSyncLabels = await getLastSyncFromPreferences[Entity.labels]!();

      int recurringBackgroundSyncCounter = _getRecurringBackgroundSyncCounter;
      int recurringNotificationsSyncCounter = _getRecurringNotificationsSyncCounter;
      String lastSavedTimeZone = _getLastSavedTimeZone;

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('no access to firebase from background');
      }

      String id = _getDeviceUUID;
      String os = Platform.isAndroid ? "android" : "ios";

      int userId = _preferencesRepository.user!.id ?? 0;

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;
      String? deviceId = deviceInfo.toMap()['id'];
      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

      Client client = Client(
          id: id,
          deviceId: deviceId,
          userId: userId,
          os: os,
          lastAccountsSyncStartedAt: lastSyncAccounts?.toUtc().toIso8601String(),
          unsafeLastAccountsSyncEndedAt: lastSyncAccounts?.toUtc().toIso8601String(),
          lastLabelsSyncStartedAt: lastSyncLabels?.toUtc().toIso8601String(),
          unsafeLastLabelsSyncEndedAt: lastSyncLabels?.toUtc().toIso8601String(),
          lastTasksSyncStartedAt: lastSyncTasks?.toUtc().toIso8601String(),
          unsafeLastTasksSyncEndedAt: lastSyncTasks?.toUtc().toIso8601String(),
          timezoneName: currentTimeZone,
          release: '${packageInfo.version} ${packageInfo.buildNumber}',
          recurringBackgroundSyncCounter: recurringBackgroundSyncCounter,
          recurringNotificationsSyncCounter: recurringNotificationsSyncCounter,
          notificationsRevoked: false);

      Client c = fcmToken != null ? client.copyWith(notificationsToken: Nullable(fcmToken)) : client;

      Map<String, dynamic>? response = await api.postClient(
        client: c.toMap(),
      );

      if (response != null) {
        //String? deviceIdFromServer = response['id'];
        String? timezoneFromServer = response['timezone_name'];
        int recurringNotificationsSyncCounterFromServer = response['recurring_notifications_sync_counter'] ?? 0;
        int recurringBackgroundSyncCounterFromServer = response['recurring_background_sync_counter'] ?? 0;

        /*// in case of new app installation but same device ID
        // this will set the same ID on the device that was set as first on the server
        if (deviceIdFromServer != null && deviceIdFromServer != client.id) {
          _setDeviceUUID(deviceIdFromServer);
        }*/

        // in case of new app installation continue to increment the old recurring_notifications_sync_counter value
        if (recurringNotificationsSyncCounterFromServer > client.recurringNotificationsSyncCounter!) {
          _setRecurringNotificationsSyncCounter(recurringNotificationsSyncCounterFromServer);
        }

        // in case of new app installation continue to increment the old recurring_background_sync_counter value
        if (recurringBackgroundSyncCounterFromServer > client.recurringBackgroundSyncCounter!) {
          _setRecurringBackgroundSyncCounter(recurringBackgroundSyncCounterFromServer);
        }

        if (timezoneFromServer != null && timezoneFromServer != lastSavedTimeZone) {
          NotificationsService.cancelScheduledNotifications(_preferencesRepository);
          NotificationsService.scheduleNotificationsService(_preferencesRepository);
        }
        _setLastSavedTimeZone(timezoneFromServer);
      }

      return;
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }

  Future<void> _syncEntity(Entity entity) async {
    try {
      print("Syncing $entity...");

      SyncService syncService = _syncServices[entity]!;

      DateTime? lastSync = await getLastSyncFromPreferences[entity]!();

      DateTime? lastSyncUpdated = await syncService.start(lastSync);

      await _setLastSyncPreferences[entity]!(lastSyncUpdated);
    } catch (e, s) {
      print(e);

      _sentryService.captureException(e, stackTrace: s);
    }
    return;
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
