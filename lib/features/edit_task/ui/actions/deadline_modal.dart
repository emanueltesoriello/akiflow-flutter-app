import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/components/base/separator.dart';
import 'package:mobile/features/add_task/ui/add_task_calendar.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';

class DeadlineModal extends StatefulWidget {
  const DeadlineModal({
    Key? key,
  }) : super(key: key);

  @override
  State<DeadlineModal> createState() => _DeadlineModalState();
}

class _DeadlineModalState extends State<DeadlineModal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const ScrollChip(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/icons/_common/flags.svg",
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.editTask.deadline,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Separator(),
                  _predefinedDate(context),
                  const Separator(),
                  AddTaskCalendar(
                    selectedDate:
                        context.watch<EditTaskCubit>().state.newTask.dueDate,
                    onDateSelected: (DateTime? date) {
                      context
                          .read<EditTaskCubit>()
                          .setDeadline(date, update: false);

                      Navigator.pop(context);
                    },
                    onAddTimeClick: (DateTime? date) {
                      context
                          .read<EditTaskCubit>()
                          .setDeadline(date, update: true);
                    },
                  ),
                  const Separator(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _predefinedDate(BuildContext context) {
    DateTime now = DateTime.now();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(children: [
            const SizedBox(height: 2),
            _predefinedDateItem(
              context,
              text: t.addTask.today,
              trailingText: DateFormat("EEE").format(now),
              onPressed: () {
                context.read<EditTaskCubit>().setDeadline(now);

                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 2),
            _predefinedDateItem(
              context,
              text: t.addTask.tomorrow,
              trailingText:
                  DateFormat("EEE").format(now.add(const Duration(days: 1))),
              onPressed: () {
                context
                    .read<EditTaskCubit>()
                    .setDeadline(now.add(const Duration(days: 1)));

                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 2),
            Builder(builder: (context) {
              DateTime nextWeekend = now
                  .add(Duration(days: 7 - now.weekday + 1))
                  .add(const Duration(days: 5));

              return _predefinedDateItem(
                context,
                text: t.addTask.nextWeekend,
                trailingText: DateFormat("EEE").format(nextWeekend),
                onPressed: () {
                  context.read<EditTaskCubit>().setDeadline(nextWeekend);

                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 2),
            Builder(builder: (context) {
              DateTime nextMonday =
                  now.add(Duration(days: 7 - now.weekday + 1));

              return _predefinedDateItem(
                context,
                text: t.addTask.nextWeek,
                trailingText: DateFormat("EEE").format(nextMonday),
                onPressed: () {
                  context.read<EditTaskCubit>().setDeadline(nextMonday);
                  Navigator.pop(context);
                },
              );
            }),
          ]),
        ),
      ],
    );
  }

  Widget _predefinedDateItem(
    BuildContext context, {
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
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: ColorsExt.grey3(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
