import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:rrule/rrule.dart';

class FrequencySelectionModal extends StatelessWidget {
  final Frequency? selectedFrequency;
  final Function(Frequency?) onChange;
  const FrequencySelectionModal({super.key, required this.selectedFrequency, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
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
                  const SizedBox(width: Dimension.paddingS),
                  Text(
                    t.editTask.recurrence.repeatEvery,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ColorsExt.grey800(context),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            _item(
              context,
              active: selectedFrequency == Frequency.daily,
              text: t.editTask.recurrence.day,
              click: () {
                onChange(Frequency.daily);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedFrequency == Frequency.weekly,
              text: t.editTask.recurrence.week,
              click: () {
                onChange(Frequency.weekly);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedFrequency == Frequency.monthly,
              text: t.editTask.recurrence.month,
              click: () {
                onChange(Frequency.monthly);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              active: selectedFrequency == Frequency.yearly,
              text: t.editTask.recurrence.year,
              click: () {
                onChange(Frequency.yearly);
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
        color: active ? ColorsExt.grey100(context) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey800(context)),
        ),
      ),
    );
  }
}
