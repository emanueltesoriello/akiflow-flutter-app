import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/create_task/ui/create_task_calendar.dart';
import 'package:mobile/features/create_task/ui/create_task_top_action_item.dart';
import 'package:mobile/features/plan_modal/cubit/plan_modal_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';

class PlanModal extends StatelessWidget {
  final Function({required DateTime? date, required DateTime? datetime, required TaskStatusType statusType})
      onSelectDate;
  final Function() setForInbox;
  final Function() setForSomeday;
  final TaskStatusType? statusType;

  const PlanModal({
    Key? key,
    required this.onSelectDate,
    required this.setForInbox,
    required this.setForSomeday,
    this.statusType = TaskStatusType.planned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlanModalCubit(statusType!),
      child: _View(
        onSelectDate: onSelectDate,
        setForInbox: setForInbox,
        setForSomeday: setForSomeday,
      ),
    );
  }
}

class _View extends StatelessWidget {
  final Function({required DateTime date, required DateTime? datetime, required TaskStatusType statusType})
      onSelectDate;
  final Function() setForInbox;
  final Function() setForSomeday;

  final ValueNotifier<TimeOfDay?> _selectedTime = ValueNotifier(null);

  _View({
    Key? key,
    required this.onSelectDate,
    required this.setForInbox,
    required this.setForSomeday,
  }) : super(key: key);

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
                        initialDate: context.watch<PlanModalCubit>().state.selectedDate,
                        onConfirm: (DateTime date, DateTime? datetime) {
                          context.read<PlanModalCubit>().selectDate(date);

                          TaskStatusType statusType = context.read<PlanModalCubit>().state.statusType;
                          onSelectDate(date: date, datetime: datetime, statusType: statusType);
                        },
                        onSelectTime: (TimeOfDay? datetime) {
                          _selectedTime.value = datetime;
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
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: BlocBuilder<PlanModalCubit, PlanModalCubitState>(
        builder: (context, state) {
          return Column(
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
                      active: state.statusType == TaskStatusType.planned,
                      onPressed: () {
                        context.read<PlanModalCubit>().selectPlanType(TaskStatusType.planned);
                      },
                    ),
                    const SizedBox(width: 24),
                    CreateTaskTopActionItem(
                      text: t.addTask.snooze,
                      color: ColorsExt.pink30(context),
                      leadingIconAsset: "assets/images/icons/_common/clock.svg",
                      active: state.statusType == TaskStatusType.snoozed,
                      onPressed: () {
                        context.read<PlanModalCubit>().selectPlanType(TaskStatusType.snoozed);
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
          );
        },
      ),
    );
  }

  Widget _predefinedDate(BuildContext context) {
    DateTime now = DateTime.now();

    return ValueListenableBuilder(
        valueListenable: _selectedTime,
        builder: (context, TimeOfDay? timeOfDay, widget) {
          return BlocBuilder<PlanModalCubit, PlanModalCubitState>(
            builder: (context, state) {
              bool useDateTime = timeOfDay != null && state.statusType == TaskStatusType.planned;

              String time = useDateTime
                  ? " - ${DateFormat.Hm().format(DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute))}"
                  : '';

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(children: [
                      Builder(builder: (context) {
                        if (state.statusType == TaskStatusType.planned) {
                          return _predefinedDateItem(
                            context,
                            iconAsset: "assets/images/icons/_common/${DateFormat("dd").format(now)}_square.svg",
                            text: t.addTask.today,
                            trailingText: '${DateFormat("EEE").format(DateTime.now())}$time',
                            onPressed: () {
                              DateTime? datetime;
                              DateTime date = now;

                              if (useDateTime) {
                                datetime = DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
                              }

                              onSelectDate(date: date, datetime: datetime, statusType: TaskStatusType.planned);

                              Navigator.pop(context);
                            },
                          );
                        } else {
                          DateTime laterToday = DateTime(now.year, now.month, now.day, now.hour + 3);

                          return _predefinedDateItem(
                            context,
                            iconAsset: "assets/images/icons/_common/clock.svg",
                            text: t.addTask.laterToday,
                            trailingText: '${DateFormat("EEE HH:mm").format(laterToday)}$time',
                            onPressed: () {
                              onSelectDate(date: laterToday, datetime: null, statusType: TaskStatusType.snoozed);

                              Navigator.pop(context);
                            },
                          );
                        }
                      }),
                      const SizedBox(height: 2),
                      _predefinedDateItem(
                        context,
                        iconAsset:
                            "assets/images/icons/_common/${DateFormat("dd").format(now.add(const Duration(days: 1)))}_square.svg",
                        text: t.addTask.tomorrow,
                        trailingText: '${DateFormat("EEE").format(now.add(const Duration(days: 1)))}$time',
                        onPressed: () {
                          DateTime? datetime;
                          DateTime tmw = now.add(const Duration(days: 1));

                          if (useDateTime) {
                            datetime = DateTime(tmw.year, tmw.month, tmw.day, timeOfDay.hour, timeOfDay.minute);
                          }

                          onSelectDate(
                              date: tmw,
                              datetime: datetime,
                              statusType: context.read<PlanModalCubit>().state.statusType);

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
                            DateTime? datetime;

                            if (useDateTime) {
                              datetime = DateTime(
                                  nextMonday.year, nextMonday.month, nextMonday.day, timeOfDay.hour, timeOfDay.minute);
                            }

                            onSelectDate(
                                date: nextMonday,
                                datetime: datetime,
                                statusType: context.read<PlanModalCubit>().state.statusType);

                            Navigator.pop(context);
                          },
                        );
                      }),
                      const SizedBox(height: 2),
                      BlocBuilder<PlanModalCubit, PlanModalCubitState>(
                        builder: (context, state) {
                          if (state.statusType == TaskStatusType.planned) {
                            return _predefinedDateItem(
                              context,
                              iconAsset: "assets/images/icons/_common/slash_circle.svg",
                              text: t.addTask.remove,
                              trailingText: t.bottomBar.inbox,
                              onPressed: () {
                                setForInbox();
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
                                setForSomeday();
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
            },
          );
        });
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
