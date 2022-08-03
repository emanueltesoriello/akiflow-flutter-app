import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';

import '../../../components/base/app_bar.dart';
import 'home_view_placeholder.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _View();
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComp(
          title: t.bottomBar.calendar,
          leading: SvgPicture.asset(
            "assets/images/icons/_common/calendar.svg",
            width: 26,
            height: 26,
          ),
          showSyncButton: true,
        ),
        body: const HomeViewPlaceholder());
  }
}
