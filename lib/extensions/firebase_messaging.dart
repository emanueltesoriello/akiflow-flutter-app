import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/services/background_service.dart';

onNotificationsReceived(RemoteMessage message, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    AndroidNotificationChannel channel,
    {bool fromBackground = false}) {
  print("onMessage: ${message.notification?.title ?? ''}");
  //final notification = message.notification;
  String notificationType = message.data["notification_type"] ?? '';
  // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
  if (notificationType == 'trigger_sync:tasks' || notificationType == 'trigger_sync:events') {
    backgroundProcesses(backgroundSyncFromNotification, fromBackground: fromBackground);
  }
  // Add support in future for other  type of notifications like the handling of the visible ones
}

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  try {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      "background_channel",
      "background_channel",
      description: "Channel for background notifications",
    );
    onNotificationsReceived(message, flutterLocalNotificationsPlugin, channel, fromBackground: true);
    return;
  } catch (e) {
    print(e);
    rethrow;
  }
}

extension FirebaseMessagingExtension on FirebaseMessaging {
  void registerOnMessage(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, AndroidNotificationChannel channel) async {
    await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.getAPNSToken();

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => onNotificationsReceived(message, flutterLocalNotificationsPlugin, channel));

    FirebaseMessaging.onMessage
        .listen((message) => onNotificationsReceived(message, flutterLocalNotificationsPlugin, channel));
  }
}
