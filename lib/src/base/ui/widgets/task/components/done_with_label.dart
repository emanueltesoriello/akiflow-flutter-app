import 'package:flutter/material.dart';

import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/slidable_button_action.dart';

class DoneWithLabel extends StatelessWidget {
  const DoneWithLabel({Key? key, this.iconColor, required this.click, required this.withLabel}) : super(key: key);
  final VoidCallback click;
  final bool withLabel;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: SlidableButtonAction(
            backColor: ColorsExt.green20(context),
            topColor: iconColor ?? ColorsExt.green(context),
            icon: Assets.images.icons.common.checkDoneSVG,
            label: withLabel ? t.task.done : null,
            size: Dimension.defaultIconSize,
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
