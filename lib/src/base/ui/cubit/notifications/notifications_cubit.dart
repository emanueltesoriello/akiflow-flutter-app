import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    /*_localNotificationsPlugin.show(
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
          ));*/

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
