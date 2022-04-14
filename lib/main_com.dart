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
import 'package:mobile/style/theme.dart';
import 'package:mobile/utils/database_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> mainCom() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  Database database = await DatabaseUtils.open();

  setupLocator(preferences: preferences, database: database);

  bool userLogged = locator<PreferencesRepository>().user != null;

  runApp(Application(userLogged: userLogged));
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
          create: (BuildContext context) => DialogCubit(),
        ),
        BlocProvider<TasksCubit>(
          create: (BuildContext context) => TasksCubit(),
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
        BlocProvider<MainCubit>(
          lazy: false,
          create: (BuildContext context) => MainCubit(
            context.read<TasksCubit>(),
            context.read<AuthCubit>(),
          ),
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
                    title: Text(state.action.title),
                    content: state.action.content != null
                        ? Text(state.action.content!)
                        : null,
                    actions: <Widget>[
                      state.action.dismiss != null
                          ? TextButton(
                              child:
                                  Text(state.action.dismissTitle ?? t.dismiss),
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
            child: userLogged ? MainPage() : const AuthPage(),
          )),
    );
  }
}
