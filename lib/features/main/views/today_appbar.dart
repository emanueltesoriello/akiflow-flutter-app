import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/style/colors.dart';

class TodayAppBar extends StatelessWidget {
  const TodayAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: DateFormat('EEE, dd').format(DateTime.now()),
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
