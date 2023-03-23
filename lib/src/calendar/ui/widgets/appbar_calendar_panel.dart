import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/date_display.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_selected_day.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_today.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
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
  PageController? _pageController;
  int firstDayOfWeek = DateTime.monday;

  @override
  void initState() {
    if (context.read<AuthCubit>().state.user?.settings?["calendar"] != null &&
        context.read<AuthCubit>().state.user?.settings?["calendar"]["firstDayOfWeek"] != null) {
      var firstDayFromDb = context.read<AuthCubit>().state.user?.settings?["calendar"]["firstDayOfWeek"];
      if (firstDayFromDb is String) {
        firstDayOfWeek = int.parse(firstDayFromDb);
      } else if (firstDayFromDb is int) {
        firstDayOfWeek = firstDayFromDb;
      }
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
                  onCalendarCreated: (pageController) {
                    _pageController = pageController;
                  },
                  startingDayOfWeek: firstDayOfWeek == -1 || firstDayOfWeek == DateTime.monday
                      ? StartingDayOfWeek.monday
                      : StartingDayOfWeek.sunday,
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
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                  ),
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
                    headerTitleBuilder: (context, date) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
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
                            DateDisplay(date: date),
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
