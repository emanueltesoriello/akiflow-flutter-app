
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:models/task/task.dart';

import '../../../common/style/colors.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader(
    this.title, {
    Key? key,
    required this.tasks,
    required this.listOpened,
    required this.onClick,
    required this.usePrimaryColor,
  }) : super(key: key);

  final String title;
  final List<Task> tasks;
  final bool listOpened;
  final Function() onClick;
  final bool usePrimaryColor;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox();
    }

    return InkWell(
      onTap: onClick,
      child: Container(
        height: 42,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ColorsExt.grey5(context),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context))),
            const SizedBox(width: 4),
            Text("(${tasks.length})",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: usePrimaryColor ? ColorsExt.akiflow(context) : ColorsExt.grey2(context))),
            const Spacer(),
            SvgPicture.asset(
              listOpened
                  ? "assets/images/icons/_common/chevron_up.svg"
                  : "assets/images/icons/_common/chevron_down.svg",
              color: ColorsExt.grey3(context),
              width: 20,
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
