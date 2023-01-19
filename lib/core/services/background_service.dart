import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:models/task/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager/src/options.dart' as constraints;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

@pragma('vm:entry-point')
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

      setupLocator(preferences: preferences, databaseService: databaseService, initFirebaseApp: false);

      if (task == 'scheduleNotifications') {
        await scheduleNotifications();
        int? totalExecutions;

        totalExecutions = preferences.getInt("totalExecutions");
        preferences.setInt("totalExecutions", totalExecutions == null ? 1 : totalExecutions + 1);

        // Show a local notification to confirm the background Sync
        NotificationsCubit.showNotifications("Yeaaah!", "Updated the scheduling of notifications!");
        // ***********************************

      } else {
        final SyncControllerService syncControllerService = locator<SyncControllerService>();
        await syncControllerService.sync();

        await scheduleNotifications();
        int? totalExecutions;

        totalExecutions = preferences.getInt("totalExecutions");
        preferences.setInt("totalExecutions", totalExecutions == null ? 1 : totalExecutions + 1);

        // Show a local notification to confirm the background Sync
        NotificationsCubit.showNotifications("Periodic task!", "Synched successfully");

        // ***********************************
        // Test for scheduled notifications
        // ***********************************
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation("Europe/Rome"));
        NotificationsCubit.scheduleNotifications("Scheduled task test!", "Scheduled task runned successfully",
            notificationId: 0,
            scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                "channel.id",
                "channel.name",
                channelDescription: "default.channelDescription",
                // other properties...
              ),
            ));
        // ***********************************
      }
    } catch (err) {
      if (kDebugMode) log(err.toString());
      throw Exception(err);
    }

    return Future.value(true);
  });
}

scheduleNotifications() async {
  await NotificationsCubit.cancelScheduledNotifications();
  TasksRepository tasksRepository = locator<TasksRepository>();
  List<Task> todayTasks = await (tasksRepository.getTasksForScheduledNotifications());

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Europe/Rome"));

  for (int i = 0; i < todayTasks.length; i++) {
    NotificationsCubit.scheduleNotifications(todayTasks[i].title ?? '', "Will start in 5 minutes!",
        notificationId: todayTasks[i].id.hashCode,
        scheduledDate: tz.TZDateTime.parse(tz.local, todayTasks[i].datetime!).subtract(const Duration(minutes: 5)),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            "channel.id",
            "channel.name",
            channelDescription: "default.channelDescription",
            // other properties...
          ),
        ));
  }
}

class BackgroundService {
  const BackgroundService._();

  static initBackgroundService() {
    Workmanager().initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode:
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
  }

  static registerPeriodicTask(Duration? frequency) {
    Workmanager().registerPeriodicTask(
      "periodicTask",
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
