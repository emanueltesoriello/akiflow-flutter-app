import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/calendar/calendar_selected_day.dart';
import 'package:mobile/components/calendar/calendar_today.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class TodayAppBarCalendar extends StatefulWidget {
  const TodayAppBarCalendar({Key? key}) : super(key: key);

  @override
  State<TodayAppBarCalendar> createState() => _TodayAppBarCalendarState();
}

class _TodayAppBarCalendarState extends State<TodayAppBarCalendar> {
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(useMaterial3: false),
      child: Material(
        elevation: 4,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.3),
        color: ColorsExt.background(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(color: ColorsExt.background(context), height: 12),
            BlocBuilder<TodayCubit, TodayCubitState>(
              builder: (context, state) {
                DateTime now = DateTime.now();

                return TableCalendar(
                  availableGestures: AvailableGestures.horizontalSwipe,
                  calendarFormat:
                      state.calendarFormat == CalendarFormatState.week ? CalendarFormat.week : CalendarFormat.month,
                  onCalendarCreated: (pageController) {
                    _pageController = pageController;
                  },
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
                      return Center(
                        child: Text(
                          DateFormat("d").format(day),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return CalendarSelectedDay(day);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return CalendarToday(day);
                    },
                    headerTitleBuilder: (context, day) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                _pageController?.jumpToPage((_pageController!.page! - 1).toInt());
                              },
                              child: RotatedBox(
                                quarterTurns: 2,
                                child: SvgPicture.asset(
                                  "assets/images/icons/_common/chevron_right.svg",
                                  width: 20,
                                  height: 20,
                                  color: ColorsExt.grey2(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 100),
                                child: Text(
                                  DateFormat("MMMM").format(day),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: ColorsExt.grey2(context),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                _pageController?.jumpToPage((_pageController!.page! + 1).toInt());
                              },
                              child: SvgPicture.asset(
                                "assets/images/icons/_common/chevron_right.svg",
                                width: 20,
                                height: 20,
                                color: ColorsExt.grey2(context),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
