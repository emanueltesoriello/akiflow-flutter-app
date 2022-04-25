import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/components/base/button_action.dart';
import 'package:mobile/style/colors.dart';

class BottomTaskActions extends StatelessWidget {
  const BottomTaskActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ButtonAction(
            backColor: ColorsExt.cyan25(context),
            topColor: ColorsExt.cyan(context),
            icon: 'assets/images/icons/_common/calendar.svg',
            click: () {
              // TODO plan selected
            },
          ),
          ButtonAction(
            backColor: ColorsExt.pink30(context),
            topColor: ColorsExt.pink(context),
            icon: 'assets/images/icons/_common/clock.svg',
            click: () {
              // TODO snooze selected
            },
          ),
          ButtonAction(
            backColor: ColorsExt.grey5(context),
            topColor: ColorsExt.grey3(context),
            icon: 'assets/images/icons/_common/number.svg',
            click: () {
              // TODO label selected
            },
          ),
          ButtonAction(
            backColor: ColorsExt.grey5(context),
            topColor: ColorsExt.grey3(context),
            icon: 'assets/images/icons/_common/exclamationmark.svg',
            click: () {
              // TODO priority selected
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              "assets/images/icons/_common/ellipsis.svg",
              width: 26,
              height: 26,
              color: ColorsExt.grey2(context),
            ),
            onPressed: () {
              // TODO open dropdown
            },
          ),
        ],
      ),
    );
  }
}
