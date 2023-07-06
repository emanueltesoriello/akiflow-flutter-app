import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/pages/auth_page.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/pages/main_page.dart';

class BaseNavigator extends StatefulWidget {
  final bool userLogged;

  const BaseNavigator({Key? key, required this.userLogged}) : super(key: key);

  @override
  State<BaseNavigator> createState() => _BaseNavigatorState();
}

class _BaseNavigatorState extends State<BaseNavigator> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        if (state.user == null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
            builder: (BuildContext context) => const AuthPage(),
          ));
        }
      },
      child: MainPage(userLogged: widget.userLogged),
    );
  }
}
