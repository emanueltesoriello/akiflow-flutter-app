import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/sizes.dart';

class SlidableButtonAction extends StatelessWidget {
  final Color backColor;
  final Color topColor;
  final String icon;
  final String? label;
  final String? bottomLabel;
  final double? size;
  final Function() click;
  final bool leftToRight;

  const SlidableButtonAction({
    Key? key,
    required this.backColor,
    required this.topColor,
    required this.icon,
    this.label,
    this.bottomLabel,
    this.size,
    required this.click,
    required this.leftToRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) {
      return GestureDetector(
        onTap: click,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: SvgPicture.asset(
              icon,
              color: topColor,
              width: size ?? Dimension.defaultIconSize,
              height: size ?? Dimension.defaultIconSize,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: click,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: _content(context),
          ),
        ),
      );
    }
  }

  Row _content(BuildContext context) {
    if (leftToRight) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            color: topColor,
            width: size ?? Dimension.defaultIconSize,
            height: size ?? Dimension.defaultIconSize,
          ),
          const SizedBox(width: Dimension.paddingXS),
          Text(label!,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: topColor,
                  )),
          const Spacer(),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(label!,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w500, color: topColor)),
          const SizedBox(width: Dimension.paddingXS),
          SvgPicture.asset(
            icon,
            color: topColor,
            width: Dimension.defaultIconSize,
            height: Dimension.defaultIconSize,
          ),
        ],
      );
    }
  }
}
