import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/calendar/ui/widgets/calendar_settings_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CalendarController calendarController;

  const CalendarAppBar({
    Key? key,
    required this.calendarController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: t.bottomBar.calendar,
      leading: SvgPicture.asset(
        "assets/images/icons/_common/calendar.svg",
        width: 26,
        height: 26,
      ),
      actions: [
        TextButton(
          onPressed: () {
            calendarController.displayDate = DateTime.now();
          },
          child: Text(
            t.bottomBar.today,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsExt.akiflow(context),
            ),
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/icons/_common/ellipsis.svg",
            width: 24,
            height: 24,
            color: ColorsExt.grey3(context),
          ),
          onPressed: () => showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => CalendarSettingsModal(calendarController: calendarController),
          ),
        )
      ],
      showSyncButton: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
