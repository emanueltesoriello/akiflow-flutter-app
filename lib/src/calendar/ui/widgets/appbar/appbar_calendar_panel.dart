import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/calendar_utils.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_selected_day.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_today.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/viewed_month_cubit.dart';
import 'package:syncfusion_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class AppbarCalendarPanel extends StatefulWidget {
  final CalendarController calendarController;
  const AppbarCalendarPanel({
    Key? key,
    required this.calendarController,
  }) : super(key: key);

  @override
  State<AppbarCalendarPanel> createState() => _AppbarCalendarPanelState();
}

class _AppbarCalendarPanelState extends State<AppbarCalendarPanel> {
  int firstDayOfWeek = DateTime.monday;

  @override
  void initState() {
    AuthCubit authCubit = context.read<AuthCubit>();
    try {
      if (authCubit.state.user?.settings?["calendar"] != null) {
        List<dynamic> calendarSettings = authCubit.state.user?.settings?["calendar"];
        for (Map<String, dynamic> element in calendarSettings) {
          if (element['key'] == 'firstDayOfWeek') {
            var firstDayFromDb = element['value'];
            if (firstDayFromDb != null) {
              if (firstDayFromDb is String) {
                firstDayOfWeek = int.parse(firstDayFromDb);
              } else if (firstDayFromDb is int) {
                firstDayOfWeek = firstDayFromDb;
              }
            }
          }
        }
      }
    } catch (e) {
      print('ERROR could not read first day of week: $e');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<CalendarCubit, CalendarCubitState>(
          builder: (context, state) {
            DateTime now = DateTime.now().toLocal();
            return Column(
              children: [
                TableCalendar(
                  onCalendarCreated: (pageController) {},
                  startingDayOfWeek: CalendarUtils.computeFirstDayOfWeekForAppbar(firstDayOfWeek, context),
                  rowHeight: Dimension.todayCalendarMinHeight,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  calendarFormat: CalendarFormat.month,
                  sixWeekMonthsEnforced: true,
                  focusedDay: widget.calendarController.displayDate ?? now,
                  firstDay: now.subtract(const Duration(days: 365)),
                  lastDay: now.add(const Duration(days: 365)),
                  selectedDayPredicate: (day) {
                    return isSameDay(widget.calendarController.displayDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    widget.calendarController.displayDate = now.hour > 2
                        ? selectedDay.add(Duration(hours: now.hour - 2, minutes: now.minute))
                        : selectedDay;
                    context.read<CalendarCubit>().closePanel();
                  },
                  onPageChanged: (focusedDay) {
                    BlocProvider.of<ViewedMonthCubit>(context).updateViewedMonth(focusedDay.month);
                  },
                  headerVisible: false,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextFormatter: (date, locale) {
                      return DateFormat("E").format(date).substring(0, 1);
                    },
                    weekdayStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w600),
                    weekendStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w600),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return SizedBox(
                        height: 24,
                        child: Center(
                          child: Text(
                            DateFormat("d").format(day),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return SizedBox(height: 24, child: CalendarSelectedDay(day));
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return SizedBox(height: 24, child: CalendarToday(day));
                    },
                    outsideBuilder: (context, day, focused) {
                      return SizedBox(
                        height: 24,
                        child: Center(
                          child: Text(
                            DateFormat("d").format(day),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
