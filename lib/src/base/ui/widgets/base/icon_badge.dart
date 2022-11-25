import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';

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
        decoration: BoxDecoration(
          border: Border.all(color: ColorsExt.background(context), width: 2),
          shape: BoxShape.circle,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsExt.akiflow(context),
          ),
          height: 16,
          width: 16,
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
      ),
    );
  }
}
