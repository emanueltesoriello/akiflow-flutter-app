import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/dialog_service.dart';
import 'package:mobile/main_com.dart';
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
import 'package:mobile/core/preferences.dart';

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
    bool userLogged =
        locator<PreferencesRepository>().user != null && locator<PreferencesRepository>().user!.accessToken != null;
    print("environment: ${Config.development ? "dev" : "prod"}");
    await AnalyticsService.config();
  }

  void initWorkmanager() async {
    try {
      //GetIt locator = GetIt.instance;
      //var a = locator.get<DatabaseService>();
      //await init();

      var b = 0;
    } catch (e) {
      print(e);
      //await init();
    }
    Workmanager().cancelAll;
    Workmanager().initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode:
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
    Workmanager().registerOneOffTask(
      DateTime.now().toString(),
      DateTime.now().toString(),
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
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    initWorkmanager();
                    /*WidgetsFlutterBinding.ensureInitialized();
                    final preferences = await StreamingSharedPreferences.instance;
                    preferences.setBool('startedBackgroundSync', true);*/
                  },
                  child: Text('Test'))
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
