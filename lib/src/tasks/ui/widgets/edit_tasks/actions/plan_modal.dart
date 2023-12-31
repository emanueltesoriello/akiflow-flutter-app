import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_calendar.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_top_action_item.dart';
import 'package:models/extensions/user_ext.dart';

class PlanModal extends StatefulWidget {
  final Function({required DateTime? date, required DateTime? datetime, required TaskStatusType statusType})
      onSelectDate;
  final Function() setForInbox;
  final Function() setForSomeday;
  final TaskStatusType initialHeaderStatusType;
  final TaskStatusType taskStatusType;
  final DateTime initialDate;
  final DateTime? initialDatetime;

  const PlanModal({
    Key? key,
    required this.onSelectDate,
    required this.setForInbox,
    required this.setForSomeday,
    this.initialHeaderStatusType = TaskStatusType.planned,
    required this.initialDate,
    required this.initialDatetime,
    required this.taskStatusType,
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
    _selectedStatus.value = widget.initialHeaderStatusType;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimension.radiusM),
                topRight: Radius.circular(Dimension.radiusM),
              ),
            ),
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
                      if (_selectedStatus.value == TaskStatusType.snoozed && _selectedDatetime.value == null) {
                        int defaultHour = context.read<AuthCubit>().state.user!.defaultHour;

                        datetime = DateTime(date.year, date.month, date.day, defaultHour, 0);
                      }

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
                    defaultTimeHour: () {
                      try {
                        return context.watch<AuthCubit>().state.user!.defaultHour;
                      } catch (_) {
                        return 8;
                      }
                    }(),
                  ),
                  const SizedBox(height: Dimension.padding),
                ],
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
                    color: ColorsExt.grey5(context),
                    leadingIconAsset: Assets.images.icons.common.calendarSVG,
                    active: status == TaskStatusType.planned,
                    onPressed: () {
                      _selectedStatus.value = TaskStatusType.planned;
                    },
                  ),
                  const SizedBox(width: 24),
                  CreateTaskTopActionItem(
                    text: t.addTask.snooze,
                    color: ColorsExt.pink30(context),
                    leadingIconAsset: Assets.images.icons.common.clockSVG,
                    active: status == TaskStatusType.snoozed,
                    onPressed: () {
                      _selectedStatus.value = TaskStatusType.snoozed;
                    },
                  ),
                ],
              ),
            ),
            const Separator(),
          ],
        ),
      ),
    );
  }

  Widget _predefinedDate(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _selectedStatus,
      builder: (context, statusType, child) => ValueListenableBuilder(
          valueListenable: _selectedDatetime,
          builder: (context, DateTime? datetime, child) {
            bool useDateTime = statusType == TaskStatusType.snoozed || datetime != null;

            String text;

            if (useDateTime) {
              int defaultTimeHour = context.watch<AuthCubit>().state.user?.defaultHour ?? 0;

              datetime ??= DateTime(
                  _selectedDate.value.year, _selectedDate.value.month, _selectedDate.value.day, defaultTimeHour, 0);

              text = " - ${DateFormat("HH:mm").format(datetime)}";
            } else {
              text = "";
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(children: [
                    Builder(
                      builder: (context) {
                        DateTime now = DateTime.now();

                        if (statusType == TaskStatusType.planned) {
                          return _predefinedDateItem(
                            context,
                            iconAsset: "assets/images/icons/_common/${DateFormat("dd").format(now)}_square.svg",
                            text: t.addTask.today,
                            trailingText: '${DateFormat("EEE").format(DateTime.now())}$text',
                            onPressed: () {
                              DateTime now = DateTime.now();

                              if (useDateTime) {
                                datetime = DateTime(now.year, now.month, now.day, datetime!.hour, datetime!.minute);
                              }

                              widget.onSelectDate(date: now, datetime: datetime, statusType: TaskStatusType.planned);

                              Navigator.pop(context);
                            },
                          );
                        } else {
                          DateTime laterTodayMore3Hours =
                              DateTime(now.year, now.month, now.day, now.hour + 3).toLocal();

                          return _predefinedDateItem(
                            context,
                            iconAsset: Assets.images.icons.common.clockSVG,
                            text: t.addTask.laterToday,
                            trailingText:
                                '${DateFormat("EEE").format(laterTodayMore3Hours)} - ${DateFormat("HH:mm").format(laterTodayMore3Hours)}',
                            onPressed: () {
                              widget.onSelectDate(
                                  date: laterTodayMore3Hours,
                                  datetime: laterTodayMore3Hours,
                                  statusType: TaskStatusType.snoozed);
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 2),
                    Builder(builder: (context) {
                      DateTime now = DateTime.now();

                      return _predefinedDateItem(
                        context,
                        iconAsset:
                            "assets/images/icons/_common/${DateFormat("dd").format(now.add(const Duration(days: 1)))}_square.svg",
                        text: t.addTask.tomorrow,
                        trailingText: '${DateFormat("EEE").format(now.add(const Duration(days: 1)))}$text',
                        onPressed: () {
                          DateTime tmw = now.add(const Duration(days: 1));

                          if (useDateTime) {
                            datetime = DateTime(tmw.year, tmw.month, tmw.day, datetime!.hour, datetime!.minute);
                          }

                          widget.onSelectDate(date: tmw, datetime: datetime, statusType: _selectedStatus.value);

                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 2),
                    Builder(builder: (context) {
                      DateTime now = DateTime.now();

                      DateTime nextMonday = now.add(Duration(days: 7 - now.weekday + 1));

                      return _predefinedDateItem(
                        context,
                        iconAsset: "assets/images/icons/_common/${DateFormat("dd").format(nextMonday)}_square.svg",
                        text: t.addTask.nextWeek,
                        trailingText: '${DateFormat("EEE").format(nextMonday)}$text',
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
                          DateTime now = DateTime.now();

                          DateTime nextWeekend = now.add(Duration(days: (6 - now.weekday) % DateTime.daysPerWeek));

                          if (widget.taskStatusType == TaskStatusType.inbox) {
                            return _predefinedDateItem(
                              context,
                              iconAsset:
                                  "assets/images/icons/_common/${DateFormat("dd").format(nextWeekend)}_square.svg",
                              text: t.addTask.nextWeekend,
                              trailingText: '${DateFormat("EEE").format(nextWeekend)}$text',
                              onPressed: () {
                                if (useDateTime) {
                                  datetime = DateTime(nextWeekend.year, nextWeekend.month, nextWeekend.day,
                                      datetime!.hour, datetime!.minute);
                                }

                                widget.onSelectDate(
                                    date: nextWeekend, datetime: datetime, statusType: _selectedStatus.value);

                                Navigator.pop(context);
                              },
                            );
                          }

                          return _predefinedDateItem(
                            context,
                            iconAsset: Assets.images.icons.common.slashCircleSVG,
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
                            iconAsset: Assets.images.icons.common.archiveboxSVG,
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
                const Separator(),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
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
