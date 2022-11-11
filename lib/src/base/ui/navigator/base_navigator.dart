import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/cubit/base_cubit.dart';

final _baseNavigationKey = GlobalKey<NavigatorState>();

class BaseNavigator extends StatefulWidget {
  const BaseNavigator({Key? key}) : super(key: key);

  @override
  State<BaseNavigator> createState() => _BaseNavigatorState();
}

class _BaseNavigatorState extends State<BaseNavigator> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<BaseCubit, BaseCubitState>(
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
    );
  }
}
