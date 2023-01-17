import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      print('setupPlugin: setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });
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
}
