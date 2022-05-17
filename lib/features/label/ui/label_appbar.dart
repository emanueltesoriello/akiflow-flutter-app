import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/label/label.dart';

class LabelAppBar extends StatelessWidget {
  final Label label;

  const LabelAppBar({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconBackground;
    Color iconForeground;

    if (label.color != null) {
      iconBackground = ColorsExt.getFromName(label.color!).withOpacity(0.1);
      iconForeground = ColorsExt.getFromName(label.color!);
    } else {
      iconBackground = ColorsExt.grey6(context);
      iconForeground = ColorsExt.grey2(context);
    }

    return AppBarComp(
      title: label.title ?? t.task.noTitle,
      showSyncButton: false,
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: iconBackground,
        ),
        height: 26,
        width: 26,
        child: Center(
          child: SvgPicture.asset(
            "assets/images/icons/_common/number.svg",
            width: 15,
            height: 15,
            color: iconForeground,
          ),
        ),
      ),
    );
  }
}
