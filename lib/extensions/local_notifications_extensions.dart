import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:models/notifications/scheduled_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';

// Create an extension on FlutterLocalNotificationsPlugin to add custom methods
extension FlutterLocalNotificationsPluginExtensions on FlutterLocalNotificationsPlugin {
  static const scheduledNotificationsConst = "scheduled_notifications";

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
        // Remove duplicates and return the list

        // TODO: add check to remove remove already shown notifications based on the date
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

  // Define a method to schedule a notification and save it to SharedPreferences
  Future<void> zonedScheduleExt(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation,
    required bool androidAllowWhileIdle,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
    required NotificationType notificationType,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<ScheduledNotification>? alreadyScheduledNotifications = await getScheduledNotifications();

      // If there are already scheduled notifications, add the new notification to the list
      if (alreadyScheduledNotifications != null) {
        alreadyScheduledNotifications.add(ScheduledNotification(
            notificationId: id, plannedDate: scheduledDate.toIso8601String(), type: notificationType));
      } else {
        // If there are no scheduled notifications, create a new list with the new notification
        alreadyScheduledNotifications = [
          ScheduledNotification(
              notificationId: id, plannedDate: scheduledDate.toIso8601String(), type: notificationType)
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
    // Schedule the notification using the FlutterLocalNotificationsPlugin
    return FlutterLocalNotificationsPlugin().zonedSchedule(id, title, body, scheduledDate, notificationDetails,
        uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation,
        androidAllowWhileIdle: androidAllowWhileIdle);
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
}
