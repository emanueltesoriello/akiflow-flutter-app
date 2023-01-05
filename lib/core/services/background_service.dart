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

callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // listen on this port in order to catch trigger from the background services.
      // Useful for UI updates based on background sync
      final sendPort = IsolateNameServer.lookupPortByName("backgroundSync");
      if (sendPort != null) {
        // N.B. The port might be null if the main isolate is not running.
        sendPort.send(['backgroundSync']); //change this in order to send datas to all the listeners.
      }

      // init local services
      SharedPreferences preferences = await SharedPreferences.getInstance();
      DatabaseService databaseService = DatabaseService();
      await databaseService.open(skipDirectoryCreation: true);
      await Config.initialize(
        configFile: 'assets/config/prod.json',
        production: true,
      );

      setupLocator(preferences: preferences, databaseService: databaseService);
      final SyncControllerService syncControllerService = locator<SyncControllerService>();
      await syncControllerService.sync();

      int? totalExecutions;

      totalExecutions = preferences.getInt("totalExecutions");
      preferences.setInt("totalExecutions", totalExecutions == null ? 1 : totalExecutions + 1);

      // Show a local notification to confirm the background Sync
      NotificationsCubit.showNotifications("Periodic task!", "Synched successfully");
    } catch (err) {
      if (kDebugMode) log(err.toString());
      throw Exception(err);
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static initBackgroundService() {
    Workmanager().initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode:
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
  }

  static registerPeriodicTask(Duration? frequency) {
    Workmanager().registerPeriodicTask(
      "task-identifier-preiodic-task",
      "periodicTask",
      //initialDelay: Duration(seconds: 20),
      constraints: constraints.Constraints(
        // connected or metered mark the task as requiring internet
        networkType: NetworkType.connected,
        // require external power
        // requiresCharging: true,
      ),
      frequency: frequency,
    );
  }
}
