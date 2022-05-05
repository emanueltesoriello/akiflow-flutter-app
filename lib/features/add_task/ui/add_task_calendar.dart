import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class AddTaskCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const AddTaskCalendar({
    Key? key,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<AddTaskCalendar> createState() => _AddTaskCalendarState();
}

class _AddTaskCalendarState extends State<AddTaskCalendar> {
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Column(
      children: [
        BlocBuilder<EditTaskCubit, EditTaskCubitState>(
          builder: (context, state) {
            return TableCalendar(
              onCalendarCreated: (pageController) {
                _pageController = pageController;
              },
              focusedDay: state.selectedDate ?? now,
              firstDay: now.subtract(const Duration(days: 365)),
              lastDay: now.add(const Duration(days: 365)),
              selectedDayPredicate: (day) {
                return isSameDay(state.selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                widget.onDateSelected(selectedDay);
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
                  return Center(
                    child: Text(
                      DateFormat("d").format(day),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.akiflow(context),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        DateFormat("d").format(day),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.background(context),
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
                            _pageController?.jumpToPage(
                                (_pageController!.page! - 1).toInt());
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
                            _pageController?.jumpToPage(
                                (_pageController!.page! + 1).toInt());
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
        Container(
          color: Theme.of(context).dividerColor,
          width: double.infinity,
          height: 1,
        ),
        InkWell(
          onTap: () {
            DateTime? selectedDate =
                context.read<EditTaskCubit>().state.selectedDate;

            if (selectedDate != null) {
              context.read<EditTaskCubit>().planFor(selectedDate);
              Navigator.pop(context);
            }
          },
          child: SizedBox(
            height: 60,
            child: Center(
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
        ),
        Container(
          color: Theme.of(context).dividerColor,
          width: double.infinity,
          height: 1,
        ),
      ],
    );
  }
}
