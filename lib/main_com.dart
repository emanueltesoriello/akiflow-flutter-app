import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/dialog/dialog_cubit.dart';
import 'package:mobile/features/home/cubit/home_cubit.dart';
import 'package:mobile/features/home/ui/home_page.dart';
import 'package:mobile/style/theme.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> mainCom() async {
  /// Initialize Sembast database
  Database db = await _openDatabase();

  /// Initialize Preferences
  SharedPreferences preferences = await SharedPreferences.getInstance();

  /// Setup the injector
  setupLocator(db, preferences);

  runApp(const Application());
}

bool dialogShown = false;

Future<Database> _openDatabase() async {
  final appDocDir = await getApplicationDocumentsDirectory();

  await appDocDir.create(recursive: true);

  final path = join(appDocDir.path, "local.db");

  DatabaseFactory dbFactory = databaseFactoryIo;

  final db = await dbFactory.openDatabase(path, version: 1);

  return db;
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

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
        BlocProvider<AuthCubit>(
          lazy: false,
          create: (BuildContext context) => AuthCubit(),
        ),
        BlocProvider<HomeCubit>(
          lazy: false,
          create: (BuildContext context) => HomeCubit(),
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
            child: const HomePage(),
          )),
    );
  }
}
