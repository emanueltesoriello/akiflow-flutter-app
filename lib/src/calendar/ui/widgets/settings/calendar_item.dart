import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:models/calendar/calendar.dart';

class CalendarItem extends StatefulWidget {
  const CalendarItem({super.key, required this.calendars, required this.title});

  final String title;
  final List<Calendar> calendars;

  @override
  State<CalendarItem> createState() => _CalendarItemState();
}

class _CalendarItemState extends State<CalendarItem> {
  bool _isExpanded = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimension.paddingS, left: Dimension.paddingS, right: Dimension.paddingS),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => setState(() {
              _isExpanded = !_isExpanded;
            }),
            child: SizedBox(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: Dimension.defaultIconSize,
                        width: Dimension.defaultIconSize,
                        child: SvgPicture.asset(
                          Assets.images.icons.google.calendarSVG,
                        ),
                      ),
                      const SizedBox(width: Dimension.paddingS),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context), fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    Assets.images.icons.common.chevronDownSVG,
                    width: Dimension.defaultIconSize,
                    height: Dimension.defaultIconSize,
                    color: ColorsExt.grey3(context),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: Dimension.paddingS, bottom: Dimension.paddingS),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.calendars.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: Dimension.paddingS, top: Dimension.paddingS + 2, bottom: Dimension.paddingS + 2),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.calendars[index] =
                                context.read<CalendarCubit>().changeCalendarVisibility(widget.calendars[index]);
                            context.read<CalendarCubit>().updateCalendar(widget.calendars[index]);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                widget.calendars[index].settings != null &&
                                        ((widget.calendars[index].settings["visibleMobile"] ??
                                                widget.calendars[index].settings["visible"] ??
                                                false) ==
                                            true)
                                    ? Assets.images.icons.common.checkDoneSVG
                                    : Assets.images.icons.common.checkEmptySVG,
                                width: Dimension.defaultIconSize,
                                height: Dimension.defaultIconSize,
                                color: ColorsExt.fromHex(EventExt.calendarColor[widget.calendars[index].color!] ??
                                    widget.calendars[index].color!),
                              ),
                              const SizedBox(width: Dimension.paddingS),
                              Text(
                                "${widget.calendars[index].title}",
                                style: TextStyle(
                                    fontSize: 17, color: ColorsExt.grey2(context), fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
