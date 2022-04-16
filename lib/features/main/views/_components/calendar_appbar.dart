import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/style/colors.dart';

class CalendarAppBar extends StatelessWidget {
  const CalendarAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: DateFormat('EEE').format(DateTime.now()),
      leading: Icon(
        SFSymbols.calendar,
        size: 26,
        color: ColorsExt.grey2(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            SFSymbols.ellipsis,
            size: 18,
            color: ColorsExt.grey2(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}