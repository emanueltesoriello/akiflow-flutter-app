import 'dart:io';

import 'package:flutter/material.dart';

import '../../style/colors.dart';

class IconBadge extends StatelessWidget {
  final int count;
  final Offset? offset;

  const IconBadge(this.count, {Key? key, this.offset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox();
    }

    return Transform.translate(
      offset: offset ?? Offset(17, Platform.isAndroid ? 5 : 8),
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: ColorsExt.akiflow(context),
          border: Border.all(color: ColorsExt.background(context), width: 1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            count > 99 ? "99+" : count.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: count > 99 ? 6 : 9,
              fontWeight: FontWeight.w600,
              color: ColorsExt.background(context),
            ),
          ),
        ),
      ),
    );
  }
}
