import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/background_service.dart';
//import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/base/ui/widgets/floating_button.dart';
import 'package:mobile/src/base/ui/widgets/navbar/bottom_nav_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/bottom_task_actions.dart';
import 'package:mobile/src/home/ui/navigator/home_navigator.dart';
import 'package:mobile/src/home/ui/widgets/just_created_task_button.dart';
import 'package:mobile/src/home/ui/widgets/undo_button.dart';
import 'package:mobile/src/home/ui/widgets/webview.dart';
import 'package:mobile/src/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:mobile/src/onboarding/ui/pages/onboarding_tutorial.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher2() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case scheduleNotificationsTaskKey:
        print("$scheduleNotificationsTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case Workmanager.iOSBackgroundTask:
        print("You can access other plugins in the background, for example Directory.getTemporaryDirectory():");
        break;
    }

    return Future.value(true);
  });
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.bottomBarHeight, required this.homeViewType});
  final double bottomBarHeight;
  final int homeViewType;

  init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    DatabaseService databaseService = DatabaseService();
    await databaseService.open();
    try {
      setupLocator(preferences: preferences, databaseService: databaseService);
    } catch (e) {
      print(e);
    }
    print("environment: ${Config.development ? "dev" : "prod"}");
    await AnalyticsService.config();
  }

  runWorkmanagerNow() {
    Workmanager().registerOneOffTask(
      scheduleNotificationsTaskKey,
      scheduleNotificationsTaskKey,
      inputData: <String, dynamic>{
        'int': 1,
        'bool': true,
        'double': 1.0,
        'string': 'string',
        'array': [1, 2, 3],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const InternalWebView(),
        Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: FloatingButton(bottomBarHeight: bottomBarHeight),
          bottomNavigationBar: CustomBottomNavigationBar(
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
            bottomBarIconSize: 30,
            topPadding: MediaQuery.of(context).padding.top,
          ),
          appBar: AppBar(
            centerTitle: true,
            /*title: SizedBox(
              height: 30,
              child: Center(
                child: ElevatedButton(onPressed: runWorkmanagerNow, child: const Text('Test background service NOW')),
              ),
            ),*/
            actions: [
              ElevatedButton(
                child: Text("Test background"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    scheduleNotificationsTaskKey,
                    scheduleNotificationsTaskKey,
                  );
                },
              ),
            ],
          ),
          body: Builder(builder: (context) {
            return const HomePageNavigator();
          }),
        ),
        BlocBuilder<TasksCubit, TasksCubitState>(
          builder: (context, state) {
            bool anyInboxSelected = state.inboxTasks.any((t) => t.selected ?? false);
            bool anyTodaySelected = state.selectedDayTasks.any((t) => t.selected ?? false);
            bool anyLabelsSelected = state.labelTasks.any((t) => t.selected ?? false);

            if (anyInboxSelected || anyTodaySelected || anyLabelsSelected) {
              return const Align(
                alignment: Alignment.bottomCenter,
                child: BottomTaskActions(),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        const UndoBottomView(),
        const JustCreatedTaskView(),
        BlocBuilder<OnboardingCubit, OnboardingCubitState>(
          builder: (context, state) {
            if (state.show) {
              return const OnboardingTutorial();
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}

class Daaaamn extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Daaaamn> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Plugin initialization",
                  style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.black),
                ),
                ElevatedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () {
                    Workmanager().initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  },
                ),
                SizedBox(height: 16),

                //This task runs once.
                //Most likely this will trigger immediately
                ElevatedButton(
                  child: Text("Register OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      scheduleNotificationsTaskKey,
                      scheduleNotificationsTaskKey,
                      inputData: <String, dynamic>{
                        'int': 1,
                        'bool': true,
                        'double': 1.0,
                        'string': 'string',
                        'array': [1, 2, 3],
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Task cancellation",
                  style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.black),
                ),
                ElevatedButton(
                  child: Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    print('Cancel all tasks completed');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




/*import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Plugin initialization",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () {
                    Workmanager().initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  },
                ),
                SizedBox(height: 16),

                //This task runs once.
                //Most likely this will trigger immediately
                ElevatedButton(
                  child: Text("Register OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      scheduleNotificationsTaskKey,
                      scheduleNotificationsTaskKey,
                      inputData: <String, dynamic>{
                        'int': 1,
                        'bool': true,
                        'double': 1.0,
                        'string': 'string',
                        'array': [1, 2, 3],
                      },
                    );
                  },
                ),
                //This task runs periodically
                //It will run about every hour
                ElevatedButton(
                    child: Text("Register 1 hour Periodic Task (Android)"),
                    onPressed: Platform.isAndroid
                        ? () {
                            Workmanager().registerPeriodicTask(
                              scheduleNotificationsTaskKey,
                              scheduleNotificationsTaskKey,
                              frequency: Duration(hours: 1),
                            );
                          }
                        : null),
                SizedBox(height: 16),
                Text(
                  "Task cancellation",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    print('Cancel all tasks completed');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/