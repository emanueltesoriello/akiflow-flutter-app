import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/label/label.dart';

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
      iconBackground = ColorsExt.getFromName(label.color!).withOpacity(0.1);
      iconForeground = ColorsExt.getFromName(label.color!);
    } else {
      iconBackground = ColorsExt.grey6(context);
      iconForeground = ColorsExt.grey2(context);
    }

    String iconAsset;

    if (label.id != null) {
      iconAsset = "assets/images/icons/_common/number.svg";
    } else {
      iconAsset = "assets/images/icons/_common/slash_circle.svg";
      iconBackground = Colors.transparent;
      iconForeground = ColorsExt.grey3(context);
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Row(
            children: [
              Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: iconBackground,
                ),
                child: Center(
                  child: SvgPicture.asset(iconAsset, width: 16, height: 16, color: iconForeground),
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

    return Wrap(
      children: [
        const SizedBox(width: 8),
        Text(
          label.title??'(No title)',
          style: TextStyle(
            fontSize: 17,
            color: label.id != null ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
          ),
        ),
        Builder(builder: (context) {
          if (folder == null) {
            return const SizedBox();
          }

          return Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset("assets/images/icons/_common/folder.svg",
                  width: 16, height: 16, color: ColorsExt.grey3(context)),
              const SizedBox(width: 4),
              Text(
                folder?.title ?? "",
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
