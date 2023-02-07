import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
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
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 12),
            const ScrollChip(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    t.editTask.recurrence.repeatEvery,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
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
          style: TextStyle(
            fontSize: 17,
            color: ColorsExt.grey2(context),
          ),
        ),
      ),
    );
  }
}
