import 'package:flutter/material.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class TransparencyModal extends StatelessWidget {
  final String initialTransparency;
  final Function(String) onChange;
  const TransparencyModal({super.key, required this.initialTransparency, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
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
                    'Mark as',
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
              icon: Assets.images.icons.common.eyePublicSVG,
              text: EventExt.getTransparencyMode(EventExt.transparencyOpaque),
              active: initialTransparency == EventExt.transparencyOpaque,
              click: () {
                onChange(EventExt.transparencyOpaque);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              icon: Assets.images.icons.common.eyePrivateSVG,
              text: EventExt.getTransparencyMode(EventExt.transparencyTransparent),
              active: initialTransparency == EventExt.transparencyTransparent,
              click: () {
                onChange(EventExt.transparencyTransparent);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: Dimension.paddingM),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required String icon,
    required String text,
    required bool active,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Container(
        padding: const EdgeInsets.all(Dimension.padding),
        color: active ? ColorsExt.grey100(context) : Colors.transparent,
        child: Row(
          children: [
            const SizedBox(width: Dimension.padding),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
