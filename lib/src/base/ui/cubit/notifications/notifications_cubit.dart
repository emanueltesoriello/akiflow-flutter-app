import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/navigation_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:models/task/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import './../../../../../extensions/firebase_messaging.dart';
import 'package:mobile/core/preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/extensions/task_extension.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsCubitState> {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "channel id",
    "channel name",
    description: "channel description",
    importance: Importance.defaultImportance,
  );
  static const dailyReminderTaskId = 1000001;

  NotificationsCubit({bool initFirebaseApp = true}) : super(const NotificationsCubitState()) {
    setupLocalNotificationsPlugin();
    if (initFirebaseApp) {
      initFirebaseMessaging();
    }
  }

  // ************ INIT FUNCTIONS ************
  // ****************************************
  initFirebaseMessaging() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    if (Platform.isAndroid) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await firebaseMessaging.requestPermission();

      firebaseMessaging.registerOnMessage(_localNotificationsPlugin, channel);
    }
    if (Platform.isIOS) {
      firebaseMessaging.requestPermission();
    }
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
    // await handlerForNotificationsClickForTerminatedApp();
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
              android: AndroidNotificationDetails("channel id", "channel name",
                  channelDescription: "channel description", priority: Priority.max, importance: Importance.high),
            ),
        payload: payload);
  }

  static cancelScheduledNotifications() async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    List<ActiveNotification> activeNotifications = [];
    try {
      activeNotifications.addAll(await localNotificationsPlugin.getActiveNotifications());
    } catch (e) {
      print(e);
    }
    await localNotificationsPlugin.cancelAll();

    setDailyReminder();

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
            android: AndroidNotificationDetails("fcm_fallback_notification_channel", "channel name",
                playSound: false,
                channelDescription: "channel description",
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
      await NotificationsCubit.cancelScheduledNotifications();

      TasksRepository tasksRepository = locator<TasksRepository>();
      List<Task> todayTasks = await (tasksRepository.getTasksForScheduledNotifications());
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));

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

          NotificationsCubit.scheduleNotifications(task.title ?? '', "Start at $startTime",
              notificationId: notificationsId,
              scheduledDate: tz.TZDateTime.parse(tz.local, task.datetime!)
                  .subtract(Duration(minutes: minutesBefore.minutesBeforeToStart)),
              payload: jsonEncode(task.toMap()),
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  "channel_d",
                  "channel_name",
                  channelDescription: "default_channelDescription",
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
    localNotificationsPlugin.zonedSchedule(
        notificationId, title, description, scheduledDate, notificationDetails ?? const NotificationDetails(),
        androidAllowWhileIdle: true,
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  static Future<void> setDailyReminder() async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel description', importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    // *********************************************
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
    } catch (e) {
      print(e);
    }
    // *********************************************
    // *********************************************

    final service = locator<PreferencesRepository>();
    bool dailyOverviewNotificationTimeEnabled = service.dailyOverviewNotificationTimeEnabled;

    if (dailyOverviewNotificationTimeEnabled) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));

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