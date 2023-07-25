import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class VisibilityMode {
  static String public = 'public';
  static String private = 'private';
  static String busy = 'busy';
}

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
                    'Event visibility',
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
              text: 'Public',
              active: initialVisibility == VisibilityMode.public,
              click: () {
                onChange(VisibilityMode.public);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              icon: Assets.images.icons.common.eyePrivateSVG,
              text: 'Private',
              active: initialVisibility == VisibilityMode.private,
              click: () {
                onChange(VisibilityMode.private);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              icon: Assets.images.icons.common.eyeBusySVG,
              text: 'Busy',
              active: initialVisibility == VisibilityMode.busy,
              click: () {
                onChange(VisibilityMode.busy);
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
            SizedBox(
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              child: SvgPicture.asset(icon),
            ),
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
