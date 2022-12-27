import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

part 'notifications_state.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //Timer.periodic(const Duration(seconds: 2), (timer) async {
    int? totalExecutions;
    final _sharedPreference = await SharedPreferences.getInstance(); //Initialize dependency

    try {
      //add code execution
      totalExecutions = _sharedPreference.getInt("totalExecutions");
      _sharedPreference.setInt("totalExecutions", totalExecutions == null ? 1 : totalExecutions + 1);
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
    } catch (err) {
      print(err.toString()); // Logger flutter package, prints error on the debug console
      throw Exception(err);
    }
    //});

    return Future.value(true);
  });
}

void initWorkmanager() {
  Workmanager().initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerPeriodicTask(
    "task-identifier",
    "simpleTask",
    frequency: const Duration(minutes: 15),
  );
}

class NotificationsCubit extends Cubit<NotificationsCubitState> {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationsCubit() : super(const NotificationsCubitState()) {
    setupLocalNotificationsPlugin();
    init();
    initWorkmanager();
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

}
