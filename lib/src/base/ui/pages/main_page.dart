import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/pages/auth_page.dart';
import 'package:mobile/src/base/ui/cubit/dialog/dialog_cubit.dart';
import 'package:mobile/src/home/ui/pages/home_page.dart';
import 'package:mobile/src/base/ui/widgets/custom_alert_dialog.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    Key? key,
    required this.userLogged,
  }) : super(key: key);

  final bool userLogged;

  @override
  Widget build(BuildContext context) {
    bool dialogShown = false;
    return BlocListener<DialogCubit, DialogState>(
      listener: (context, state) {
        if (state is DialogShowMessage) {
          if (dialogShown) {
            return;
          }
          dialogShown = true;
          Timer(const Duration(milliseconds: 1000), () => dialogShown = false);

          showDialog(context: context, builder: (_) => CustomAlertDialog(action: state.action));
        }
      },
      child: Builder(
        builder: (context) {
          if (userLogged) {
            return const HomePage();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
