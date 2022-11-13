import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/account/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/account/auth/ui/trial_expired_page.dart';
import 'package:mobile/features/account/auth/ui/auth_page.dart';
import 'package:mobile/features/dialog/dialog_cubit.dart';
import 'package:mobile/features/main/ui/main_page.dart';
import 'package:mobile/src/updates/ui/widget/custom_navigator_pop_scope.dart';
import 'package:mobile/core/preferences.dart';

//final _baseNavigationKey = GlobalKey<NavigatorState>();

class BaseNavigator extends StatefulWidget {
  const BaseNavigator({Key? key}) : super(key: key);

  @override
  State<BaseNavigator> createState() => _BaseNavigatorState();
}

class _BaseNavigatorState extends State<BaseNavigator> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (BuildContext context) => StartPageNavigator(state: state),
        ));
        /* if (state.hasValidPlan == false) {
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
            builder: (BuildContext context) => const TrialExpiredPage(),
          ));
        }
        if (state.user == null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
            builder: (BuildContext context) => const AuthPage(),
          ));
        }*/
      },
      child: const Scaffold(
        body: Center(
          child: Text('Loading (default)..'),
        ),
      ), //_Home(userLogged: userLogged),
    );
    /*return BlocListener<BaseCubit, BaseCubitState>(
      listener: (context, state) {
        if (!state.hasValidPlan) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => const Scaffold(
              body: Center(
                child: Text('Not valid plan'),
              ),
            ),
          ));
        }
        if (state.isLoading) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => const Scaffold(
              body: Center(
                child: Text('Loading'),
              ),
            ),
          ));
        }
        if (state.dialogShown) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => const Scaffold(
              body: Center(
                child: Text('Show dialog'),
              ),
            ),
          ));
        }
        if (state.userLogged) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => const Scaffold(
              body: Center(
                child: Text('User logged'),
              ),
            ),
          ));
        }
      },
      child: const Scaffold(
        body: Center(
          child: Text('Default'),
        ),
      ),
    );*/
  }
}

final _startPageNavigationKey = GlobalKey<NavigatorState>();

class StartPageNavigator extends StatelessWidget {
  final AuthCubitState state;
  const StartPageNavigator({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomNavigatorPopScope(
      navigatorStateKey: _startPageNavigationKey,
      pages: [
        //This is just for the presentation for a correct use, we consider using a proper splash screen
        if (!state.hasValidPlan) const MaterialPage(child: TrialExpiredPage()),
        if (/*state.hasValidPlan &&*/
        locator<PreferencesRepository>().user != null &&
            locator<PreferencesRepository>().user!.accessToken != null &&
            state.authenticated)
          const MaterialPage(
            child: MainPage(),
          ),
        if (state.loading)
          const MaterialPage(
            child: Scaffold(
              body: Center(
                child: Text('Loading..'),
              ),
            ),
          ),
        if (state.user == null) const MaterialPage(child: AuthPage()),
      ],
      onPopPage: (route, result) {
        // viewModel.navigationState = StartPageNavigationState.startPage;
        return false;
      },
    );
  }
}
/*

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
                    : const SizedBox(),
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
         // if (userLogged) {
            return const MainPage();
         // } else {
        //    return const AuthPage();
        //  }
        },
      ),
    );
  }
}*/
