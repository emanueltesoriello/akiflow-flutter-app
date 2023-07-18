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

enum EventRecurrenceModalType {
  none,
  daily,
  everyCurrentDay,
  everyYearOnThisDay,
  everyMonthOnThisDay,
  everyWeekday,
  custom
}

class EventRecurrenceModal extends StatelessWidget {
  final Function(RecurrenceRule?) onChange;
  final Function(EventRecurrenceModalType) onRecurrenceType;
  final EventRecurrenceModalType? selectedRecurrence;
  final RecurrenceRule? rule;
  final DateTime eventStartTime;

  const EventRecurrenceModal({
    Key? key,
    required this.onChange,
    required this.selectedRecurrence,
    required this.rule,
    required this.onRecurrenceType,
    required this.eventStartTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
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
                    width: Dimension.appBarLeadingIcon,
                    height: Dimension.appBarLeadingIcon,
                  ),
                  const SizedBox(width: Dimension.paddingS),
                  Text(t.editTask.repeat,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey800(context))),
                ],
              ),
            ),
            _item(
              context,
              active: selectedRecurrence == EventRecurrenceModalType.none,
              text: t.event.editEvent.recurrence.noRepeat,
              click: () {
                onChange(null);
                onRecurrenceType(EventRecurrenceModalType.none);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == EventRecurrenceModalType.daily,
              text: t.event.editEvent.recurrence.everyDay,
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.daily,
                  until: eventStartTime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                onRecurrenceType(EventRecurrenceModalType.daily);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == EventRecurrenceModalType.everyCurrentDay,
              text: t.editTask.everyCurrentDay(
                day: DateFormat("EEEE").format(eventStartTime),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.weekly,
                  byWeekDays: {
                    ByWeekDayEntry(eventStartTime.weekday),
                  },
                  until: eventStartTime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                onRecurrenceType(EventRecurrenceModalType.everyCurrentDay);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == EventRecurrenceModalType.everyYearOnThisDay,
              text: t.editTask.everyYearOn(
                date: DateFormat("MMM dd").format(eventStartTime),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.yearly,
                  until: eventStartTime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                onRecurrenceType(EventRecurrenceModalType.everyYearOnThisDay);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == EventRecurrenceModalType.everyMonthOnThisDay,
              text: t.editTask.everyMonthOn(
                date: DateFormat("MMM dd").format(eventStartTime),
              ),
              click: () {
                var rule = RecurrenceRule(
                  frequency: Frequency.monthly,
                  byMonthDays: {eventStartTime.day},
                  until: eventStartTime.toUtc().add(const Duration(days: 365 * 2)),
                );
                onChange(rule);
                onRecurrenceType(EventRecurrenceModalType.everyMonthOnThisDay);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedRecurrence == EventRecurrenceModalType.everyWeekday,
              text: t.event.editEvent.recurrence.everyWeekday,
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
                  until: eventStartTime.toUtc().add(const Duration(days: 365 * 2)),
                );

                onChange(rule);
                onRecurrenceType(EventRecurrenceModalType.everyWeekday);
                Navigator.pop(context);
              },
            ),
            Container(
                color: selectedRecurrence == EventRecurrenceModalType.custom
                    ? ColorsExt.grey100(context)
                    : Colors.transparent,
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
                          onRecurrenceType(EventRecurrenceModalType.custom);
                        },
                      ),
                    );
                  },
                  child: Text(t.editTask.custom,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context))),
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
        color: active ? ColorsExt.grey100(context) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context))),
      ),
    );
  }
}
