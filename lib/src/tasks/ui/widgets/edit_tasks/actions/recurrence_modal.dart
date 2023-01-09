import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/custom_repeat_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rrule/rrule.dart';

enum RecurrenceModalType { none, daily, everyCurrentDay, everyYearOnThisDay, everyWeekday, custom }

class RecurrenceModal extends StatelessWidget {
  final Function(RecurrenceRule?) onChange;
  final RecurrenceModalType? selectedRecurrence;

  const RecurrenceModal({
    Key? key,
    required this.onChange,
    required this.selectedRecurrence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          children: [
            const SizedBox(height: 12),
            const ScrollChip(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/icons/_common/repeat.svg",
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.editTask.repeat,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                ],
              ),
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.none,
              text: t.editTask.noRepeat,
              click: () {
                onChange(null);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.daily,
              text: t.editTask.everyDay,
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.daily,
                  until: DateTime.now().toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.everyCurrentDay,
              text: t.editTask.everyCurrentDay(
                day: DateFormat("EEEE").format(DateTime.now()),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.weekly,
                  byWeekDays: {
                    ByWeekDayEntry(DateTime.now().weekday),
                  },
                  until: DateTime.now().toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.everyYearOnThisDay,
              text: t.editTask.everyYearOn(
                date: DateFormat("MMM dd").format(DateTime.now()),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.yearly,
                  until: DateTime.now().toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.everyWeekday,
              text: t.editTask.everyWeekday,
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.weekly,
                  byWeekDays: {
                    ByWeekDayEntry(DateTime.monday),
                    ByWeekDayEntry(DateTime.tuesday),
                    ByWeekDayEntry(DateTime.wednesday),
                    ByWeekDayEntry(DateTime.thursday),
                    ByWeekDayEntry(DateTime.friday),
                  },
                  until: DateTime.now().toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => const CustomRepeatModal(),
                    );
                  },
                  child: Text(
                    t.editTask.custom,
                    style: TextStyle(
                      fontSize: 17,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required bool active,
    required String text,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Container(
        color: active ? ColorsExt.grey6(context) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            color: ColorsExt.grey2(context),
          ),
        ),
      ),
    );
  }
}
