import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class ChangeColorModal extends StatelessWidget {
  final String? selectedColor;
  final Function(String?) onChange;
  const ChangeColorModal({super.key, required this.selectedColor, required this.onChange});

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(Dimension.padding),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: Dimension.padding),
              const ScrollChip(),
              const SizedBox(height: Dimension.padding),
              Padding(
                padding: const EdgeInsets.only(bottom: Dimension.paddingM),
                child: Row(
                  children: [
                    const SizedBox(width: Dimension.paddingS),
                    Text(t.event.editEvent.eventColor,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _item(
                    context,
                    active: EventExt.eventColor['#dc2127'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#dc2127'] == EventExt.eventColor[selectedColor],
                    color: '#dc2127',
                    click: () {
                      onChange('#dc2127');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#ffb878'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#ffb878'] == EventExt.eventColor[selectedColor],
                    color: '#ffb878',
                    click: () {
                      onChange('#ffb878');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#7ae7bf'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#7ae7bf'] == EventExt.eventColor[selectedColor],
                    color: '#7ae7bf',
                    click: () {
                      onChange('#7ae7bf');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#46d6db'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#46d6db'] == EventExt.eventColor[selectedColor],
                    color: '#46d6db',
                    click: () {
                      onChange('#46d6db');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#a4bdfc'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#a4bdfc'] == EventExt.eventColor[selectedColor],
                    color: '#a4bdfc',
                    click: () {
                      onChange('#a4bdfc');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#e1e1e1'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#e1e1e1'] == EventExt.eventColor[selectedColor],
                    color: '#e1e1e1',
                    click: () {
                      onChange('#e1e1e1');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _item(
                    context,
                    active: EventExt.eventColor['#ff887c'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#ff887c'] == EventExt.eventColor[selectedColor],
                    color: '#ff887c',
                    click: () {
                      onChange('#ff887c');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#fbd75b'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#fbd75b'] == EventExt.eventColor[selectedColor],
                    color: '#fbd75b',
                    click: () {
                      onChange('#fbd75b');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#51b749'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#51b749'] == EventExt.eventColor[selectedColor],
                    color: '#51b749',
                    click: () {
                      onChange('#51b749');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#5484ed'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#5484ed'] == EventExt.eventColor[selectedColor],
                    color: '#5484ed',
                    click: () {
                      onChange('#5484ed');
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    active: EventExt.eventColor['#dbadff'] == EventExt.calendarColor[selectedColor] ||
                        EventExt.eventColor['#dbadff'] == EventExt.eventColor[selectedColor],
                    color: '#dbadff',
                    click: () {
                      onChange('#dbadff');
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 50, width: 50),
                ],
              ),
              const SizedBox(height: Dimension.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required bool active,
    required String color,
    required Function() click,
  }) {
    return Padding(
      padding: const EdgeInsets.all(Dimension.paddingXS),
      child: SizedBox(
        height: 42,
        width: 42,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: click,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ColorsExt.getCalendarBackgroundColor(context, ColorsExt.fromHex(EventExt.eventColor[color]!)),
                  border: Border.all(color: ColorsExt.fromHex(EventExt.eventColor[color]!), width: 2),
                  shape: BoxShape.circle,
                ),
              ),
              if (active)
                Center(
                  child: SizedBox(
                    height: Dimension.defaultIconSize,
                    width: Dimension.defaultIconSize,
                    child: SvgPicture.asset(Assets.images.icons.common.checkmarkSVG,
                        color: ColorsExt.fromHex(EventExt.eventColor[color]!)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
