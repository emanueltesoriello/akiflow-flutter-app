import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/date_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/date_display.dart';
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
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(color: ColorsExt.background(context), height: 12),
        BlocBuilder<TodayCubit, TodayCubitState>(
          builder: (context, state) {
            DateTime now = DateTime.now();

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Text(
                        DateFormat("E").format(now.next(i)).substring(0, 1),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorsExt.grey3(context),
                        ),
                      )
                  ],
                ),
                TableCalendar(
                  onPageChanged: (page) {
                    BlocProvider.of<ViewedMonthCubit>(context).updateViewedMonth(page.month);
                  },
                  rowHeight: todayCalendarMinHeight,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  daysOfWeekVisible: false,
                  calendarFormat: widget.calendarFormat != null
                      ? (widget.calendarFormat == CalendarFormatState.week ? CalendarFormat.week : CalendarFormat.month)
                      : (state.calendarFormat == CalendarFormatState.week ? CalendarFormat.week : CalendarFormat.month),
                  onCalendarCreated: (pageController) {
                    _pageController = pageController;
                  },
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
                                  Assets.images.icons.common.chevronRightSVG,
                                  width: 20,
                                  height: 20,
                                  color: ColorsExt.grey2(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                _pageController?.jumpToPage((_pageController!.page! + 1).toInt());
                              },
                              child: SvgPicture.asset(
                                Assets.images.icons.common.chevronRightSVG,
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
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
