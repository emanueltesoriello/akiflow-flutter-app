import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/task/task.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader(
    this.title, {
    Key? key,
    required this.tasks,
    required this.listOpened,
    required this.onClick,
  }) : super(key: key);

  final String title;
  final List<Task> tasks;
  final bool listOpened;
  final Function() onClick;

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
        
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context))),
            const SizedBox(width: 4),
            Text("(${tasks.length})",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:  ColorsExt.grey2(context))),
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
