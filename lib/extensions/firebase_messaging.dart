import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

onNotificationsReceived(RemoteMessage message, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    AndroidNotificationChannel channel) {
  print("onMessage: ${message.notification?.title ?? ''}");
  final notification = message.notification;
  // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
  if (notification != null /*&& Platform.isAndroid*/) {
    flutterLocalNotificationsPlugin.show(
        100,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // other properties...
          ),
        ));
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  try {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      "channel.id",
      "channel.name",
      description: "channel.description",
    );
    onNotificationsReceived(message, flutterLocalNotificationsPlugin, channel);
    return true;
  } catch (e) {
    print(e);
    rethrow;
  }
}

extension FirebaseMessagingExtension on FirebaseMessaging {
  void registerOnMessage(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, AndroidNotificationChannel channel) {
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => onNotificationsReceived(message, flutterLocalNotificationsPlugin, channel));
    FirebaseMessaging.onMessage
        .listen((message) => onNotificationsReceived(message, flutterLocalNotificationsPlugin, channel));
  }
}
