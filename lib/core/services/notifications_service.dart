import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/navigation_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/models/next_event_notifications_models.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/events/ui/widgets/event_modal.dart';
import 'package:mobile/src/home/ui/pages/home_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/event/event.dart';
import 'package:models/notifications/scheduled_notification.dart';
import 'package:models/task/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import './../../../../../extensions/firebase_messaging.dart';
import 'package:mobile/core/preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './../../../../../extensions/local_notifications_extensions.dart';

class NotificationsService {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "channel id",
    "Default remote channel",
    description: "Remote notifications from server and desktop app",
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

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await firebaseMessaging.requestPermission();

    firebaseMessaging.registerOnMessage(_localNotificationsPlugin, channel);

    print("FCM Token: ${(await FirebaseMessaging.instance.getToken()).toString()}");
    // *********************************
    // **********************************/
  }

  Future<void> setupLocalNotificationsPlugin() async {
    const androidSetting = AndroidInitializationSettings('@drawable/ic_notifications');
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

  // read all the previously scheduled events, tasks, and other local notifications
  // aggregate them
  // schedule the next 64 notifications --> according to iOS limits
  static Future scheduleEventsTasksAndOthers() async {
    List<ScheduledNotification>? scheduledNotifications =
        await FlutterLocalNotificationsPlugin().getScheduledNotifications();
    if (scheduledNotifications != null && scheduledNotifications.isNotEmpty) {
      // order notifications by date and limit to 64 notifications max
      scheduledNotifications.sort((a, b) {
        try {
          return a.plannedDate.compareTo(b.plannedDate);
        } catch (e) {
          print("Error sorting scheduledNotifications: ${e.toString()}");
        }
        return 0;
      });

      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      if (scheduledNotifications.length > 64) {
        scheduledNotifications = scheduledNotifications.sublist(0, 63);
      }

      for (var notification in scheduledNotifications) {
        NotificationDetails notificationDetails = const NotificationDetails();
        if (notification.type == NotificationType.Tasks) {
          notificationDetails = const NotificationDetails(
            android: AndroidNotificationDetails("channel_tasks", "Task Notification",
                channelDescription: "Reminders that a task is about to start.",
                importance: Importance.max,
                priority: Priority.high),
          );
        } else if (notification.type == NotificationType.Event) {
          notificationDetails = const NotificationDetails(
            android: AndroidNotificationDetails("channel_events", "Event Notification",
                channelDescription: "Reminders that an event is about to start.",
                importance: Importance.max,
                priority: Priority.high),
          );
        } else {
          notificationDetails = const NotificationDetails(
            android: AndroidNotificationDetails("channel_reminders", "Daily Overview",
                channelDescription: "Reminder to view how your day looks like.",
                importance: Importance.max,
                priority: Priority.high),
          );
        }
        if (notification.notificationTitle.isNotEmpty) {
          FlutterLocalNotificationsPlugin().zonedScheduleExt(
              notification.notificationId,
              notification.notificationTitle,
              notification.notificationBody,
              tz.TZDateTime.parse(tz.local, notification.plannedDate),
              notificationDetails,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
              androidAllowWhileIdle: true,
              payload: notification.payload,
              matchDateTimeComponents: notification.type == NotificationType.Other ? DateTimeComponents.time : null,
              notificationType: notification.type);
        }
      }
    }
  }

  static Future scheduleEvents(
      PreferencesRepository preferencesRepository, Map<String, Event> eventsTobeScheduled) async {
    bool eventsNotificationEnabled = UserSettingsUtils.getSettingBySectionAndKey(
            preferencesRepository: preferencesRepository,
            sectionName: UserSettingsUtils.notificationsSection,
            key: UserSettingsUtils.eventsNotificationsEnabled) ??
        true;
    if (eventsNotificationEnabled) {
      var dbScheduledNotifications = await FlutterLocalNotificationsPlugin().getScheduledNotifications();

      List<ScheduledNotification> toBeRemoved = [];

      if (dbScheduledNotifications != null) {
        // put in toBeRemoved all the events that are in scheduledNotifications but not in eventsToBeScheduled (check only the scheduledNotifications that has type == Event)
        for (var dbScheduledNotification in dbScheduledNotifications) {
          // Assuming that the 'type' field is available in the notification's payload
          NotificationType notificationType = dbScheduledNotification.type;

          if (notificationType == NotificationType.Event) {
            if (!eventsTobeScheduled.containsKey(dbScheduledNotification.fullEventId)) {
              toBeRemoved.add(dbScheduledNotification);
            }
          }
        }
        if (toBeRemoved.isNotEmpty) {
          // remove notifications
          for (var eventToBeRemoved in toBeRemoved) {
            await cancelNotificationById(eventToBeRemoved.notificationId);
          }
        }
      }

      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      // Schedule all the events and update the already set ones
      eventsTobeScheduled.forEach((id, event) {
        try {
          String startTime = DateFormat('kk:mm').format(DateTime.parse(id.split(';')[1]).toLocal());
          String eventIdString = id.split(';')[0];
          int notificationsId = 0;
          String startTimeString = id.split(';')[1];
          try {
            // get the last 8 hex char from the ID and convert them into an int
            notificationsId = int.parse(eventIdString);
          } catch (e) {
            print(e);
            notificationsId = eventIdString.hashCode;
          }
          NextEventNotificationsModel minutesBefore = NextEventNotificationsModel.fromMap(jsonDecode(
              UserSettingsUtils.getSettingBySectionAndKey(
                      preferencesRepository: preferencesRepository,
                      sectionName: UserSettingsUtils.notificationsSection,
                      key: UserSettingsUtils.eventsNotificationsTime) ??
                  '{"minutesBeforeToStart":5,"title":"5 minutes before the event starts"}'));

          NotificationsService.scheduleNotifications(
              event.title ?? '',
              (event.startDate != null && event.endDate != null && startTime.contains("24:00"))
                  ? "Today"
                  : "Event start at $startTime",
              notificationId: notificationsId,
              fullEventId: id,
              scheduledDate: tz.TZDateTime.parse(
                tz.local,
                startTimeString,
              ).subtract(Duration(minutes: minutesBefore.minutesBeforeToStart)),
              payload: jsonEncode(event.toMap()),
              notificationType: NotificationType.Event,
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails("channel_d", "Event Notification",
                    channelDescription: "Reminders that an event is about to start.",
                    importance: Importance.max,
                    priority: Priority.high),
              ),
              minutesBeforeToStart: minutesBefore.minutesBeforeToStart);
        } catch (e) {
          print(e);
        }
      });
    }
  }

  /// This method schedule all the planned notifications for tasks
  /// It automatically schedule the new one and also update the existing ones and removes the deleted/done/trashed tasks
  static planTasksNotifications(PreferencesRepository preferencesRepository,
      {List<Task>? changedTasks, List<Task>? notExistingTasks, List<Task>? unchangedTasks}) async {
    bool tasksNotificationEnabled = UserSettingsUtils.getSettingBySectionAndKey(
            preferencesRepository: preferencesRepository,
            sectionName: UserSettingsUtils.notificationsSection,
            key: UserSettingsUtils.tasksNotificationsEnabled) ??
        true;
    if (tasksNotificationEnabled) {
      List<Task> toBeScheduled = [];
      List<Task> toBeRemoved = [];

      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      DateTime date = DateTime.now().toUtc();
      DateTime endTime = date.add(const Duration(days: 5));

      if (notExistingTasks != null && notExistingTasks.isNotEmpty) {
        toBeScheduled.addAll(notExistingTasks
            .where((task) =>
                task.deletedAt == null &&
                task.trashedAt == null &&
                task.datetime != null &&
                task.status == TaskStatusType.planned.id &&
                (DateTime.parse(task.datetime!).toUtc().isAfter(date.toUtc())) &&
                DateTime.parse(task.datetime!).toUtc().isBefore(endTime.toUtc()))
            .toList());
      }

      if (changedTasks != null && changedTasks.isNotEmpty) {
        toBeScheduled.addAll(changedTasks
            .where((task) =>
                task.datetime != null &&
                (task.deletedAt == null &&
                    task.trashedAt == null &&
                    task.status == TaskStatusType.planned.id &&
                    (DateTime.parse(task.datetime!).toUtc().isAfter(date.toUtc()) &&
                        DateTime.parse(task.datetime!).toUtc().isBefore(endTime.toUtc()))))
            .toList());
        toBeRemoved.addAll(changedTasks
            .where((task) =>
                task.datetime != null &&
                (task.done == true ||
                    ((task.deletedAt != null || task.trashedAt != null) || task.status != TaskStatusType.planned.id) &&
                        DateTime.parse(task.datetime!).toUtc().isAfter(date.toUtc())))
            .toList());
      }

      if (unchangedTasks != null && unchangedTasks.isNotEmpty) {
        toBeScheduled.addAll(unchangedTasks
            .where((task) =>
                task.datetime != null &&
                (task.deletedAt == null &&
                    task.trashedAt == null &&
                    task.status == TaskStatusType.planned.id &&
                    DateTime.parse(task.datetime!).toUtc().isAfter(date.toUtc()) &&
                    DateTime.parse(task.datetime!).toUtc().isBefore(endTime.toUtc())))
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
          NextTaskNotificationsModel minutesBefore = NextTaskNotificationsModel.fromMap(jsonDecode(
              UserSettingsUtils.getSettingBySectionAndKey(
                      preferencesRepository: preferencesRepository,
                      sectionName: UserSettingsUtils.notificationsSection,
                      key: UserSettingsUtils.tasksNotificationsTime) ??
                  '{"minutesBeforeToStart":5,"title":"5 minutes before the task starts"}'));

          try {
            String startTime = DateFormat('kk:mm').format(DateTime.parse(task.datetime!).toLocal());

            NotificationsService.scheduleNotifications(task.title ?? '', "Start at $startTime",
                notificationId: notificationsId,
                scheduledDate: tz.TZDateTime.parse(tz.local, task.datetime!)
                    .subtract(Duration(minutes: minutesBefore.minutesBeforeToStart)),
                payload: jsonEncode(task.toMap()),
                notificationType: NotificationType.Tasks,
                notificationDetails: const NotificationDetails(
                  android: AndroidNotificationDetails("channel_d", "Task Notification",
                      channelDescription: "Reminders that a task is about to start.",
                      importance: Importance.max,
                      priority: Priority.high),
                ),
                minutesBeforeToStart: minutesBefore.minutesBeforeToStart);
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

  static Future<void> handlerForNotificationsClickForTerminatedApp() async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    print('handlerForNotificationsClickForTerminatedApp');
    var details = await localNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      print(details.notificationResponse);
      print('runned handlerForNotificationsClickForTerminatedApp');
      handleNotificationClick(details.notificationResponse!);
    }
    return;
  }

  static handleNotificationClick(NotificationResponse payload) async {
    //payload.payload;
    if (payload.payload != '') {
      bool? isEvent;
      try {
        isEvent = jsonDecode(payload.payload!)['creator_id'] != null;
      } catch (e) {
        print(e);
      }
      if (isEvent != null && !isEvent) {
        print('Task notification clicked on handleNotificationClick');
        Task task = Task.fromMap(jsonDecode(payload.payload!));

        BuildContext? context = NavigationService.navigatorKey.currentContext;
        if (context != null) {
          context.read<MainCubit>().changeHomeView(HomeViewType.today);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false);

          await TaskExt.editTask(context, task);
        }
      } else {
        try {
          Event? event = Event.fromMap(jsonDecode(payload.payload!));
          print('Event notification clicked on handleNotificationClick');
          BuildContext? context = NavigationService.navigatorKey.currentContext;
          if (context != null) {
            context.read<MainCubit>().changeHomeView(HomeViewType.calendar);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false);

            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => EventModal(
                event: event,
                tappedDate: DateTime.now().toLocal(),
              ),
            );
          }
        } catch (e) {
          print(e);
        }
      }
    } else if (payload.id == dailyReminderTaskId) {
      BuildContext? context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        print('handleNotificationClick: daily reminder pressed');

        context.read<MainCubit>().changeHomeView(HomeViewType.today);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false);
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
    await localNotificationsPlugin.cancelAllExt();

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
                channelDescription: "Remote notifications from server and desktop app",
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
    bool tasksNotificationEnabled = UserSettingsUtils.getSettingBySectionAndKey(
            preferencesRepository: preferencesRepository,
            sectionName: UserSettingsUtils.notificationsSection,
            key: UserSettingsUtils.tasksNotificationsEnabled) ??
        true;
    if (tasksNotificationEnabled) {
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
        NextTaskNotificationsModel minutesBefore = NextTaskNotificationsModel.fromMap(jsonDecode(
            UserSettingsUtils.getSettingBySectionAndKey(
                    preferencesRepository: preferencesRepository,
                    sectionName: UserSettingsUtils.notificationsSection,
                    key: UserSettingsUtils.tasksNotificationsTime) ??
                '{"minutesBeforeToStart":5,"title":"5 minutes before the task starts"}'));
        try {
          String startTime = DateFormat('kk:mm').format(DateTime.parse(task.datetime!).toUtc().toLocal());

          NotificationsService.scheduleNotifications(task.title ?? '', "Start at $startTime",
              notificationId: notificationsId,
              scheduledDate: tz.TZDateTime.parse(tz.local, task.datetime!)
                  .subtract(Duration(minutes: minutesBefore.minutesBeforeToStart)),
              payload: jsonEncode(task.toMap()),
              notificationType: NotificationType.Tasks,
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails("channel_d", "Task Notification",
                    channelDescription: "Reminders that a task is about to start.",
                    importance: Importance.max,
                    priority: Priority.high),
              ),
              minutesBeforeToStart: minutesBefore.minutesBeforeToStart);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  static scheduleNotifications(String title, String description,
      {String? fullEventId,
      int notificationId = 0,
      NotificationDetails? notificationDetails,
      required TZDateTime scheduledDate,
      required String? payload,
      required NotificationType notificationType,
      required int minutesBeforeToStart}) async {
    if (scheduledDate.toUtc().difference(DateTime.now().toUtc()).inMinutes > 0) {
      await FlutterLocalNotificationsPlugin().saveScheduleExt(notificationId, title, description, scheduledDate,
          fullEventId: fullEventId,
          payload: payload,
          notificationType: notificationType,
          minutesBeforeToStart: minutesBeforeToStart);
    } else {
      print('show immediately this notification');
      FlutterLocalNotificationsPlugin().showExt(
          notificationId, title, description, notificationDetails ?? const NotificationDetails(),
          payload: payload,
          scheduledDate: scheduledDate,
          notificationType: notificationType,
          minutesBeforeToStart: minutesBeforeToStart);
    }
  }

  static Future<void> setDailyReminder(PreferencesRepository service) async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails('channel id', 'Daily Overview',
        channelDescription: 'Reminder to view how your day looks like.',
        importance: Importance.max,
        priority: Priority.high);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // *********************************************
    // *********************************************

    bool dailyOverviewNotificationTimeEnabled = UserSettingsUtils.getSettingBySectionAndKey(
            preferencesRepository: service,
            sectionName: UserSettingsUtils.notificationsSection,
            key: UserSettingsUtils.dailyOverviewNotificationsEnabled) ??
        true;

    if (dailyOverviewNotificationTimeEnabled) {
      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      TimeOfDay dailyOverviewNotificationTime;
      dynamic savedDailyOverviewTime = UserSettingsUtils.getSettingBySectionAndKey(
          preferencesRepository: service,
          sectionName: UserSettingsUtils.notificationsSection,
          key: UserSettingsUtils.dailyOverviewNotificationsTime);

      if (savedDailyOverviewTime != null) {
        TimeOfDay time = TimeOfDay(
            hour: int.parse(savedDailyOverviewTime.split(":")[0]),
            minute: int.parse(savedDailyOverviewTime.split(":")[1]));
        dailyOverviewNotificationTime = time;
      } else {
        dailyOverviewNotificationTime = const TimeOfDay(hour: 8, minute: 0);
      }

      final now = DateTime.now();

      DateTime dt = DateTime(
          now.year, now.month, now.day, dailyOverviewNotificationTime.hour, dailyOverviewNotificationTime.minute);
      await localNotificationsPlugin.saveScheduleExt(dailyReminderTaskId,
          "Start your day right by checking your schedule!", "", tz.TZDateTime.parse(tz.local, dt.toIso8601String()),
          notificationType: NotificationType.Other, minutesBeforeToStart: 5);
      await localNotificationsPlugin.zonedScheduleExt(
          dailyReminderTaskId,
          "Start your day right by checking your schedule!",
          "",
          tz.TZDateTime.parse(tz.local, dt.toIso8601String()),
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          notificationType: NotificationType.Other);
    }
  }

  static Future cancelNotificationById(int id) async => await FlutterLocalNotificationsPlugin().cancelExt(id);
}
