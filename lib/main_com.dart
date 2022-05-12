import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/features/dialog/dialog_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/ui/main_page.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';
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
        BlocProvider<TasksCubit>(
          lazy: false,
          create: (BuildContext context) => TasksCubit(),
        ),
        BlocProvider<MainCubit>(
          lazy: false,
          create: (BuildContext context) => MainCubit(),
        ),
        BlocProvider<AuthCubit>(
          lazy: false,
          create: (BuildContext context) => AuthCubit(
            context.read<TasksCubit>(),
          ),
        ),
        BlocProvider<SettingsCubit>(
          lazy: false,
          create: (BuildContext context) => SettingsCubit(),
        ),
        BlocProvider<TodayCubit>(
          lazy: false,
          create: (BuildContext context) => TodayCubit(context.read<TasksCubit>()),
        ),
      ],
      child: MaterialApp(
          title: t.appName,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: const Locale('it', 'IT'),
          supportedLocales: const [
            Locale('it', 'IT'),
          ],
          debugShowCheckedModeBanner: Config.development,
          navigatorObservers: [routeObserver],
          theme: lightTheme,
          home: BlocListener<DialogCubit, DialogState>(
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
            child: Builder(
              builder: (context) {
                if (userLogged) {
                  return MainPage();
                } else {
                  return const AuthPage();
                }
              },
            ),
          )),
    );
  }
}
