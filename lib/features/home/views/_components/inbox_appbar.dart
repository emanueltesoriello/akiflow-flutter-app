import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:mobile/components/app_bar.dart';
import 'package:mobile/style/colors.dart';

class InboxAppBar extends StatelessWidget {
  const InboxAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: 'Inbox',
      leading: Icon(
        SFSymbols.tray,
        size: 26,
        color: ColorsExt.textGrey2_5(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            SFSymbols.ellipsis,
            size: 18,
            color: ColorsExt.textGrey3(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
