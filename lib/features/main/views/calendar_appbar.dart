import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/style/colors.dart';

class CalendarAppBar extends StatelessWidget {
  const CalendarAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: DateFormat('EEE').format(DateTime.now()),
      leading: SvgPicture.asset(
        "assets/images/icons/_common/calendar.svg",
        width: 26,
        height: 26,
        color: ColorsExt.grey2(context),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/icons/_common/ellipsis.svg",
            width: 26,
            height: 26,
            color: ColorsExt.grey2(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
