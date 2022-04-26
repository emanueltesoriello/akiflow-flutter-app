import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_action.dart';
import 'package:mobile/style/colors.dart';

class BottomTaskActions extends StatelessWidget {
  const BottomTaskActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.cyan25(context),
                  topColor: ColorsExt.cyan(context),
                  icon: 'assets/images/icons/_common/calendar.svg',
                  bottomLabel: t.task.plan,
                  click: () {
                    // TODO plan selected
                  },
                ),
              ),
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.pink30(context),
                  topColor: ColorsExt.pink(context),
                  icon: 'assets/images/icons/_common/clock.svg',
                  bottomLabel: t.task.snooze,
                  click: () {
                    // TODO snooze selected
                  },
                ),
              ),
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.grey5(context),
                  topColor: ColorsExt.grey3(context),
                  icon: 'assets/images/icons/_common/number.svg',
                  bottomLabel: t.task.assign,
                  click: () {
                    // TODO label selected
                  },
                ),
              ),
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.grey5(context),
                  topColor: ColorsExt.grey3(context),
                  icon: 'assets/images/icons/_common/exclamationmark.svg',
                  bottomLabel: t.task.priority,
                  click: () {
                    // TODO priority selected
                  },
                ),
              ),
              Expanded(
                child: IconButton(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
