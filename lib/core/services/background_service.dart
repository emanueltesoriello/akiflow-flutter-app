import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:models/task/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager/src/options.dart' as constraints;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/core/preferences.dart';

const scheduleNotificationsTaskKey = "com.akiflow.mobile.scheduleNotifications";
const periodicTaskskKey = "com.akiflow.mobile.periodicTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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
      setupLocator(preferences: preferences, databaseService: databaseService, initFirebaseApp: false);
      // *********************************************
      // *********************************************

      // *********************************************
      // ***** background notifications scheduling ***
      // *********************************************
      if (task == scheduleNotificationsTaskKey) {
        await scheduleNotifications(locator<PreferencesRepository>());

        // N.B. to be remove: show a local notification to confirm the background Sync
        NotificationsCubit.showNotifications("Yeaaah!", "Updated the scheduling of notifications!");
        // *********************************************

      } else {
        final SyncControllerService syncControllerService = locator<SyncControllerService>();
        await syncControllerService.sync();

        await scheduleNotifications(locator<PreferencesRepository>());
        // Show a local notification to confirm the background Sync
        NotificationsCubit.showNotifications("Periodic task!", "Synched successfully");

        // ***********************************
        // Test for scheduled notifications
        // ***********************************
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation("Europe/Rome"));
        /*NotificationsCubit.scheduleNotifications("Scheduled task test!", "Scheduled task runned successfully",
            notificationId: 0,
            scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                "channel.id",
                "channel.name",
                channelDescription: "default.channelDescription",
                // other properties...
              ),
            ));*/
        // ***********************************
      }
    } catch (err) {
      if (kDebugMode) log(err.toString());
      throw Exception(err);
    }
    return Future.value(true);
  });
}

scheduleNotifications(PreferencesRepository preferencesRepository) async {
  if (preferencesRepository.nextTaskNotificationSettingEnabled) {
    await NotificationsCubit.cancelScheduledNotifications();

    TasksRepository tasksRepository = locator<TasksRepository>();
    List<Task> todayTasks = await (tasksRepository.getTasksForScheduledNotifications());

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Europe/Rome"));

    for (Task task in todayTasks) {
      int notificationsId = 0;
      try {
        // get the last 8 hex char from the ID and convert them into an int
        notificationsId = (int.parse(task.id!.substring(task.id!.length - 8, task.id!.length), radix: 16) / 2).round();
      } catch (e) {
        notificationsId = task.id.hashCode;
      }
      NextTaskNotificationsModel minutesBefore = preferencesRepository.nextTaskNotificationSetting;
      NotificationsCubit.scheduleNotifications(task.title ?? '',
          "Will start in ${minutesBefore.minutesBeforeToStart.toString()} ${minutesBefore.minutesBeforeToStart == 1 ? "minute" : "minutes"}!",
          notificationId: notificationsId,
          scheduledDate: tz.TZDateTime.parse(tz.local, task.datetime!)
              .subtract(Duration(minutes: minutesBefore.minutesBeforeToStart)),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              "channel_d",
              "channel_name",
              channelDescription: "default_channelDescription",
            ),
          ));
    }
  }
}

class BackgroundService {
  const BackgroundService._();

  static initBackgroundService() async {
    await Workmanager().initialize(callbackDispatcher,
        isInDebugMode:
            //TODO: add a kfebugMode check
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
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
        // require external power
        // requiresCharging: true,
      ),
      frequency: frequency,
    );
  }
}
