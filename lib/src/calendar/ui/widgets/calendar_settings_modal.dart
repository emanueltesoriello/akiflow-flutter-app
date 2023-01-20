import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/widgets/calendar_settings_item.dart';
import 'package:mobile/src/settings/ui/widgets/button_selectable.dart';
import 'package:models/calendar/calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarSettingsModal extends StatelessWidget {
  const CalendarSettingsModal({
    Key? key,
    required this.calendarController,
  }) : super(key: key);
  final CalendarController calendarController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        bool isThreeDays = context.read<CalendarCubit>().state.isCalendarThreeDays;
        bool isWeekendHidden = context.read<CalendarCubit>().state.isCalendarWeekendHidden;
        List<Calendar> calendars = context.watch<CalendarCubit>().state.calendars;

        List<Calendar> primaryCalendars = calendars.where((calendar) => calendar.primary ?? false == true).toList();

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
                      ButtonSelectable(
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
                        selected: calendarController.view == CalendarView.schedule && !isThreeDays,
                        onPressed: () {
                          context.read<CalendarCubit>().setCalendarViewThreeDays(false);
                          context.read<CalendarCubit>().changeCalendarView(CalendarView.schedule);
                          calendarController.view = CalendarView.schedule;
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
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
                        selected: calendarController.view == CalendarView.day && !isThreeDays,
                        onPressed: () {
                          context.read<CalendarCubit>().setCalendarViewThreeDays(false);
                          context.read<CalendarCubit>().changeCalendarView(CalendarView.day);
                          calendarController.view = CalendarView.day;
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
                        title: '3 Days',
                        leading: SizedBox(
                          height: 22,
                          width: 22,
                          child: SvgPicture.asset(
                            "assets/images/icons/_common/03_square.svg",
                            color: ColorsExt.grey1(context),
                          ),
                        ),
                        trailing: const SizedBox(),
                        selected: isThreeDays,
                        onPressed: () {
                          context.read<CalendarCubit>().setCalendarViewThreeDays(true);
                          if (isWeekendHidden) {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                            calendarController.view = CalendarView.workWeek;
                          } else {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                            calendarController.view = CalendarView.week;
                          }
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
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
                        selected: (calendarController.view == CalendarView.week ||
                                calendarController.view == CalendarView.workWeek) &&
                            !isThreeDays,
                        onPressed: () {
                          if (isWeekendHidden) {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                            calendarController.view = CalendarView.workWeek;
                          } else {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                            calendarController.view = CalendarView.week;
                          }
                          context.read<CalendarCubit>().setCalendarViewThreeDays(false);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
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
                        selected: calendarController.view == CalendarView.month && !isThreeDays,
                        onPressed: () {
                          context.read<CalendarCubit>().setCalendarViewThreeDays(false);
                          context.read<CalendarCubit>().changeCalendarView(CalendarView.month);
                          calendarController.view = CalendarView.month;
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      const Separator(),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hide Weekends',
                              style: TextStyle(
                                fontSize: 17,
                                color: ColorsExt.grey2(context),
                              ),
                            ),
                            FlutterSwitch(
                              width: 48,
                              height: 24,
                              toggleSize: 20,
                              activeColor: ColorsExt.akiflow(context),
                              inactiveColor: ColorsExt.grey5(context),
                              value: isWeekendHidden,
                              borderRadius: 24,
                              padding: 2,
                              onToggle: (value) {
                                context.read<CalendarCubit>().setCalendarWeekendHidden(value);
                                if (calendarController.view == CalendarView.week ||
                                    calendarController.view == CalendarView.workWeek) {
                                  if (value) {
                                    context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                                    calendarController.view = CalendarView.workWeek;
                                  } else {
                                    context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                                    calendarController.view = CalendarView.week;
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const Separator(),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8.0),
                        child: Text(
                          'CALENDARS',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: primaryCalendars.length,
                        itemBuilder: (context, index) {
                          return CalendarItem(
                            title: primaryCalendars[index].title!,
                            calendars: calendars
                                .where((calendar) => calendar.originAccountId == calendars[index].originAccountId)
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
