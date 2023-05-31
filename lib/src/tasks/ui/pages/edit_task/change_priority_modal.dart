import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

enum PriorityEnum {
  high(1),
  medium(2),
  low(3),
  none(-1);

  final int? value;
  const PriorityEnum(this.value);

  factory PriorityEnum.fromValue(int? value) {
    switch (value) {
      case 1:
        return high;
      case 2:
        return medium;
      case 3:
        return low;
      default:
        return none;
    }
  }
}

class PriorityModal extends StatelessWidget {
  final PriorityEnum? selectedPriority;

  const PriorityModal(this.selectedPriority, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: Dimension.padding),
            const ScrollChip(),
            Padding(
              padding: const EdgeInsets.all(Dimension.padding),
              child: Row(
                children: [
                  Text(
                    t.task.priority.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.grey800(context),
                        ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: selectedPriority != PriorityEnum.none,
              replacement: const SizedBox(),
              child: _item(
                context,
                active: selectedPriority == PriorityEnum.none,
                text: t.task.priority.noPriority,
                click: () {
                  Navigator.pop(context, PriorityEnum.none);
                },
                icon: Assets.images.icons.common.slashCircleSVG,
              ),
            ),
            _item(
              context,
              active: selectedPriority == PriorityEnum.low,
              text: t.task.priority.low,
              click: () {
                Navigator.pop(context, PriorityEnum.low);
              },
              icon: Assets.images.icons.common.exclamationmark1SVG,
            ),
            _item(
              context,
              active: selectedPriority == PriorityEnum.medium,
              text: t.task.priority.medium,
              click: () {
                Navigator.pop(context, PriorityEnum.medium);
              },
              icon: Assets.images.icons.common.exclamationmark2SVG,
            ),
            _item(
              context,
              active: selectedPriority == PriorityEnum.high,
              text: t.task.priority.high,
              click: () {
                Navigator.pop(context, PriorityEnum.high);
              },
              icon: Assets.images.icons.common.exclamationmark3SVG,
            ),
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
    required String icon,
  }) {
    return InkWell(
      onTap: click,
      child: Container(
        color: active ? ColorsExt.grey100(context) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      color: ColorsExt.grey800(context),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
