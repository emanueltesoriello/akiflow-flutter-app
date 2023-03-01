import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/navigation_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:models/task/task.dart';
import 'package:timezone/timezone.dart';
import './../../../../../extensions/firebase_messaging.dart';
import 'package:mobile/core/preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/core/repository/tasks_repository.dart';

class NotificationsService {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "channel id",
    "Default remote channel",
    description: "Default notification channel for remote notifications",
    importance: Importance.defaultImportance,
  );
  static const dailyReminderTaskId = 1000001;

  NotificationsService({bool initFirebaseApp = true}) {
    setupLocalNotificationsPlugin();
    if (initFirebaseApp) {
      initFirebaseMessaging();
    }
  }

  // ************ INIT FUNCTIONS ************
  // ****************************************

  initFirebaseMessaging() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'default_channel_id',
      'Default notification',
      channelDescription: 'The default notification channel.',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    //await _localNotificationsPlugin
    //    .show(0, 'Notification Permission Granted', 'You can now receive notifications!', platformChannelSpecifics)
    //   .then((value) => print('Notification Permission Granted'));

    await firebaseMessaging.requestPermission();

    firebaseMessaging.registerOnMessage(_localNotificationsPlugin, channel);

    print("FCM Token: ${(await FirebaseMessaging.instance.getToken()).toString()}");
    // *********************************
    // **********************************/
  }

  static Future<void> handlerForNotificationsClickForTerminatedApp() async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var details = await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      print(details.notificationResponse);
      print('runned handlerForNotificationsClickForTerminatedApp');
      handleNotificationClick(details.notificationResponse!);
    }
  }

  Future<void> setupLocalNotificationsPlugin() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);

    await _localNotificationsPlugin
        .initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleNotificationClick,
      onDidReceiveBackgroundNotificationResponse: handleNotificationClick,
    )
        .then((_) {
      print('setupPlugin: setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });
  }

  /// This method schedule all the planned notifications for tasks
  /// It automatically schedule the new one and also update the existing ones and removes the deleted/done/trashed tasks
  static planTasksNotifications(PreferencesRepository preferencesRepository,
      {List<Task>? changedTasks, List<Task>? notExistingTasks}) async {
    if (preferencesRepository.nextTaskNotificationSettingEnabled) {
      List<Task> toBeScheduled = [];
      List<Task> toBeRemoved = [];

      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      DateTime date = DateTime.now().toUtc();
      DateTime endTime = date.add(const Duration(days: 1));

      if (notExistingTasks != null && notExistingTasks.isNotEmpty) {
        toBeScheduled.addAll(notExistingTasks
            .where((task) =>
                task.deletedAt == null &&
                task.trashedAt == null &&
                task.datetime != null &&
                task.status == TaskStatusType.planned.id &&
                (DateTime.parse(task.datetime!).isAfter(DateTime.parse(date.toUtc().toIso8601String())) &&
                    DateTime.parse(task.datetime!).isBefore(DateTime.parse(endTime.toUtc().toIso8601String()))))
            .toList());
      }

      if (changedTasks != null && changedTasks.isNotEmpty) {
        toBeScheduled.addAll(changedTasks
            .where((task) =>
                task.deletedAt == null &&
                task.trashedAt == null &&
                task.datetime != null &&
                task.status == TaskStatusType.planned.id &&
                (DateTime.parse(task.datetime!).isAfter(DateTime.parse(date.toUtc().toIso8601String())) &&
                    DateTime.parse(task.datetime!).isBefore(DateTime.parse(endTime.toUtc().toIso8601String()))))
            .toList());
      }

      if (changedTasks != null && changedTasks.isNotEmpty) {
        toBeRemoved.addAll(changedTasks
            .where((task) => (task.done == true ||
                ((task.deletedAt != null || task.trashedAt != null) && task.datetime != null ||
                        task.status != TaskStatusType.planned.id) &&
                    DateTime.parse(task.datetime!).isAfter(DateTime.parse(date.toUtc().toIso8601String()))))
            .toList());
      }

      if (toBeScheduled.isNotEmpty) {
        for (var task in toBeScheduled) {
          int notificationsId = 0;

          try {
            // get the last 8 hex char from the ID and convert them into an int
            notificationsId =
                (int.parse(task.id!.substring(task.id!.length - 8, task.id!.length), radix: 16) / 2).round();
          } catch (e) {
            notificationsId = task.id.hashCode;
          }
          NextTaskNotificationsModel minutesBefore = preferencesRepository.nextTaskNotificationSetting;

          try {
            String startTime = DateFormat('kk:mm').format(DateTime.parse(task.datetime!).toUtc().toLocal());

            NotificationsService.scheduleNotifications(task.title ?? '', "Start at $startTime",
                notificationId: notificationsId,
                scheduledDate: tz.TZDateTime.parse(tz.local, task.datetime!)
                    .subtract(Duration(minutes: minutesBefore.minutesBeforeToStart)),
                payload: jsonEncode(task.toMap()),
                notificationDetails: const NotificationDetails(
                  android: AndroidNotificationDetails(
                    "channel_d",
                    "Tasks notification",
                    channelDescription: "The notifications received as a reminder for a task.",
                  ),
                ));
          } catch (e) {
            print(e);
          }
        }
      }
      if (toBeRemoved.isNotEmpty) {
        for (var task in toBeRemoved) {
          int notificationsId = 0;

          try {
            // get the last 8 hex char from the ID and convert them into an int
            notificationsId =
                (int.parse(task.id!.substring(task.id!.length - 8, task.id!.length), radix: 16) / 2).round();
          } catch (e) {
            notificationsId = task.id.hashCode;
          }
          cancelNotificationById(notificationsId);
        }
      }
    }
  }

  static handleNotificationClick(NotificationResponse payload) async {
    //payload.payload;
    if (payload.payload != '') {
      Task task = Task.fromMap(jsonDecode(payload.payload!));
      print('notification clicked');
      BuildContext? context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        print('NavigationService.navigatorKey.currentContext');
        await TaskExt.editTask(NavigationService.navigatorKey.currentContext!, task);
      } else {
        print('NO NavigationService.navigatorKey.currentContext');
      }
    }
  }

  // ********************
  // ********************
  static showNotifications(String title, String description,
      {int notificationId = 1, NotificationDetails? notificationDetails, String? payload}) {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localNotificationsPlugin.show(
        notificationId,
        title,
        description,
        notificationDetails ??
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                  presentAlert: true, presentSound: true, interruptionLevel: InterruptionLevel.active),
              android: AndroidNotificationDetails("channel id", "Default notification",
                  channelDescription: "The default notification channel.",
                  priority: Priority.max,
                  importance: Importance.high),
            ),
        payload: payload);
  }

  static cancelScheduledNotifications(PreferencesRepository service) async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    List<ActiveNotification> activeNotifications = [];
    try {
      activeNotifications.addAll(await localNotificationsPlugin.getActiveNotifications());
    } catch (e) {
      print(e);
    }
    await localNotificationsPlugin.cancelAll();

    setDailyReminder(service);

    if (activeNotifications.isNotEmpty) {
      for (var notification in activeNotifications) {
        localNotificationsPlugin.show(
          notification.id,
          notification.title,
          notification.body,
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
                presentAlert: false,
                presentBadge: false,
                presentSound: false,
                interruptionLevel: InterruptionLevel.passive),
            android: AndroidNotificationDetails("fcm_fallback_notification_channel", "Default remote channel",
                playSound: false,
                channelDescription: "Default notification channel for remote notifications",
                enableVibration: false,
                onlyAlertOnce: true,
                usesChronometer: false),
          ),
          payload: notification.payload,
        );
      }
    }
  }

  static scheduleNotificationsService(PreferencesRepository preferencesRepository) async {
    if (preferencesRepository.nextTaskNotificationSettingEnabled) {
      await NotificationsService.cancelScheduledNotifications(preferencesRepository);

      TasksRepository tasksRepository = locator<TasksRepository>();
      List<Task> todayTasks = await (tasksRepository.getTasksForScheduledNotifications());

      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      for (Task task in todayTasks) {
        int notificationsId = 0;
        try {
          // get the last 8 hex char from the ID and convert them into an int
          notificationsId =
              (int.parse(task.id!.substring(task.id!.length - 8, task.id!.length), radix: 16) / 2).round();
        } catch (e) {
          notificationsId = task.id.hashCode;
        }
        NextTaskNotificationsModel minutesBefore = preferencesRepository.nextTaskNotificationSetting;
        try {
          String startTime = DateFormat('kk:mm').format(DateTime.parse(task.datetime!).toUtc().toLocal());

          NotificationsService.scheduleNotifications(task.title ?? '', "Start at $startTime",
              notificationId: notificationsId,
              scheduledDate: tz.TZDateTime.parse(tz.local, task.datetime!)
                  .subtract(Duration(minutes: minutesBefore.minutesBeforeToStart)),
              payload: jsonEncode(task.toMap()),
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  "channel_d",
                  "Tasks notification",
                  channelDescription: "The notifications received as a reminder for a task.",
                ),
              ));
        } catch (e) {
          print(e);
        }
      }
    }
  }

  static scheduleNotifications(String title, String description,
      {int notificationId = 0,
      NotificationDetails? notificationDetails,
      required TZDateTime scheduledDate,
      required String? payload}) {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (scheduledDate.toUtc().difference(DateTime.now().toUtc()).inMinutes > 0) {
      localNotificationsPlugin.zonedSchedule(
          notificationId, title, description, scheduledDate, notificationDetails ?? const NotificationDetails(),
          androidAllowWhileIdle: true,
          payload: payload,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
    } else {
      print('show immediately this notification');
      localNotificationsPlugin.show(
        notificationId,
        title,
        description,
        notificationDetails ?? const NotificationDetails(),
        payload: payload,
      );
    }
  }

  static Future<void> setDailyReminder(PreferencesRepository service) async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails('channel id', 'Daily reminder',
        channelDescription: 'The channel for the daily overview  notification.',
        importance: Importance.max,
        priority: Priority.high);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // *********************************************
    // *********************************************

    bool dailyOverviewNotificationTimeEnabled = service.dailyOverviewNotificationTimeEnabled;

    if (dailyOverviewNotificationTimeEnabled) {
      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      TimeOfDay dailyOverviewNotificationTime = service.dailyOverviewNotificationTime;
      final now = DateTime.now();

      DateTime dt = DateTime(
          now.year, now.month, now.day, dailyOverviewNotificationTime.hour, dailyOverviewNotificationTime.minute);

      await localNotificationsPlugin.zonedSchedule(
        dailyReminderTaskId,
        "Start your day right by checking your schedule!",
        null,
        tz.TZDateTime.parse(tz.local, dt.toIso8601String()),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static cancelNotificationById(int id) => FlutterLocalNotificationsPlugin().cancel(id);
}
