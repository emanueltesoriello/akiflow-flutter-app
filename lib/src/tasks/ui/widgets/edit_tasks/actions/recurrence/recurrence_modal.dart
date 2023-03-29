import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/recurrence/custom_recurrence_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rrule/rrule.dart';

enum RecurrenceModalType {
  none,
  daily,
  everyCurrentDay,
  everyYearOnThisDay,
  everyMonthOnThisDay,
  everyLastDayOfTheMonth,
  everyWeekday,
  custom
}

class RecurrenceModal extends StatelessWidget {
  final Function(RecurrenceRule?) onChange;
  final RecurrenceModalType? selectedRecurrence;
  final RecurrenceRule? rule;
  final DateTime taskDatetime;

  const RecurrenceModal({
    Key? key,
    required this.onChange,
    required this.selectedRecurrence,
    required this.rule,
    required this.taskDatetime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime lastDayOfMonth = DateTime(taskDatetime.year, taskDatetime.month + 1, 0);
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: Dimension.padding),
            const ScrollChip(),
            const SizedBox(height: Dimension.padding),
            Padding(
              padding: const EdgeInsets.all(Dimension.padding),
              child: Row(
                children: [
                  SvgPicture.asset(
                    Assets.images.icons.common.repeatSVG,
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: Dimension.paddingS),
                  Text(
                    t.editTask.repeat,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ColorsExt.grey2(context),
                          fontWeight: FontWeight.w500,
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
                  until: taskDatetime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.everyCurrentDay,
              text: t.editTask.everyCurrentDay(
                day: DateFormat("EEEE").format(taskDatetime),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.weekly,
                  byWeekDays: {
                    ByWeekDayEntry(taskDatetime.weekday),
                  },
                  until: taskDatetime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.everyYearOnThisDay,
              text: t.editTask.everyYearOn(
                date: DateFormat("MMM dd").format(taskDatetime),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.yearly,
                  until: taskDatetime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == RecurrenceModalType.everyMonthOnThisDay,
              text: t.editTask.everyMonthOn(
                date: DateFormat("MMM dd").format(taskDatetime),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.monthly,
                  until: taskDatetime.toUtc().add(const Duration(days: 365 * 2)),
                );
                onChange(rule);
                Navigator.pop(context);
              },
            ),
            if (taskDatetime.year == lastDayOfMonth.year &&
                taskDatetime.month == lastDayOfMonth.month &&
                taskDatetime.day == lastDayOfMonth.day)
              _item(
                context,
                active: selectedRecurrence == RecurrenceModalType.everyLastDayOfTheMonth,
                text: t.editTask.everyLastDayOfTheMonth,
                click: () {
                  var rule = RecurrenceRule(
                    frequency: Frequency.monthly,
                    byMonthDays: const {-1},
                    until: taskDatetime.toUtc().add(const Duration(days: 365 * 2)),
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
                  until: taskDatetime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                Navigator.pop(context);
              },
            ),
            Container(
                color: selectedRecurrence == RecurrenceModalType.custom ? ColorsExt.grey6(context) : Colors.transparent,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => CustomRecurrenceModal(
                        rule: rule,
                        onChange: (RecurrenceRule? rule) {
                          onChange(rule);
                        },
                      ),
                    );
                  },
                  child: Text(
                    t.editTask.custom,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey2(context)),
                  ),
                )),
            const SizedBox(height: Dimension.paddingL),
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
          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey2(context)),
        ),
      ),
    );
  }
}
