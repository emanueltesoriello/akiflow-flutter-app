import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/calendar/calendar_selected_day.dart';
import 'package:mobile/components/calendar/calendar_today.dart';
import 'package:mobile/style/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class AddTaskCalendar extends StatefulWidget {
  final Function(DateTime, DateTime?) onConfirm;
  final DateTime? initialDate;

  const AddTaskCalendar({
    Key? key,
    required this.onConfirm,
    required this.initialDate,
  }) : super(key: key);

  @override
  State<AddTaskCalendar> createState() => _AddTaskCalendarState();
}

class _AddTaskCalendarState extends State<AddTaskCalendar> {
  PageController? _pageController;

  final ValueNotifier<DateTime> _selectedDay;
  final ValueNotifier<TimeOfDay?> _selectedDatetime;

  _AddTaskCalendarState()
      : _selectedDay = ValueNotifier(DateTime.now()),
        _selectedDatetime = ValueNotifier(null);

  @override
  void initState() {
    _selectedDay.value = widget.initialDate ?? DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return ValueListenableBuilder<DateTime>(
      valueListenable: _selectedDay,
      builder: (context, selectedDate, child) => Column(
        children: [
          TableCalendar(
            onCalendarCreated: (pageController) {
              _pageController = pageController;
            },
            focusedDay: selectedDate,
            firstDay: now.subtract(const Duration(days: 365)),
            lastDay: now.add(const Duration(days: 365)),
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              _selectedDay.value = (selectedDay);
            },
            headerStyle: const HeaderStyle(
              leftChevronVisible: false,
              rightChevronVisible: false,
              formatButtonVisible: false,
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
          ),
          Container(
            color: Theme.of(context).dividerColor,
            width: double.infinity,
            height: 1,
          ),
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        TimeOfDay time = TimeOfDay.fromDateTime(selectedDate);
                        _selectedDatetime.value = await showTimePicker(context: context, initialTime: time);
                      },
                      child: Text(
                        t.addTask.addTime,
                        style: TextStyle(
                          fontSize: 15,
                          color: ColorsExt.grey2(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime date = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                      );

                      DateTime? datetime;

                      if (_selectedDatetime.value != null) {
                        datetime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          _selectedDatetime.value!.hour,
                          _selectedDatetime.value!.minute,
                        );
                      }

                      widget.onConfirm(date, datetime);

                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset("assets/images/icons/_common/checkmark.svg",
                        width: 24, height: 24, color: ColorsExt.akiflow(context)),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).dividerColor,
            width: double.infinity,
            height: 1,
          ),
        ],
      ),
    );
  }
}
