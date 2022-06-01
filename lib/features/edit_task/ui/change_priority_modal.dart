import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';

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
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 12),
                const ScrollChip(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/icons/_common/exclamationmark.svg",
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.task.priority.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.grey2(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(builder: (context) {
                  if (selectedPriority != null && selectedPriority == PriorityEnum.none) {
                    return const SizedBox();
                  }

                  return _item(
                    context,
                    active: selectedPriority == PriorityEnum.none,
                    text: t.task.priority.noPriority,
                    click: () {
                      Navigator.pop(context, PriorityEnum.none);
                    },
                    icon: "assets/images/icons/_common/slash_circle.svg",
                  );
                }),
                _item(
                  context,
                  active: selectedPriority == PriorityEnum.low,
                  text: t.task.priority.low,
                  click: () {
                    Navigator.pop(context, PriorityEnum.low);
                  },
                  icon: "assets/images/icons/_common/exclamationmark_1.svg",
                ),
                _item(
                  context,
                  active: selectedPriority == PriorityEnum.medium,
                  text: t.task.priority.medium,
                  click: () {
                    Navigator.pop(context, PriorityEnum.medium);
                  },
                  icon: "assets/images/icons/_common/exclamationmark_2.svg",
                ),
                _item(
                  context,
                  active: selectedPriority == PriorityEnum.high,
                  text: t.task.priority.high,
                  click: () {
                    Navigator.pop(context, PriorityEnum.high);
                  },
                  icon: "assets/images/icons/_common/exclamationmark_3.svg",
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
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
        color: active ? ColorsExt.grey6(context) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  color: ColorsExt.grey2(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
