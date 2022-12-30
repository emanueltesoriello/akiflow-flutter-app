import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/settings/ui/widgets/button_selectable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

enum AddListType { addLabel, addFolder }

class CalendarSettingsModal extends StatelessWidget {
  const CalendarSettingsModal({
    Key? key,
    required this.calendarController,
  }) : super(key: key);
  final CalendarController calendarController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: ScrollConfiguration(
        behavior: NoScrollBehav(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const ScrollChip(),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 10),
                    child: Text(
                      'CALENDAR VIEW',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                    ),
                  ),
                  BlocBuilder<CalendarCubit, CalendarCubitState>(
                    builder: (context, state) {
                      return ButtonSelectable(
                        title: 'Agenda',
                        leading: SizedBox(
                          height: 22,
                          width: 22,
                          child: SvgPicture.asset(
                            "assets/images/icons/_common/rectangle_grid_1x2.svg",
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                        trailing: const SizedBox(),
                        selected: calendarController.view == CalendarView.schedule,
                        onPressed: () {
                          context.read<CalendarCubit>().changeCalendarView(CalendarView.schedule);
                          calendarController.view = CalendarView.schedule;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  BlocBuilder<CalendarCubit, CalendarCubitState>(
                    builder: (context, state) {
                      return ButtonSelectable(
                        title: '1 Day',
                        leading: SizedBox(
                          height: 22,
                          width: 22,
                          child: SvgPicture.asset(
                            "assets/images/icons/_common/01_square.svg",
                            color: ColorsExt.grey1(context),
                          ),
                        ),
                        trailing: const SizedBox(),
                        selected: calendarController.view == CalendarView.day,
                        onPressed: () {
                          context.read<CalendarCubit>().changeCalendarView(CalendarView.day);
                          calendarController.view = CalendarView.day;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  BlocBuilder<CalendarCubit, CalendarCubitState>(
                    builder: (context, state) {
                      return ButtonSelectable(
                        title: '3 Days',
                        leading: SizedBox(
                          height: 22,
                          width: 22,
                          child: SvgPicture.asset(
                            "assets/images/icons/_common/03_square.svg",
                            color: ColorsExt.grey3(context),
                          ),
                        ),
                        trailing: Text(
                          t.comingSoon,
                          style: TextStyle(
                            fontSize: 17,
                            color: ColorsExt.grey3(context),
                          ),
                        ),
                        selected: calendarController.view == CalendarView.workWeek,
                        onPressed: () {
                          // context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                          // calendarController.view = CalendarView.workWeek;
                          // Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  BlocBuilder<CalendarCubit, CalendarCubitState>(
                    builder: (context, state) {
                      return ButtonSelectable(
                        title: 'Week',
                        leading: SizedBox(
                          height: 22,
                          width: 22,
                          child: SvgPicture.asset(
                            "assets/images/icons/_common/07_square.svg",
                            color: ColorsExt.grey1(context),
                          ),
                        ),
                        trailing: const SizedBox(),
                        selected: calendarController.view == CalendarView.week,
                        onPressed: () {
                          context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                          calendarController.view = CalendarView.week;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  BlocBuilder<CalendarCubit, CalendarCubitState>(
                    builder: (context, state) {
                      return ButtonSelectable(
                        title: 'Month',
                        leading: SizedBox(
                          height: 22,
                          width: 22,
                          child: SvgPicture.asset(
                            "assets/images/icons/_common/30_square.svg",
                            color: ColorsExt.grey1(context),
                          ),
                        ),
                        trailing: const SizedBox(),
                        selected: calendarController.view == CalendarView.month,
                        onPressed: () {
                          context.read<CalendarCubit>().changeCalendarView(CalendarView.month);
                          calendarController.view = CalendarView.month;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Separator(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 10),
                    child: Text(
                      'Hide Weekends',
                      style: TextStyle(
                        fontSize: 17,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                  ),
                  const Separator(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 10),
                    child: Text(
                      'CALENDARS',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
