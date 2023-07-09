import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/src/base/models/next_event_notifications_models.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:models/notifications/scheduled_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';

// Create an extension on FlutterLocalNotificationsPlugin to add custom methods
extension FlutterLocalNotificationsPluginExtensions on FlutterLocalNotificationsPlugin {
  static const scheduledNotificationsConst = "scheduled_notifications";
  static const shownNotificationsConst = "shown_notifications";

  // Define a method to retrieve scheduled notifications from SharedPreferences
  Future<List<ScheduledNotification>?> getScheduledNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? scheduledNotificationsList = prefs.getStringList(scheduledNotificationsConst);
      List<ScheduledNotification> scheduledNotifications = [];

      // Check if there are any scheduled notifications
      if (scheduledNotificationsList != null && scheduledNotificationsList.isNotEmpty) {
        // Convert each JSON string to a ScheduledNotification object and add it to the list
        for (var element in scheduledNotificationsList) {
          scheduledNotifications.add(ScheduledNotification.fromMap(json.decode(element)));
        }

        // Remove notifications with plannedDate in the past
        scheduledNotifications.removeWhere((notification) {
          DateTime plannedDate = DateTime.parse(notification.plannedDate);
          // TODO get minutes from minutesBeforeToStartNotification
          return plannedDate.isBefore(DateTime.now().subtract(const Duration(minutes: 10)).toUtc());
        });

        scheduledNotifications = scheduledNotifications.toSet().toList();

        List<String> stringNotifications = [];
        // Convert each ScheduledNotification object to a JSON string and add it to the list
        for (var element in scheduledNotifications) {
          stringNotifications.add(json.encode(element.toMap()));
        }
        prefs.setStringList(scheduledNotificationsConst, stringNotifications);

        return scheduledNotifications.toSet().toList();
      } else {
        // If there are no scheduled notifications, return null
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> minutesBeforeToStartNotification(NotificationType type) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      NextEventNotificationsModel nextEventNotificationsModel = NextEventNotificationsModel.fromMap(
        jsonDecode(prefs.getString("nextEventNotificationSettingValue") ?? '{}'),
      );
      NextTaskNotificationsModel nextTaskNotificationsModel = NextTaskNotificationsModel.fromMap(
        jsonDecode(prefs.getString("nextTaskNotificationSettingValue") ?? '{}'),
      );
      if (type == NotificationType.Event) {
        return nextEventNotificationsModel.minutesBeforeToStart;
      }
      if (type == NotificationType.Tasks) {
        return nextTaskNotificationsModel.minutesBeforeToStart;
      }
      return 10;
    } catch (e) {
      print(e);
      return 10;
    }
  }

  // Define a method to retrieve scheduled notifications, that are immediately shown and not scheduled anymore, from SharedPreferences
  Future<List<ScheduledNotification>?> getNotificationsScheduledButImmediatelyShown() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? shownNotificationsList = prefs.getStringList(shownNotificationsConst);
      List<ScheduledNotification> shownNotifications = [];

      // Check if there are any notifications
      if (shownNotificationsList != null && shownNotificationsList.isNotEmpty) {
        // Convert each JSON string to a ScheduledNotification object and add it to the list
        for (var element in shownNotificationsList) {
          shownNotifications.add(ScheduledNotification.fromMap(json.decode(element)));
        }

        // Remove notifications with plannedDate in the past
        shownNotifications.removeWhere((notification) {
          DateTime plannedDate = DateTime.parse(notification.plannedDate);

          // TODO get minutes from minutesBeforeToStartNotification
          return plannedDate.isBefore(DateTime.now().subtract(const Duration(minutes: 10)).toUtc());
        });

        shownNotifications = shownNotifications.toSet().toList();

        List<String> stringNotifications = [];
        // Convert each ScheduledNotification object to a JSON string and add it to the list
        for (var element in shownNotifications) {
          stringNotifications.add(json.encode(element.toMap()));
        }
        prefs.setStringList(shownNotificationsConst, stringNotifications);

        return shownNotifications.toSet().toList();
      } else {
        // If there are no scheduled notifications, return null
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Define a method to schedule a notification and save it to SharedPreferences
  Future<void> zonedScheduleExt(
      int id, String title, String body, TZDateTime scheduledDate, NotificationDetails notificationDetails,
      {required UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation,
      required bool androidAllowWhileIdle,
      String? payload,
      DateTimeComponents? matchDateTimeComponents,
      required NotificationType notificationType}) async {
    try {
      await saveScheduleExt(id, title, body, scheduledDate, payload: payload, notificationType: notificationType);
    } catch (e) {
      print(e);
    }
    // Schedule the notification using the FlutterLocalNotificationsPlugin
    return FlutterLocalNotificationsPlugin().zonedSchedule(id, title, body, scheduledDate, notificationDetails,
        uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation,
        androidAllowWhileIdle: androidAllowWhileIdle);
  }

  // Define a method to save a notification to SharedPreferences
  Future<void> saveScheduleExt(
    int id,
    String title,
    String body,
    TZDateTime scheduledDate, {
    String? payload,
    required NotificationType notificationType,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<ScheduledNotification>? alreadyScheduledNotifications = await getScheduledNotifications();

      // If there are already scheduled notifications, add the new notification to the list
      if (alreadyScheduledNotifications != null) {
        alreadyScheduledNotifications.add(ScheduledNotification(
            notificationBody: body,
            notificationTitle: title,
            notificationId: id,
            plannedDate: scheduledDate.toIso8601String(),
            type: notificationType,
            payload: payload ?? ''));
      } else {
        // If there are no scheduled notifications, create a new list with the new notification
        alreadyScheduledNotifications = [
          ScheduledNotification(
              notificationId: id,
              notificationBody: body,
              notificationTitle: title,
              plannedDate: scheduledDate.toIso8601String(),
              type: notificationType,
              payload: payload ?? '')
        ];
      }
      List<String> reScheduleNotifications = [];
      // Convert each ScheduledNotification object to a JSON string and add it to the list
      for (var element in alreadyScheduledNotifications) {
        reScheduleNotifications.add(json.encode(element.toMap()));
      }
      // Save the list of scheduled notifications to SharedPreferences
      prefs.setStringList(scheduledNotificationsConst, reScheduleNotifications);
    } catch (e) {
      print(e);
    }
  }

  // Define a method to cancel a notification and remove it from SharedPreferences
  Future<void> cancelExt(int id, {String? tag}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<ScheduledNotification>? scheduledNotifications = await getScheduledNotifications();
      List<String> stringListSccheduledNotifications = [];

      // If there are scheduled notifications, remove the notification with the given ID from the list
      if (scheduledNotifications != null) {
        scheduledNotifications.removeWhere((element) => element.notificationId == id);
        // Convert each ScheduledNotification object to a JSON string and add it to     // the list
        for (var element in scheduledNotifications) {
          stringListSccheduledNotifications.add(json.encode(element.toMap()));
        }
        // Save the updated list of scheduled notifications to SharedPreferences
        prefs.setStringList(scheduledNotificationsConst, stringListSccheduledNotifications);
      }
    } catch (e) {
      print("Error on cancelExt");
      print(e);
    }

// Cancel the notification using the FlutterLocalNotificationsPlugin
    return FlutterLocalNotificationsPlugin().cancel(id);
  }

  // Define a method to cancel all notifications and remove them from SharedPreferences
  Future<void> cancelAllExt() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Remove the list of scheduled notifications from SharedPreferences
      prefs.remove(scheduledNotificationsConst);
    } catch (e) {
      print("Error on cancelAllExt");
      print(e);
    }
    // Cancel all notifications using the FlutterLocalNotificationsPlugin
    return FlutterLocalNotificationsPlugin().cancelAll();
  }

  bool containsNotificationWithId(List<ScheduledNotification> notifications, int id) {
    List<ScheduledNotification> filteredList =
        notifications.where((notification) => notification.notificationId == id).toList();
    return filteredList.isNotEmpty;
  }

  showExt(int id, String title, String body, NotificationDetails? notificationDetails,
      {String? payload, required TZDateTime scheduledDate, required NotificationType notificationType}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<ScheduledNotification>? alreadyShownNotifications = await getNotificationsScheduledButImmediatelyShown();

      // If there are already shown notifications, add the new notification to the list
      if (alreadyShownNotifications != null) {
        if (containsNotificationWithId(alreadyShownNotifications, id)) {
          return;
        }
        alreadyShownNotifications.add(ScheduledNotification(
            notificationBody: body,
            notificationTitle: title,
            notificationId: id,
            plannedDate: scheduledDate.toIso8601String(),
            type: notificationType,
            payload: payload ?? ''));
      } else {
        // If there are no shown notifications, create a new list with the new notification
        alreadyShownNotifications = [
          ScheduledNotification(
              notificationBody: body,
              notificationTitle: title,
              notificationId: id,
              plannedDate: scheduledDate.toIso8601String(),
              type: notificationType,
              payload: payload ?? '')
        ];
      }
      List<String> reScheduleNotifications = [];
      // Convert each ScheduledNotification object to a JSON string and add it to the list
      for (var element in alreadyShownNotifications) {
        reScheduleNotifications.add(json.encode(element.toMap()));
      }
      // Save the list of scheduled notifications to SharedPreferences
      prefs.setStringList(shownNotificationsConst, reScheduleNotifications);
    } catch (e) {
      print(e);
    }
    // Show the notification using the FlutterLocalNotificationsPlugin
    return show(id, title, body, notificationDetails, payload: payload);
  }
}
