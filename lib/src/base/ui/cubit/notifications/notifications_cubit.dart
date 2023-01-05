import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsCubitState> {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationsCubit() : super(const NotificationsCubitState()) {
    setupLocalNotificationsPlugin();
    init();
  }

  // ************ INIT FUNCTIONS ************
  // ****************************************
  init() async {
    // ************* ONESIGNAL *********
    // *********************************
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId("b698eb0f-03cc-43a3-a131-8910095a4b21");

    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      print('notification received');
      event.complete(null); //pass null param for not displaying the notification
      _localNotificationsPlugin.show(
          22,
          "title",
          "body",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "channel.id",
              "channel.name",
              channelDescription: "channel.description",
              // other properties...
            ),
          ));
    });

    // *********************************
    // **********************************/
  }

  Future<void> setupLocalNotificationsPlugin() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSetting = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);

    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      print('setupPlugin: setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });
  }

  // ********************
  // ********************
  static showNotifications(String title, String description) {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localNotificationsPlugin.show(
        22,
        title,
        description,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            "channel.id",
            "channel.name",
            channelDescription: "default.channelDescription",
            // other properties...
          ),
        ));
  }
}
