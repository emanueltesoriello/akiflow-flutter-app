import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/common/style/colors.dart';

class BadgedIcon extends StatelessWidget {
  final String icon;
  final Widget? badge;

  const BadgedIcon({
    Key? key,
    required this.icon,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsExt.background(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, Platform.isAndroid ? -3 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: SvgPicture.asset(icon),
                )
              ],
            ),
          ),
          if (badge != null) Align(alignment: Alignment.topCenter, child: badge!),
        ],
      ),
    );
  }
}
