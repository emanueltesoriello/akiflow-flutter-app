import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/core/services/dialog_service.dart';
import 'package:mobile/common/style/colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final DialogAction action;

  const CustomAlertDialog({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(action.title, style: TextStyle(color: ColorsExt.grey1(context))),
      content: action.content != null ? Text(action.content!, style: TextStyle(color: ColorsExt.grey1(context))) : null,
      actions: <Widget>[
        action.dismiss != null
            ? TextButton(
                child: Text(action.dismissTitle ?? t.dismiss),
                onPressed: () {
                  Navigator.pop(context);
                  action.dismiss!();
                },
              )
            : const SizedBox(),
        TextButton(
          child: Text(action.confirmTitle ?? t.ok),
          onPressed: () {
            Navigator.pop(context);
            if (action.confirm != null) {
              action.confirm!();
            }
          },
        ),
      ],
    );
  }
}
