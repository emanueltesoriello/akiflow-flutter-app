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
                      SvgPicture.asset(
                        Assets.images.icons.google.calendarSVG,
                        width: Dimension.defaultIconSize,
                        height: Dimension.defaultIconSize,
                      ),
                      const SizedBox(width: Dimension.paddingS),
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
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: primaryCalendars.length,
                  itemBuilder: (context, index) {
                    return _item(
                      context,
                      active: initialCalendar == primaryCalendars[index].originId,
                      text: primaryCalendars[index].originId ?? '',
                      calendar: primaryCalendars[index],
                      click: () {
                        onChange(primaryCalendars[index]);
                        Navigator.pop(context);
                      },
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
        padding: const EdgeInsets.all(Dimension.padding),
        child: Row(
          children: [
            CalendarColorCircle(calendarColor: calendar.color!, active: active),
            const SizedBox(width: Dimension.paddingS),
            Text(
              text,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(color: ColorsExt.grey800(context)),
            ),
          ],
        ),
      ),
    );
  }
}
