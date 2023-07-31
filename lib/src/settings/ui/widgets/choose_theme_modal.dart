import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/settings/ui/pages/general_settings_page.dart';

class ChooseThemeModal extends StatelessWidget {
  final String initialThemeMode;
  final Function(String) onChange;
  const ChooseThemeModal({super.key, required this.initialThemeMode, required this.onChange});

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
                    t.settings.general.appearance,
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
              text: ThemeOptions.themeOptionToText(ThemeOptions.system),
              active: initialThemeMode == ThemeOptions.system,
              click: () {
                onChange(ThemeOptions.system);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              text: ThemeOptions.themeOptionToText(ThemeOptions.light),
              active: initialThemeMode == ThemeOptions.light,
              click: () {
                onChange(ThemeOptions.light);
                Navigator.pop(context);
              },
            ),
            _item(
              context,
              text: ThemeOptions.themeOptionToText(ThemeOptions.dark),
              active: initialThemeMode == ThemeOptions.dark,
              click: () {
                onChange(ThemeOptions.dark);
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
