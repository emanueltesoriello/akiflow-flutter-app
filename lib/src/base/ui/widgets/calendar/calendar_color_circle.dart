import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';

class CalendarColorCircle extends StatelessWidget {
  final bool active;
  final String calendarColor;
  final double size;
  const CalendarColorCircle(
      {super.key, this.active = true, required this.calendarColor, this.size = Dimension.defaultIconSize});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (active)
        SvgPicture.asset(
          Assets.images.icons.common.circleFillSVG,
          width: size,
          height: size,
          color: ColorsExt.getCalendarBackgroundColor(
              ColorsExt.fromHex(EventExt.calendarColor[calendarColor] ?? calendarColor)),
        ),
      SvgPicture.asset(
        Assets.images.icons.common.circleSVG,
        width: size,
        height: size,
        color: active
            ? ColorsExt.fromHex(EventExt.calendarColor[calendarColor] ?? calendarColor)
            : ColorsExt.getCalendarBackgroundColor(
                ColorsExt.fromHex(EventExt.calendarColor[calendarColor] ?? calendarColor)),
      ),
    ]);
  }
}
