import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/style/colors.dart';

class ButtonIconed extends StatelessWidget {
  final String icon;
  final double? iconSize;
  final String? text;
  final Function() onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  const ButtonIconed({
    Key? key,
    required this.icon,
    this.iconSize,
    this.text,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() => onPressed()),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              color: iconColor,
              width: iconSize ?? 12,
              height: iconSize ?? 12,
            ),
            Flexible(
              child: Builder(builder: (context) {
                if (text == null) {
                  return const SizedBox();
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        text!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: ColorsExt.grey2(context),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
