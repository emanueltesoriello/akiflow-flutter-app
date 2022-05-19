import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/label/label.dart';

class LabelItem extends StatelessWidget {
  final Label label;
  final Function() onTap;

  const LabelItem(
    this.label, {
    Key? key,
    required this.onTap,
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

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Row(
            children: [
              Container(
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
              _text(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(BuildContext context) {
    if (label.title == null || label.title!.isEmpty) {
      return const SizedBox();
    }

    return Wrap(
      children: [
        const SizedBox(width: 8),
        Text(
          label.title!,
          style: TextStyle(
            fontSize: 17,
            color: ColorsExt.grey2(context),
          ),
        ),
        Builder(builder: (context) {
          if (label.type == null || label.type != "folder") {
            return const SizedBox();
          }

          return Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset("assets/images/icons/_common/folder.svg",
                  width: 16, height: 16, color: ColorsExt.grey3(context)),
              const SizedBox(width: 4),
              Text(
                t.addTask.folder,
                style: TextStyle(
                  fontSize: 15,
                  color: ColorsExt.grey3(context),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
