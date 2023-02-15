import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_selected_day.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_today.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class AppbarCalendarPanel extends StatelessWidget {
  final CalendarController calendarController;
  const AppbarCalendarPanel({
    Key? key,
    required this.calendarController,
  }) : super(key: key);

//   @override
//   State<AppbarCalendarPanel> createState() => _AppbarCalendarPanelState();
// }

// class _AppbarCalendarPanelState extends State<AppbarCalendarPanel> {
//   PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(color: ColorsExt.background(context), height: 12),
        BlocBuilder<CalendarCubit, CalendarCubitState>(
          builder: (context, state) {
            DateTime now = DateTime.now();
            int firstDayOfWeek = DateTime.monday;
            if (context.read<AuthCubit>().state.user?.settings?["calendar"] != null &&
                context.read<AuthCubit>().state.user?.settings?["calendar"]["firstDayOfWeek"] != null) {
              firstDayOfWeek = context.read<AuthCubit>().state.user?.settings?["calendar"]["firstDayOfWeek"];
            }
            return Column(
              children: [
                TableCalendar(
                  startingDayOfWeek:
                      firstDayOfWeek == -1 || firstDayOfWeek == 1 ? StartingDayOfWeek.monday : StartingDayOfWeek.sunday,
                  onPageChanged: (date) {
                    //context.read<CalendarCubit>().setPanelMonth(date.month);
                  },
                  rowHeight: todayCalendarMinHeight,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  calendarFormat: CalendarFormat.month,
                  sixWeekMonthsEnforced: true,
                  focusedDay: now,
                  firstDay: now.subtract(const Duration(days: 365)),
                  lastDay: now.add(const Duration(days: 365)),
                  selectedDayPredicate: (day) {
                    return isSameDay(calendarController.displayDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    context.read<CalendarCubit>().changeCalendarView(CalendarView.day);
                    calendarController.displayDate = selectedDay.add(const Duration(hours: 8));
                  },
                  headerVisible: false,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextFormatter: (date, locale) {
                      return DateFormat("E").format(date).substring(0, 1);
                    },
                    weekdayStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorsExt.grey3(context),
                    ),
                    weekendStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorsExt.grey3(context),
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return SizedBox(
                        height: 24,
                        child: Center(
                          child: Text(
                            DateFormat("d").format(day),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ),
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey3(context),
                            ),
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
