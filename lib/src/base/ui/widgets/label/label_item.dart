import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:models/label/label.dart';

import 'label_title.dart';

class LabelItem extends StatelessWidget {
  final Label label;
  final Label? folder;
  final Function() onTap;

  const LabelItem(
    this.label, {
    Key? key,
    this.folder,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconBackground;
    Color iconForeground;

    if (label.color != null) {
      iconBackground = ColorsExt.getBgColorFromName(context, label.color!);
      iconForeground = ColorsExt.getFromName(label.color!);
    } else {
      iconBackground = ColorsExt.grey100(context);
      iconForeground = ColorsExt.grey800(context);
    }

    String iconAsset;

    if (label.id != null) {
      iconAsset = Assets.images.icons.common.numberSVG;
    } else {
      iconAsset = Assets.images.icons.common.slashCircleSVG;
      iconBackground = Colors.transparent;
      iconForeground = ColorsExt.grey600(context);
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Dimension.radius),
        child: Row(
          children: [
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimension.radiusS),
                color: iconBackground,
              ),
              child: Center(
                child: SvgPicture.asset(iconAsset,
                    width: Dimension.padding, height: Dimension.padding, color: iconForeground),
              ),
            ),
            Expanded(child: LabelTitle(label: label, folder: folder)),
          ],
        ),
      ),
    );
  }
}
