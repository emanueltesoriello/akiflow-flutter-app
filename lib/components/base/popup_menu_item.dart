import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';

class PopupMenuCustomItem extends StatelessWidget {
  final String iconAsset;
  final String text;

  const PopupMenuCustomItem({
    Key? key,
    required this.iconAsset,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 22, height: 22, child: SvgPicture.asset(iconAsset, color: ColorsExt.grey2(context))),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
