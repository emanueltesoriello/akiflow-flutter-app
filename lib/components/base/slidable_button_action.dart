import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SlidableButtonAction extends StatelessWidget {
  final Color backColor;
  final Color topColor;
  final String icon;
  final String? label;
  final String? bottomLabel;
  final Function() click;
  final bool leftToRight;

  const SlidableButtonAction({
    Key? key,
    required this.backColor,
    required this.topColor,
    required this.icon,
    this.label,
    this.bottomLabel,
    required this.click,
    required this.leftToRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) {
      return GestureDetector(
        onTap: click,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: SvgPicture.asset(
              icon,
              color: topColor,
              width: 24,
              height: 24,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: click,
        child: Container(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.centerRight,
            child: _content(),
          ),
        ),
      );
    }
  }

  Row _content() {
    if (leftToRight) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            color: topColor,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 4.5),
          Text(
            label!,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: topColor,
            ),
          ),
          const Spacer(),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            label!,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: topColor,
            ),
          ),
          const SizedBox(width: 4.5),
          SvgPicture.asset(
            icon,
            color: topColor,
            width: 24,
            height: 24,
          ),
        ],
      );
    }
  }
}
