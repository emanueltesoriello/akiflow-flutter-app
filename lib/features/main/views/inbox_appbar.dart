import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/style/colors.dart';

class InboxAppBar extends StatelessWidget {
  const InboxAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: t.bottomBar.inbox,
      leading: SvgPicture.asset(
        "assets/images/icons/_common/tray.svg",
        width: 26,
        height: 26,
        color: ColorsExt.grey2(context),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/icons/_common/ellipsis.svg",
            width: 26,
            height: 26,
            color: ColorsExt.grey2(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
