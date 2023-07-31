import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/main_com.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/settings_header_text.dart';
import 'package:mobile/src/settings/ui/widgets/choose_theme_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ThemeOptions {
  static const String system = 'system';
  static const String light = 'light';
  static const String dark = 'dark';

  static String themeOptionToText(String theme) {
    switch (theme) {
      case ThemeOptions.system:
        return t.settings.general.auto;
      case ThemeOptions.light:
        return t.settings.general.light;
      case ThemeOptions.dark:
        return t.settings.general.dark;
      default:
        return t.settings.general.auto;
    }
  }

  static ThemeMode themeOptionToThemeMode(String theme) {
    switch (theme) {
      case ThemeOptions.system:
        return ThemeMode.system;
      case ThemeOptions.light:
        return ThemeMode.light;
      case ThemeOptions.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  final _preferencesRepository = locator<PreferencesRepository>();

  late String theme;

  @override
  void initState() {
    super.initState();

    theme = UserSettingsUtils.getSettingBySectionAndKey(
            preferencesRepository: _preferencesRepository,
            sectionName: UserSettingsUtils.generalSection,
            key: UserSettingsUtils.theme) ??
        ThemeOptions.system;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.general.general,
        showBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimension.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: Dimension.paddingS),
              child: SettingHeaderText(text: t.settings.general.style),
            ),
            InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(Dimension.radius)),
              onTap: () {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => ChooseThemeModal(
                    initialThemeMode: theme,
                    onChange: (newTheme) {
                      setState(() {
                        theme = newTheme;
                      });

                      Application.of(context).changeTheme(theme);

                      _saveNewSetting(
                          sectionName: UserSettingsUtils.generalSection, key: UserSettingsUtils.theme, value: theme);
                    },
                  ),
                );
              },
              child: Ink(
                color: ColorsExt.background(context),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorsExt.grey200(context)),
                      borderRadius: const BorderRadius.all(Radius.circular(Dimension.radius))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Dimension.paddingS),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.settings.general.theme,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey800(context))),
                            Text(ThemeOptions.themeOptionToText(theme),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey600(context))),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: Dimension.defaultIconSize,
                        height: Dimension.defaultIconSize,
                        child: SvgPicture.asset(Assets.images.icons.common.chevronRightSVG,
                            color: ColorsExt.grey600(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNewSetting({required String sectionName, required String key, required dynamic value}) {
    final AuthCubit authCubit = locator<AuthCubit>();
    Map<String, dynamic> setting = {
      'key': key,
      'value': value,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
    List<dynamic> sectionSettings = UserSettingsUtils.updateSectionSetting(
        sectionName: sectionName,
        localSectionSettings: _preferencesRepository.user?.settings?[sectionName],
        newSetting: setting);

    authCubit.updateSection(sectionName: sectionName, section: sectionSettings);

    authCubit.updateUserSettings({
      sectionName: [setting]
    });
  }
}
