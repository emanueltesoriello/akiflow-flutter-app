import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/style/colors.dart';

class TagBox extends StatelessWidget {
  final String? icon;
  final double? iconSize;
  final String? text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final Function() onPressed;
  final bool isBig;
  final bool isSquare;

  const TagBox({
    Key? key,
    this.icon,
    this.iconSize,
    this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    required this.onPressed,
    this.isBig = false,
    this.isSquare = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() => onPressed()),
      child: Container(
        constraints: BoxConstraints(
          minHeight: isBig ? 32 : 28,
          minWidth: isSquare ? (isBig ? 32 : 28) : 0,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 6),
            Builder(builder: (context) {
              if (icon == null) {
                return const SizedBox();
              }

              return SvgPicture.asset(
                icon!,
                color: foregroundColor ?? iconColor,
                width: iconSize ?? (isBig ? 22 : 14),
                height: iconSize ?? (isBig ? 22 : 14),
              );
            }),
            Flexible(
              child: Builder(builder: (context) {
                if (text == null) {
                  return const SizedBox();
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: icon != null ? 3 : 0),
                    Flexible(
                      child: Text(
                        text!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isBig ? 15 : 13,
                          color: foregroundColor ?? ColorsExt.grey2(context),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
