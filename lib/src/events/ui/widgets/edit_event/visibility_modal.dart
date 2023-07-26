import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class VisibilityModal extends StatelessWidget {
  final String initialVisibility;
  final Function(String) onChange;
  const VisibilityModal({super.key, required this.initialVisibility, required this.onChange});

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
                    t.editTask.visibility.eventVisibility,
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
              text: EventExt.getVisibilityMode(EventExt.visibilityDefault),
              active: initialVisibility == EventExt.visibilityDefault,
              click: () {
                onChange(EventExt.visibilityDefault);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              icon: Assets.images.icons.common.eyePrivateSVG,
              text: EventExt.getVisibilityMode(EventExt.visibilityPublic),
              active: initialVisibility == EventExt.visibilityPublic,
              click: () {
                onChange(EventExt.visibilityPublic);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              icon: Assets.images.icons.common.eyePublicSVG,
              text: EventExt.getVisibilityMode(EventExt.visibilityPrivate),
              active: initialVisibility == EventExt.visibilityPrivate,
              click: () {
                onChange(EventExt.visibilityPrivate);
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
