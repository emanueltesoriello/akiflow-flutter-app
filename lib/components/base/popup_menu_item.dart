import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';

class PopupMenuCustomItem extends StatelessWidget {
  final String iconAsset;
  final String text;
  final bool enabled;

  const PopupMenuCustomItem({
    Key? key,
    required this.iconAsset,
    required this.text,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 22,
            height: 22,
            child: SvgPicture.asset(iconAsset, color: enabled ? ColorsExt.grey2(context) : ColorsExt.grey3(context))),
        const SizedBox(width: 8),
        Expanded(
            child: Text(
          text,
          style: TextStyle(
              color: enabled ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
              fontSize: 15,
              fontWeight: FontWeight.w500),
        )),
      ],
    );
  }
}
