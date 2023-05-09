import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/time_picker_utils.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/date_display.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_selected_day.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_today.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/recurrence/recurrence_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateTaskCalendar extends StatefulWidget {
  final Function(DateTime, DateTime?) onConfirm;
  final DateTime initialDate;
  final DateTime? initialDateTime;
  final Function(TimeOfDay? time)? onSelectTime;
  final bool showTime;
  final bool showRepeat;
  final int defaultTimeHour;

  const CreateTaskCalendar({
    Key? key,
    required this.onConfirm,
    required this.initialDate,
    required this.initialDateTime,
    this.onSelectTime,
    this.showTime = true,
    this.showRepeat = true,
    required this.defaultTimeHour,
  }) : super(key: key);

  @override
  State<CreateTaskCalendar> createState() => _CreateTaskCalendarState();
}

class _CreateTaskCalendarState extends State<CreateTaskCalendar> {
  PageController? _pageController;

  final ValueNotifier<DateTime> _selectedDay;
  final ValueNotifier<TimeOfDay?> _selectedDatetime;

  _CreateTaskCalendarState()
      : _selectedDay = ValueNotifier(DateTime.now()),
        _selectedDatetime = ValueNotifier(null);

  @override
  void initState() {
    _selectedDay.value = widget.initialDate;

    if (widget.initialDateTime != null) {
      _selectedDatetime.value = TimeOfDay.fromDateTime(widget.initialDateTime!);
    } else {
      _selectedDatetime.value = null;
    }
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
            rowHeight: 40,
            focusedDay: selectedDate,
            firstDay: now.subtract(const Duration(days: 365)),
            lastDay: now.add(const Duration(days: 365)),
            sixWeekMonthsEnforced: true,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              _selectedDay.value = (selectedDay);

              if (!widget.showTime) {
                widget.onConfirm(_selectedDay.value, null);
                Navigator.pop(context);
              }
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
              weekdayStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorsExt.grey3(context),
                  ),
              weekendStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                            width: Dimension.chevronIconSize,
                            height: Dimension.chevronIconSize,
                            color: ColorsExt.grey3(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimension.padding),
                      DateDisplay(date: day),
                      const SizedBox(width: Dimension.padding),
                      InkWell(
                        onTap: () {
                          _pageController?.jumpToPage((_pageController!.page! + 1).toInt());
                        },
                        child: SvgPicture.asset(
                          Assets.images.icons.common.chevronRightSVG,
                          width: Dimension.chevronIconSize,
                          height: Dimension.chevronIconSize,
                          color: ColorsExt.grey3(context),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Dimension.padding),
          Visibility(
            visible: widget.showTime,
            replacement: const SizedBox(),
            child: Column(
              children: [
                const Separator(),
                SizedBox(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _selectedDatetime,
                              builder: (context, TimeOfDay? selectedTime, child) {
                                return TextButton(
                                    onPressed: () {
                                      TimeOfDay initialTime =
                                          _selectedDatetime.value ?? TimeOfDay(hour: widget.defaultTimeHour, minute: 0);
                                      TimePickerUtils.pick(
                                        context,
                                        initialTime: initialTime,
                                        onTimeSelected: (selected) {
                                          _selectedDatetime.value = selected;

                                          if (widget.onSelectTime != null) {
                                            widget.onSelectTime!(_selectedDatetime.value);
                                          }
                                        },
                                      );
                                    },
                                    style: const ButtonStyle(
                                      alignment: Alignment.centerLeft,
                                    ),
                                    child: Text(
                                      selectedTime == null
                                          ? t.addTask.addTime
                                          : DateFormat("HH:mm").format(DateTime(selectedDate.year, selectedDate.month,
                                              selectedDate.day, selectedTime.hour, selectedTime.minute)),
                                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: ColorsExt.grey2(context),
                                          ),
                                    ));
                              },
                            ),
                            const SizedBox(width: Dimension.padding),
                            if (widget.showRepeat)
                              InkWell(
                                onTap: () {
                                  Task updatedTask = context.read<EditTaskCubit>().state.updatedTask;
                                  var cubit = context.read<EditTaskCubit>()..attachTask(updatedTask);
                                  cubit.recurrenceTap();

                                  showCupertinoModalBottomSheet(
                                    context: context,
                                    builder: (context) => RecurrenceModal(
                                      onChange: (RecurrenceRule? rule) {
                                        cubit.setRecurrence(rule);
                                      },
                                      selectedRecurrence: updatedTask.recurrenceComputed,
                                      rule: updatedTask.ruleFromStringList,
                                      taskDatetime: updatedTask.datetime != null
                                          ? DateTime.parse(updatedTask.datetime!)
                                          : DateTime.parse(updatedTask.date!),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Assets.images.icons.common.repeatSVG,
                                      width: Dimension.defaultIconSize,
                                      height: Dimension.defaultIconSize,
                                      color: context.read<EditTaskCubit>().state.updatedTask.recurrence != null
                                          ? ColorsExt.grey2(context)
                                          : ColorsExt.grey3(context),
                                    ),
                                    const SizedBox(width: Dimension.paddingS),
                                    Text(
                                      t.editTask.repeat,
                                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: context.watch<EditTaskCubit>().state.updatedTask.recurrence != null
                                                ? ColorsExt.grey2(context)
                                                : ColorsExt.grey3(context),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: Dimension.padding),
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
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
                            icon: SvgPicture.asset(Assets.images.icons.common.checkmarkSVG,
                                width: Dimension.chevronIconSize,
                                height: Dimension.chevronIconSize,
                                color: ColorsExt.akiflow(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Separator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
