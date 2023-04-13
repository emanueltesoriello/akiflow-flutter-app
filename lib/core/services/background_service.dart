import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager/src/options.dart' as constraints;
import 'package:mobile/core/preferences.dart';

const scheduleNotificationsTaskKey = "com.akiflow.mobile.scheduleNotifications";
const periodicTaskskKey = "com.akiflow.mobile.periodicTask";
const backgroundSyncFromNotification = "com.akiflow.mobile.backgroundSyncFromNotification";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await initProcesses();

    await backgroundProcesses(task);
    // listen on this port in order to catch trigger from the background services.
    // Useful for UI updates based on background sync
    final sendPort = IsolateNameServer.lookupPortByName("backgroundSync");

    if (sendPort != null) {
      // N.B. The port might be null if the main isolate is not running.
      sendPort.send(['backgroundSync']); //change this in order to send datas to all the listeners.
    }

    return Future.value(true);
  });
}

Future initProcesses() async {
  // *********************************************
  // ***** init services *************************
  // *********************************************
  SharedPreferences preferences = await SharedPreferences.getInstance();
  DatabaseService databaseService = DatabaseService();
  if (databaseService.database == null || !databaseService.database!.isOpen) {
    await databaseService.open(skipDirectoryCreation: true);
    print('new database opened - backgroundProcesses');
  } else {
    print('database already opened - backgroundProcesses');
  }
  await Config.initialize(
    configFile: 'assets/config/prod.json',
    production: true,
  );
  try {
    setupLocator(preferences: preferences, databaseService: databaseService, initFirebaseApp: false);
  } on ArgumentError catch (e, _) {
    if (e.message.toString().contains('type HttpClient is already registered')) {
      print('Locator already initialized!');
    }
  } catch (e) {
    print(e);
  }
  // *********************************************
  // *********************************************
}

Future<bool> backgroundProcesses(String task, {bool fromBackground = true}) async {
  try {
    // *********************************************
    // ***** background notifications scheduling ***
    // *********************************************
    if (fromBackground) {
      await initProcesses();
    }

    final SyncControllerService syncControllerService = locator<SyncControllerService>();
    if ((locator<PreferencesRepository>().lastTasksSyncAt != null &&
            DateTime.now().difference(locator<PreferencesRepository>().lastTasksSyncAt!).inMinutes > 15) ||
        task == backgroundSyncFromNotification) {
      await syncControllerService.sync();
    }

    // Show a local notification to confirm the background Sync
    if (kDebugMode) {
      NotificationsService.showNotifications("From background!", "Synched successfully");
    }

    // listen on this port in order to catch trigger from the background services.
    // Useful for UI updates based on background sync
    final sendPort = IsolateNameServer.lookupPortByName("backgroundSync");

    if (sendPort != null) {
      // N.B. The port might be null if the main isolate is not running.
      sendPort.send(['backgroundSync']); //change this in order to send datas to all the listeners.
    }

    if (task == backgroundSyncFromNotification) {
      int counter = (locator<PreferencesRepository>().recurringNotificationsSyncCounter) + 1;
      await locator<PreferencesRepository>().setRecurringNotificationsSyncCounter(counter);
    } else {
      int counter = (locator<PreferencesRepository>().recurringBackgroundSyncCounter) + 1;
      await locator<PreferencesRepository>().setRecurringBackgroundSyncCounter(counter);
    }
    // ***********************************

  } catch (err) {
    if (kDebugMode) log(err.toString());
    throw Exception(err);
  }
  return Future.value(true);
}

class BackgroundService {
  const BackgroundService._();

  static initBackgroundService() async {
    await Workmanager().initialize(callbackDispatcher,
        isInDebugMode:
            kDebugMode // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
  }

  static registerPeriodicTask(Duration? frequency) {
    Workmanager().registerPeriodicTask(
      periodicTaskskKey,
      periodicTaskskKey,
      initialDelay: const Duration(minutes: 1),
      constraints: constraints.Constraints(
        // connected or metered mark the task as requiring internet
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: frequency,
    );
  }
}
