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
        height: isBig ? 34 : 22,
        width: isSquare ? (isBig ? 34 : 22) : null,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                          fontSize: 13,
                          color: foregroundColor ?? ColorsExt.grey2(context),
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
