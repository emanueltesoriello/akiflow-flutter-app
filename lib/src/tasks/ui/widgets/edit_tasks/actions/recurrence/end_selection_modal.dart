import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class EndSelectionModal extends StatelessWidget {
  final List<bool> endOption;
  final Function(List<bool>) onChange;
  const EndSelectionModal({super.key, required this.endOption, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimension.padding),
            topRight: Radius.circular(Dimension.padding),
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
                  const SizedBox(width: Dimension.paddingS),
                  Text(
                    t.editTask.recurrence.repeatEvery,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ColorsExt.grey2(context),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            _item(
              context,
              active: endOption.elementAt(0) == true,
              text: t.editTask.recurrence.never,
              click: () {
                onChange([true, false, false]);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: endOption.elementAt(1) == true,
              text: t.editTask.recurrence.until,
              click: () {
                onChange([false, true, false]);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: endOption.elementAt(2) == true,
              text: t.editTask.recurrence.after,
              click: () {
                onChange([false, false, true]);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 48),
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
        color: active ? ColorsExt.grey6(context) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Text(
          text,
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                color: ColorsExt.grey2(context),
              ),
        ),
      ),
    );
  }
}
