import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

extension FirebaseMessagingExtension on FirebaseMessaging {
  void registerOnMessage(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, AndroidNotificationChannel channel) {
    (Map<String, dynamic> message) async {
      print("onMessage: $message");
      final notification = message["notification"];
      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && Platform.isAndroid) {
        flutterLocalNotificationsPlugin.show(
            100,
            notification['title'],
            notification['body'],
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // other properties...
              ),
            ));
      }
    };
  }
}
