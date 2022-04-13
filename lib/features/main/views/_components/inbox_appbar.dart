import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/style/colors.dart';

class InboxAppBar extends StatelessWidget {
  const InboxAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: t.bottom_bar.inbox,
      leading: Icon(
        SFSymbols.tray,
        size: 26,
        color: ColorsExt.grey2(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            SFSymbols.ellipsis,
            size: 18,
            color: ColorsExt.grey2(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
