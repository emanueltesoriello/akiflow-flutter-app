import 'package:flutter/material.dart';

import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';

import '../../base/slidable_button_action.dart';

class DoneWithLabel extends StatelessWidget {
  const DoneWithLabel({Key? key, required this.click, required this.withLabel}) : super(key: key);
  final VoidCallback click;
  final bool withLabel;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: SlidableButtonAction(
            backColor: ColorsExt.green20(context),
            topColor: ColorsExt.green(context),
            icon: 'assets/images/icons/_common/Check-done.svg',
            label: withLabel ? t.task.done.toUpperCase() : null,
            size: 28,
            leftToRight: true,
            click: () {
      
              click.call();
            },
          ),
        ),
      ],
    );
  }
}
