import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/core/chrono_node_js.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/features/dialog/dialog_cubit.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/ui/main_page.dart';
import 'package:mobile/features/push/cubit/push_cubit.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

FutureOr<SentryEvent?> beforeSend(SentryEvent event, {dynamic hint}) async {
  if (Config.development || SentryService.ignoreException(event.throwable)) {
    return null;
  }

  return event;
}

Future<void> mainCom() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  DatabaseService databaseService = DatabaseService();

  await databaseService.open();

  setupLocator(preferences: preferences, databaseService: databaseService);

  bool userLogged = locator<PreferencesRepository>().user != null;

  print("environment: ${Config.development ? "dev" : "prod"}");

  await ChronoNodeJs.init();

  await SentryFlutter.init(
    (options) {
      options.beforeSend = beforeSend;
      options.dsn = Config.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(Application(userLogged: userLogged)),
  );
}

bool dialogShown = false;

class Application extends StatelessWidget {
  final bool userLogged;

  const Application({
    Key? key,
    required this.userLogged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<DialogCubit>(
          lazy: false,
          create: (BuildContext context) => DialogCubit(),
        ),
        BlocProvider<PushCubit>(
          lazy: false,
          create: (BuildContext context) => locator<PushCubit>(),
        ),
        BlocProvider<SyncCubit>(
          lazy: false,
          create: (BuildContext context) => locator<SyncCubit>(),
        ),
        BlocProvider<TasksCubit>(
          lazy: false,
          create: (BuildContext context) => locator<TasksCubit>(),
        ),
        BlocProvider<LabelsCubit>(
          lazy: false,
          create: (BuildContext context) => LabelsCubit(locator<SyncCubit>()),
        ),
        BlocProvider<MainCubit>(
          lazy: false,
          create: (BuildContext context) => MainCubit(locator<SyncCubit>()),
        ),
        BlocProvider<AuthCubit>(
          lazy: false,
          create: (BuildContext context) => locator<AuthCubit>(),
        ),
        BlocProvider<SettingsCubit>(
          lazy: false,
          create: (BuildContext context) => SettingsCubit(
            context.read<LabelsCubit>(),
            locator<AuthCubit>(),
            locator<SyncCubit>(),
          ),
        ),
        BlocProvider<TodayCubit>(
          lazy: false,
          create: (BuildContext context) => locator<TodayCubit>(),
        ),
        BlocProvider<EditTaskCubit>(
          lazy: false,
          create: (BuildContext context) => EditTaskCubit(locator<TasksCubit>(), locator<SyncCubit>()),
        ),
      ],
      child: MaterialApp(
        title: t.appName,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        debugShowCheckedModeBanner: Config.development,
        navigatorObservers: [routeObserver],
        theme: lightTheme,
        home: _Home(userLogged: userLogged),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    Key? key,
    required this.userLogged,
  }) : super(key: key);

  final bool userLogged;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DialogCubit, DialogState>(
      listener: (context, state) {
        if (state is DialogShowMessage) {
          if (dialogShown) {
            return;
          }

          dialogShown = true;

          Timer(
            const Duration(milliseconds: 1000),
            () {
              dialogShown = false;
            },
          );

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(state.action.title, style: TextStyle(color: ColorsExt.grey1(context))),
              content: state.action.content != null
                  ? Text(state.action.content!, style: TextStyle(color: ColorsExt.grey1(context)))
                  : null,
              actions: <Widget>[
                state.action.dismiss != null
                    ? TextButton(
                        child: Text(state.action.dismissTitle ?? t.dismiss),
                        onPressed: () {
                          Navigator.pop(context);
                          state.action.dismiss!();
                        },
                      )
                    : Container(),
                TextButton(
                  child: Text(state.action.confirmTitle ?? t.ok),
                  onPressed: () {
                    Navigator.pop(context);
                    if (state.action.confirm != null) {
                      state.action.confirm!();
                    }
                  },
                ),
              ],
            ),
          );
        }
      },
      child: Stack(
        children: [
          Builder(
            builder: (context) {
              if (userLogged) {
                return const MainPage();
              } else {
                return const AuthPage();
              }
            },
          ),
          const UndoBottomView(),
          const JustCreatedTaskView(),
        ],
      ),
    );
  }
}

class UndoBottomView extends StatelessWidget {
  const UndoBottomView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        if (state.queue.isEmpty) {
          return const SizedBox();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 51,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsExt.grey6(context),
                    border: Border.all(
                      color: ColorsExt.grey5(context),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.queue.first.type.text,
                            style:
                                TextStyle(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              context.read<TasksCubit>().undo();
                            },
                            child: Text(t.task.undo.toUpperCase(),
                                style: TextStyle(
                                    color: ColorsExt.akiflow(context), fontWeight: FontWeight.w500, fontSize: 15))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Builder(builder: (context) {
              if (Platform.isIOS) {
                return SizedBox(height: MediaQuery.of(context).padding.top + kBottomNavigationBarHeight + 10);
              } else {
                return SizedBox(height: MediaQuery.of(context).viewInsets.bottom + kBottomNavigationBarHeight + 16);
              }
            }),
          ],
        );
      },
    );
  }
}

class JustCreatedTaskView extends StatelessWidget {
  const JustCreatedTaskView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        if (state.justCreatedTask == null) {
          return const SizedBox();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 51,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsExt.grey6(context),
                    border: Border.all(
                      color: ColorsExt.grey5(context),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.task.taskCreatedSuccessfully,
                            style:
                                TextStyle(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Task task = state.justCreatedTask!;

                              TaskStatusType? statusType = task.statusType;
                              String? date = task.date;

                              if (statusType == null || statusType == TaskStatusType.inbox) {
                                context.read<MainCubit>().changeHomeView(HomeViewType.inbox);
                              } else {
                                if (date != null) {
                                  DateTime dateParsed = DateTime.parse(date).toLocal();
                                  context.read<MainCubit>().changeHomeView(HomeViewType.today);
                                  context.read<TodayCubit>().onDateSelected(dateParsed);
                                } else {
                                  context.read<MainCubit>().changeHomeView(HomeViewType.today);
                                }
                              }
                            },
                            child: Text(t.view.toUpperCase(),
                                style: TextStyle(
                                    color: ColorsExt.akiflow(context), fontWeight: FontWeight.w500, fontSize: 15))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Builder(builder: (context) {
              if (Platform.isIOS) {
                return SizedBox(height: MediaQuery.of(context).padding.top + kBottomNavigationBarHeight + 10);
              } else {
                return SizedBox(height: MediaQuery.of(context).viewInsets.bottom + kBottomNavigationBarHeight + 16);
              }
            }),
          ],
        );
      },
    );
  }
}
