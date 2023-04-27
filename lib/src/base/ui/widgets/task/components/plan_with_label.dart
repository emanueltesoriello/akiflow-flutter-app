import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/slidable_button_action.dart';

class PlanWithLabel extends StatelessWidget {
  const PlanWithLabel({Key? key, required this.click}) : super(key: key);
  final VoidCallback click;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: SlidableButtonAction(
            backColor: ColorsExt.cyan25(context),
            topColor: ColorsExt.cyan(context),
            icon: Assets.images.icons.common.calendarSVG,
            label: t.task.plan,
            leftToRight: false,
            click: () {
              click.call();
            },
          ),
        ),
      ],
    );
  }
}
