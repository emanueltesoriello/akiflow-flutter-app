import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/calendar_utils.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_selected_day.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_today.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/viewed_month_cubit.dart';
import 'package:table_calendar/table_calendar.dart';

class TodayAppBarCalendar extends StatefulWidget {
  final CalendarFormatState? calendarFormat;

  const TodayAppBarCalendar({Key? key, this.calendarFormat}) : super(key: key);

  @override
  State<TodayAppBarCalendar> createState() => _TodayAppBarCalendarState();
}

class _TodayAppBarCalendarState extends State<TodayAppBarCalendar> {
  int firstDayOfWeek = DateTime.monday;
  DateTime now = DateTime.now();
  double size = Dimension.calendarElementHeight;
  late TextStyle textStyle;

  @override
  void initState() {
    AuthCubit authCubit = context.read<AuthCubit>();
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: ColorsExt.grey600(context),
          fontWeight: FontWeight.w500,
          overflow: TextOverflow.ellipsis,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: Dimension.paddingS),
        BlocBuilder<TodayCubit, TodayCubitState>(
          builder: (context, state) {
            return Column(
              children: [
                TableCalendar(
                  startingDayOfWeek: CalendarUtils.computeFirstDayOfWeekForAppbar(firstDayOfWeek, context),
                  onPageChanged: (page) {
                    BlocProvider.of<ViewedMonthCubit>(context).updateViewedMonth(page.month);
                  },
                  rowHeight: Dimension.todayCalendarMinHeight,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  calendarFormat: widget.calendarFormat != null
                      ? (widget.calendarFormat == CalendarFormatState.week ? CalendarFormat.week : CalendarFormat.month)
                      : (state.calendarFormat == CalendarFormatState.week ? CalendarFormat.week : CalendarFormat.month),
                  sixWeekMonthsEnforced: true,
                  focusedDay: state.selectedDate,
                  firstDay: now.subtract(const Duration(days: 365)),
                  lastDay: now.add(const Duration(days: 365)),
                  selectedDayPredicate: (day) {
                    return isSameDay(state.selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    context.read<TodayCubit>().onDateSelected(selectedDay);
                  },
                  headerVisible: false,
                  daysOfWeekStyle: DaysOfWeekStyle(
                      dowTextFormatter: (date, locale) {
                        return DateFormat("E").format(date).substring(0, 1);
                      },
                      weekdayStyle: textStyle,
                      weekendStyle: textStyle),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return SizedBox(
                        height: size,
                        child: Center(
                          child: Text(
                            DateFormat("d").format(day),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: ColorsExt.grey800(context),
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return SizedBox(height: size, child: CalendarSelectedDay(day));
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return SizedBox(height: size, child: CalendarToday(day));
                    },
                    outsideBuilder: (context, day, focused) {
                      return SizedBox(
                        height: size,
                        child: Center(
                          child: Text(DateFormat("d").format(day), style: textStyle),
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
