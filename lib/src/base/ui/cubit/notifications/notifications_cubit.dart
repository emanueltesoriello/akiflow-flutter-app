import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/services/navigation_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/task/task.dart';
import 'package:timezone/timezone.dart';
import './../../../../../extensions/firebase_messaging.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsCubitState> {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'default_channel', // id
    "defaultChannel", // title
    description: "descriptionDefaultChannel", // description
    importance: Importance.defaultImportance,
  );

  NotificationsCubit({bool initFirebaseApp = true}) : super(const NotificationsCubitState()) {
    setupLocalNotificationsPlugin();
    if (initFirebaseApp) {
      initFirebaseMessaging();
    }
  }

  // ************ INIT FUNCTIONS ************
  // ****************************************
  initFirebaseMessaging() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    if (Platform.isAndroid) {
      //  await _localNotificationsPlugin
      //     .initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
      //   await _localNotificationsPlugin
      //       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      //       ?.createNotificationChannel(channel);
      // _firebaseMessaging.app.
      final bool? result = await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _firebaseMessaging.requestPermission();

      _firebaseMessaging.registerOnMessage(_localNotificationsPlugin, channel);
    }
    if (Platform.isIOS) {
      _firebaseMessaging.requestPermission();
    }
    print("FCM Token: ${(await FirebaseMessaging.instance.getToken()).toString()}");
    // *********************************
    // **********************************/
  }

  Future<void> setupLocalNotificationsPlugin() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);
    await _localNotificationsPlugin
        .initialize(
      initSettings,
      onDidReceiveNotificationResponse: selectNotification,
      onDidReceiveBackgroundNotificationResponse: selectNotification,
    )
        .then((_) {
      print('setupPlugin: setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });
  }

  static selectNotification(NotificationResponse payload) async {
    //payload.payload;
    if (payload.payload != '') {
      Task task = Task.fromMap(jsonDecode(payload.payload!));
      // jsonDecode(payload.payload)
      print('notification clicked');
      BuildContext? context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        TaskExt.editTask(NavigationService.navigatorKey.currentContext!, task);
      }
    }
  }

  // ********************
  // ********************
  static showNotifications(String title, String description,
      {int notificationId = 1, NotificationDetails? notificationDetails}) {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localNotificationsPlugin.show(
        notificationId,
        title,
        description,
        notificationDetails ??
            const NotificationDetails(
              android: AndroidNotificationDetails(
                "channel.id",
                "channel.name",
                channelDescription: "default.channelDescription",
                // other properties...
              ),
            ));
  }

  static cancelScheduledNotifications() async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    List<ActiveNotification> activeNotifications = [];
    activeNotifications.addAll(await localNotificationsPlugin.getActiveNotifications());
    await localNotificationsPlugin.cancelAll();
    if (activeNotifications.isNotEmpty) {
      for (var notification in activeNotifications) {
        localNotificationsPlugin.show(
          notification.id,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "channel.id",
              "channel.name",
              channelDescription: "default.channelDescription",
              // other properties...
            ),
          ),
          payload: notification.payload,
        );
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

  static Future<void> scheduleDailyReminder(
    TZDateTime scheduledDate, {
    String? scheduledTitle,
    String? scheduledBody,
  }) async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description', importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotificationsPlugin.zonedSchedule(
      9999,
      scheduledTitle,
      scheduledBody,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
