import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/create_task/ui/create_task_calendar.dart';
import 'package:mobile/features/create_task/ui/create_task_top_action_item.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';

class PlanModal extends StatefulWidget {
  final Function({required DateTime? date, required DateTime? datetime, required TaskStatusType statusType})
      onSelectDate;
  final Function() setForInbox;
  final Function() setForSomeday;
  final TaskStatusType initialStatusType;
  final DateTime initialDate;
  final DateTime? initialDatetime;

  const PlanModal({
    Key? key,
    required this.onSelectDate,
    required this.setForInbox,
    required this.setForSomeday,
    this.initialStatusType = TaskStatusType.planned,
    required this.initialDate,
    required this.initialDatetime,
  }) : super(key: key);

  @override
  State<PlanModal> createState() => _PlanModalState();
}

class _PlanModalState extends State<PlanModal> {
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime?> _selectedDatetime = ValueNotifier(null);
  final ValueNotifier<TaskStatusType> _selectedStatus = ValueNotifier(TaskStatusType.planned);

  @override
  void initState() {
    _selectedDate.value = widget.initialDate;
    _selectedDatetime.value = widget.initialDatetime;
    _selectedStatus.value = widget.initialStatusType;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Container(
                color: Theme.of(context).backgroundColor,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  child: Column(
                    children: [
                      _planType(),
                      _predefinedDate(context),
                      CreateTaskCalendar(
                        initialDate: _selectedDate.value,
                        initialDateTime: _selectedDatetime.value,
                        onConfirm: (DateTime date, DateTime? datetime) {
                          _selectedDate.value = date;
                          _selectedDatetime.value = datetime;
                          widget.onSelectDate(date: date, datetime: datetime, statusType: _selectedStatus.value);
                        },
                        onSelectTime: (TimeOfDay? datetime) {
                          _selectedDatetime.value = DateTime(
                            _selectedDate.value.year,
                            _selectedDate.value.month,
                            _selectedDate.value.day,
                            datetime?.hour ?? 10,
                            datetime?.minute ?? 0,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planType() {
    return ValueListenableBuilder(
      valueListenable: _selectedStatus,
      builder: (context, status, child) => SizedBox(
        height: 70,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CreateTaskTopActionItem(
                    text: t.addTask.plan,
                    color: ColorsExt.cyan25(context),
                    leadingIconAsset: "assets/images/icons/_common/calendar.svg",
                    active: status == TaskStatusType.planned,
                    onPressed: () {
                      _selectedStatus.value = TaskStatusType.planned;
                    },
                  ),
                  const SizedBox(width: 24),
                  CreateTaskTopActionItem(
                    text: t.addTask.snooze,
                    color: ColorsExt.pink30(context),
                    leadingIconAsset: "assets/images/icons/_common/clock.svg",
                    active: status == TaskStatusType.snoozed,
                    onPressed: () {
                      _selectedStatus.value = TaskStatusType.snoozed;
                    },
                  ),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).dividerColor,
              width: double.infinity,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _predefinedDate(BuildContext context) {
    DateTime now = DateTime.now();

    return ValueListenableBuilder(
      valueListenable: _selectedStatus,
      builder: (context, statusType, child) => ValueListenableBuilder(
          valueListenable: _selectedDatetime,
          builder: (context, DateTime? datetime, child) {
            bool useDateTime = statusType == TaskStatusType.planned && datetime != null;

            String time = useDateTime
                ? " - ${DateFormat.Hm().format(DateTime(now.year, now.month, now.day, datetime.hour, datetime.minute))}"
                : '';

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(children: [
                    Builder(
                      builder: (context) {
                        if (statusType == TaskStatusType.planned) {
                          return _predefinedDateItem(
                            context,
                            iconAsset: "assets/images/icons/_common/${DateFormat("dd").format(now)}_square.svg",
                            text: t.addTask.today,
                            trailingText: '${DateFormat("EEE").format(DateTime.now())}$time',
                            onPressed: () {
                              if (useDateTime) {
                                datetime = DateTime(_selectedDate.value.year, _selectedDate.value.month,
                                    _selectedDate.value.day, datetime!.hour, datetime!.minute);
                              }

                              widget.onSelectDate(
                                  date: _selectedDate.value, datetime: datetime, statusType: TaskStatusType.planned);

                              Navigator.pop(context);
                            },
                          );
                        } else {
                          DateTime laterToday = DateTime(now.year, now.month, now.day, now.hour);
                          DateTime laterTodayMore3Hours = DateTime(now.year, now.month, now.day, now.hour + 3);

                          return _predefinedDateItem(
                            context,
                            iconAsset: "assets/images/icons/_common/clock.svg",
                            text: t.addTask.laterToday,
                            trailingText: '${DateFormat("EEE HH:mm").format(laterToday)}$time',
                            onPressed: () {
                              widget.onSelectDate(
                                  date: laterToday, datetime: laterTodayMore3Hours, statusType: TaskStatusType.snoozed);
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 2),
                    _predefinedDateItem(
                      context,
                      iconAsset:
                          "assets/images/icons/_common/${DateFormat("dd").format(now.add(const Duration(days: 1)))}_square.svg",
                      text: t.addTask.tomorrow,
                      trailingText: '${DateFormat("EEE").format(now.add(const Duration(days: 1)))}$time',
                      onPressed: () {
                        DateTime tmw = now.add(const Duration(days: 1));

                        if (useDateTime) {
                          datetime = DateTime(tmw.year, tmw.month, tmw.day, datetime!.hour, datetime!.minute);
                        }

                        widget.onSelectDate(date: tmw, datetime: datetime, statusType: _selectedStatus.value);

                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 2),
                    Builder(builder: (context) {
                      DateTime nextMonday = now.add(Duration(days: 7 - now.weekday + 1));

                      return _predefinedDateItem(
                        context,
                        iconAsset: "assets/images/icons/_common/${DateFormat("dd").format(nextMonday)}_square.svg",
                        text: t.addTask.nextWeek,
                        trailingText: '${DateFormat("EEE").format(nextMonday)}$time',
                        onPressed: () {
                          if (useDateTime) {
                            datetime = DateTime(
                                nextMonday.year, nextMonday.month, nextMonday.day, datetime!.hour, datetime!.minute);
                          }

                          widget.onSelectDate(date: nextMonday, datetime: datetime, statusType: _selectedStatus.value);

                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 2),
                    ValueListenableBuilder(
                      valueListenable: _selectedStatus,
                      builder: (context, statusType, child) {
                        if (statusType == TaskStatusType.planned) {
                          return _predefinedDateItem(
                            context,
                            iconAsset: "assets/images/icons/_common/slash_circle.svg",
                            text: t.addTask.remove,
                            trailingText: t.bottomBar.inbox,
                            onPressed: () {
                              widget.setForInbox();
                              Navigator.pop(context);
                            },
                          );
                        } else {
                          return _predefinedDateItem(
                            context,
                            iconAsset: "assets/images/icons/_common/archivebox.svg",
                            text: t.task.someday,
                            trailingText: t.addTask.noDate,
                            onPressed: () {
                              widget.setForSomeday();
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                  ]),
                ),
                Container(
                  color: Theme.of(context).dividerColor,
                  width: double.infinity,
                  height: 1,
                )
              ],
            );
          }),
    );
  }

  Widget _predefinedDateItem(
    BuildContext context, {
    required String iconAsset,
    required String text,
    required String trailingText,
    required Function() onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 24,
              height: 24,
              color: ColorsExt.grey2(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey2(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      trailingText,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey3(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
