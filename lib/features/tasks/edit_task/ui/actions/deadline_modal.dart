import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/components/base/scroll_chip.dart';
import 'package:mobile/common/components/base/separator.dart';
import 'package:mobile/features/tasks/create_task/ui/create_task_calendar.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:models/extensions/user_ext.dart';

class DeadlineModal extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime?) onSelectDate;

  const DeadlineModal({
    Key? key,
    required this.initialDate,
    required this.onSelectDate,
  }) : super(key: key);

  @override
  State<DeadlineModal> createState() => _DeadlineModalState();
}

class _DeadlineModalState extends State<DeadlineModal> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
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
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 12),
                const ScrollChip(),
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
                _predefinedDate(context, widget.onSelectDate),
                const Separator(),
                CreateTaskCalendar(
                  initialDate: widget.initialDate ?? DateTime.now(),
                  initialDateTime: null,
                  onConfirm: (DateTime date, DateTime? datetime) {
                    widget.onSelectDate(datetime ?? date);
                  },
                  showTime: false,
                  defaultTimeHour: context.watch<AuthCubit>().state.user!.defaultHour,
                ),
                const Separator(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _predefinedDate(BuildContext context, Function onSelectDate) {
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
              onSelectDate(now);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 2),
          _predefinedDateItem(
            context,
            text: t.addTask.tomorrow,
            trailingText: DateFormat("EEE").format(now.add(const Duration(days: 1))),
            onPressed: () {
              onSelectDate(now.add(const Duration(days: 1)));
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 2),
          Builder(builder: (context) {
            DateTime nextWeekend = now.add(Duration(days: 7 - now.weekday + 1)).add(const Duration(days: 5));

            return _predefinedDateItem(
              context,
              text: t.addTask.nextWeekend,
              trailingText: DateFormat("EEE").format(nextWeekend),
              onPressed: () {
                onSelectDate(nextWeekend);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 2),
          Builder(builder: (context) {
            DateTime nextMonday = now.add(Duration(days: 7 - now.weekday + 1));

            return _predefinedDateItem(
              context,
              text: t.addTask.nextWeek,
              trailingText: DateFormat("EEE").format(nextMonday),
              onPressed: () {
                onSelectDate(nextMonday);
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
