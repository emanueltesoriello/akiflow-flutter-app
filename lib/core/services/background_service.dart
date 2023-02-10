import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager/src/options.dart' as constraints;
import 'package:mobile/core/preferences.dart';

const scheduleNotificationsTaskKey = "com.akiflow.mobile.scheduleNotifications";
const periodicTaskskKey = "com.akiflow.mobile.periodicTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return backgroundProcesses(task);
  });
}

Future<bool> backgroundProcesses(String task) async {
  try {
    // listen on this port in order to catch trigger from the background services.
    // Useful for UI updates based on background sync
    final sendPort = IsolateNameServer.lookupPortByName("backgroundSync");
    if (sendPort != null) {
      // N.B. The port might be null if the main isolate is not running.
      sendPort.send(['backgroundSync']); //change this in order to send datas to all the listeners.
    }

    // *********************************************
    // ***** init services *************************
    // *********************************************
    SharedPreferences preferences = await SharedPreferences.getInstance();
    DatabaseService databaseService = DatabaseService();
    await databaseService.open(skipDirectoryCreation: true);
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

    // *********************************************
    // ***** background notifications scheduling ***
    // *********************************************
    if (task == scheduleNotificationsTaskKey) {
      await NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());

      // N.B. to be remove: show a local notification to confirm the background Sync
      if (kDebugMode) NotificationsCubit.showNotifications("Yeaaah!", "Updated the scheduling of notifications!");
      // *********************************************

    } else {
      final SyncControllerService syncControllerService = locator<SyncControllerService>();
      await syncControllerService.sync();

      await NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());

      // Show a local notification to confirm the background Sync
      if (kDebugMode) NotificationsCubit.showNotifications("Periodic task!", "Synched successfully");
      NotificationsCubit.showNotifications("From background!", "Synched successfully");
      // ***********************************
    }
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
      //initialDelay: Duration(seconds: 20),
      constraints: constraints.Constraints(
        // connected or metered mark the task as requiring internet
        networkType: NetworkType.connected,
      ),
      frequency: frequency,
    );
  }
}