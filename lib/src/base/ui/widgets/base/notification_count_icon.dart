import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';

class NotifcationCountIcon extends StatelessWidget {
  final int count;

  const NotifcationCountIcon(
    this.count, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox();
    }

    return Container(
      width: 25,
      height: 25,
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
            fontSize: count > 99 ? 6 : 12,
            fontWeight: FontWeight.w600,
            color: ColorsExt.background(context),
          ),
        ),
      ),
    );
  }
}
