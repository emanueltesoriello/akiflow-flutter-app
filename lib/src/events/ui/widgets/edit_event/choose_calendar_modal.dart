import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_color_circle.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:models/calendar/calendar.dart';

class ChooseCalendarModal extends StatefulWidget {
  final String? initialCalendar;
  final Function(Calendar) onChange;
  final bool forTask;
  final Function(void)? onRemoveCalendar;
  const ChooseCalendarModal({
    super.key,
    required this.initialCalendar,
    required this.onChange,
    this.forTask = false,
    this.onRemoveCalendar,
  });

  @override
  State<ChooseCalendarModal> createState() => _ChooseCalendarModalState();
}

class _ChooseCalendarModalState extends State<ChooseCalendarModal> {
  List<bool> isExpandedList = [];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        List<Calendar> primaryCalendars = state.calendars.where((calendar) => calendar.primary == true).toList();
        Map<String, List<Calendar>> groupedCalendars = {};

        for (var primaryCalendar in primaryCalendars) {
          isExpandedList.add(true);
          groupedCalendars.addAll({
            '${primaryCalendar.title}': state.calendars
                .where((calendar) =>
                    calendar.akiflowAccountId == primaryCalendar.akiflowAccountId && calendar.readOnly == false)
                .toList()
          });
        }

        return Material(
          color: ColorsExt.background(context),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimension.radiusM),
                topRight: Radius.circular(Dimension.radiusM),
              ),
            ),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      Text(
                        t.event.editEvent.chooseCalendar,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: ColorsExt.grey800(context),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimension.padding),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedCalendars.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() {
                            isExpandedList[index] = !isExpandedList[index];
                          }),
                          child: SizedBox(
                            height: 42,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: Dimension.paddingS),
                                    SizedBox(
                                      height: Dimension.defaultIconSize,
                                      width: Dimension.defaultIconSize,
                                      child: SvgPicture.asset(
                                        Assets.images.icons.google.calendarSVG,
                                      ),
                                    ),
                                    const SizedBox(width: Dimension.paddingS),
                                    Text(groupedCalendars.keys.elementAt(index),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      Assets.images.icons.common.chevronDownSVG,
                                      width: Dimension.defaultIconSize,
                                      height: Dimension.defaultIconSize,
                                      color: ColorsExt.grey600(context),
                                    ),
                                    const SizedBox(width: Dimension.padding),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimension.paddingS),
                        if (isExpandedList[index])
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedCalendars.values.elementAt(index).length,
                            itemBuilder: (context, index2) {
                              return _item(
                                context,
                                active: widget.forTask
                                    ? widget.initialCalendar == groupedCalendars.values.elementAt(index)[index2].id
                                    : widget.initialCalendar ==
                                        groupedCalendars.values.elementAt(index)[index2].originId,
                                forTask: widget.forTask,
                                text: groupedCalendars.values.elementAt(index)[index2].title ?? '',
                                calendar: groupedCalendars.values.elementAt(index)[index2],
                                onCalendarSelectTap: () {
                                  widget.onChange(groupedCalendars.values.elementAt(index)[index2]);
                                  Navigator.pop(context);
                                },
                                onCalendarRemoveTap: () {
                                  widget.onChange(const Calendar());
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        const SizedBox(height: Dimension.paddingS),
                      ],
                    );
                  },
                ),
                const SizedBox(height: Dimension.paddingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _item(
    BuildContext context, {
    required bool active,
    required bool forTask,
    required String text,
    required Calendar calendar,
    required Function() onCalendarSelectTap,
    Function()? onCalendarRemoveTap,
  }) {
    return InkWell(
      onTap: onCalendarSelectTap,
      child: Container(
        color: active ? ColorsExt.grey100(context) : Colors.transparent,
        padding: const EdgeInsets.all(Dimension.paddingSM),
        child: Row(
          mainAxisAlignment: forTask ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: Dimension.paddingS),
                CalendarColorCircle(calendarColor: calendar.color!, active: active),
                const SizedBox(width: Dimension.paddingS),
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context)),
                ),
              ],
            ),
            if (forTask && active)
              Padding(
                padding: const EdgeInsets.only(right: Dimension.paddingXS),
                child: InkWell(
                  onTap: onCalendarRemoveTap,
                  child: SvgPicture.asset(
                    Assets.images.icons.common.xmarkSVG,
                    width: Dimension.defaultIconSize,
                    height: Dimension.defaultIconSize,
                    color: ColorsExt.grey600(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
