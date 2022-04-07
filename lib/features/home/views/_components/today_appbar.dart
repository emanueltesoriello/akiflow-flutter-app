import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/app_bar.dart';
import 'package:mobile/style/colors.dart';

class TodayAppBar extends StatelessWidget {
  const TodayAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: DateFormat('EEE, dd').format(DateTime.now()),
      actions: [
        IconButton(
          icon: Icon(
            SFSymbols.ellipsis,
            size: 18,
            color: ColorsExt.textGrey3(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
