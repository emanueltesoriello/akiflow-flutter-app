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

class ChooseCalendarModal extends StatelessWidget {
  final String? initialCalendar;
  final Function(Calendar) onChange;
  const ChooseCalendarModal({super.key, required this.initialCalendar, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        List<Calendar> primaryCalendars = state.calendars.where((calendar) => calendar.primary == true).toList();
        Map<String, List<Calendar>> groupedCalendars = {};

        for (var primaryCalendar in primaryCalendars) {
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
                        Row(
                          children: [
                            const SizedBox(width: Dimension.paddingS),
                            SvgPicture.asset(
                              Assets.images.icons.google.calendarSVG,
                              width: Dimension.defaultIconSize,
                              height: Dimension.defaultIconSize,
                            ),
                            const SizedBox(width: Dimension.paddingS),
                            Text(
                              groupedCalendars.keys.elementAt(index),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: ColorsExt.grey700(context),
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimension.paddingS),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupedCalendars.values.elementAt(index).length,
                          itemBuilder: (context, index2) {
                            return _item(
                              context,
                              active: initialCalendar == groupedCalendars.values.elementAt(index)[index2].originId,
                              text: groupedCalendars.values.elementAt(index)[index2].title ?? '',
                              calendar: groupedCalendars.values.elementAt(index)[index2],
                              click: () {
                                onChange(groupedCalendars.values.elementAt(index)[index2]);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: Dimension.padding),
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
    required String text,
    required Calendar calendar,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Container(
        color: active ? ColorsExt.grey100(context) : Colors.transparent,
        padding: const EdgeInsets.all(Dimension.paddingSM),
        child: Row(
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
      ),
    );
  }
}
