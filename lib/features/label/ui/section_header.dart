import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';

class SectionHeaderItem extends StatelessWidget {
  const SectionHeaderItem(
    this.title, {
    Key? key,
    required this.taskCount,
    required this.listOpened,
    required this.onClick,
  }) : super(key: key);

  final String title;
  final int taskCount;
  final bool listOpened;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
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
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06), // shadow color
            ),
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 6,
              color: ColorsExt.grey7(context),
              // background color
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context))),
            const SizedBox(width: 4),
            Text("($taskCount)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context))),
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
