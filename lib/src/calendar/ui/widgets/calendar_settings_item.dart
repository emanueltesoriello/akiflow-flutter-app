import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/nullable.dart';

class CalendarItem extends StatefulWidget {
  const CalendarItem({super.key, required this.calendars, required this.title});

  final String title;
  final List<Calendar> calendars;

  @override
  State<CalendarItem> createState() => _CalendarItemState();
}

class _CalendarItemState extends State<CalendarItem> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
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
                        height: 22,
                        width: 22,
                        child: SvgPicture.asset(
                          "assets/images/icons/google/calendar.svg",
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context), fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    Assets.images.icons.common.chevronDownSVG,
                    width: 22,
                    height: 22,
                    color: ColorsExt.grey3(context),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.calendars.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 10.0, bottom: 10.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            bool isVisible = widget.calendars[index].settings != null &&
                                    widget.calendars[index].settings["visible"] != null
                                ? widget.calendars[index].settings["visible"]
                                : false;
                            bool notificationsEnabled = widget.calendars[index].settings != null &&
                                    widget.calendars[index].settings["notificationsEnabled"] != null
                                ? widget.calendars[index].settings["notificationsEnabled"]
                                : false;
                            dynamic settings = widget.calendars[index].settings;
                            if (settings != null) {
                              settings["visible"] = !isVisible;
                              isVisible
                                  ? settings["notificationsEnabled"] = notificationsEnabled
                                  : settings["notificationsEnabled"] = false;
                            } else {
                              settings = {"visible": !isVisible, "notificationsEnabled": true};
                            }

                            Calendar updatedCalendar = widget.calendars[index].copyWith(
                                settings: settings, updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));
                            context.read<CalendarCubit>().updateCalendar(updatedCalendar);

                            print(updatedCalendar.settings);
                          },
                          child: SvgPicture.asset(
                            widget.calendars[index].settings != null &&
                                    widget.calendars[index].settings["visible"] != null &&
                                    widget.calendars[index].settings["visible"] == true
                                ? Assets.images.icons.common.checkDoneSVG
                                : Assets.images.icons.common.checkEmptySVG,
                            width: 22,
                            height: 22,
                            color: Color(int.parse(widget.calendars[index].color!.replaceAll('#', '0xff'))),
                          ),
                        ),
                        Text(
                          "${widget.calendars[index].title}",
                          style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context), fontWeight: FontWeight.w400),
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
