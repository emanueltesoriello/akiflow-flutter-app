import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/time_format_utils.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';

class CalendarSettingsPage extends StatefulWidget {
  const CalendarSettingsPage({Key? key}) : super(key: key);

  @override
  State<CalendarSettingsPage> createState() => _CalendarSettingsPageState();
}

class _CalendarSettingsPageState extends State<CalendarSettingsPage> {
  final _preferencesRepository = locator<PreferencesRepository>();

  int timeFormat = -1;
  bool use24hFormat = true;

  @override
  void initState() {
    super.initState();

    timeFormat = _preferencesRepository.timeFormat;
  }

  @override
  Widget build(BuildContext context) {
    timeFormat = _preferencesRepository.timeFormat;
    use24hFormat = TimeFormatUtils.use24hFormat(timeFormat: timeFormat, context: context);

    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.calendar,
        showBack: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
              children: [
                const SizedBox(height: Dimension.padding),
                Text(
                  t.settings.viewOptions.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorsExt.grey600(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: Dimension.paddingXS),
                Container(
                  height: 61,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimension.radius),
                      boxShadow: [
                        BoxShadow(
                          color: ColorsExt.grey200(context),
                          offset: const Offset(0, 2),
                          blurRadius: 1,
                        ),
                      ],
                      color: ColorsExt.background(context),),
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.settings.use24hoursFormat,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: ColorsExt.grey800(context),
                                  ),
                            ),
                            const SizedBox(height: Dimension.paddingXS),
                            Text(
                              use24hFormat ? "13:00" : "1:00 PM",
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: ColorsExt.grey600(context),
                                  ),
                            ),
                          ],
                        ),
                        FlutterSwitch(
                          width: 48,
                          height: 24,
                          toggleSize: 20,
                          activeColor: ColorsExt.akiflow500(context),
                          inactiveColor: ColorsExt.grey200(context),
                          value: use24hFormat,
                          borderRadius: 24,
                          padding: 2,
                          onToggle: (value) {
                            setState(() {
                              use24hFormat = value;
                            });
                            int timeFormat = value ? TimeFormatUtils.twentyFourHours : TimeFormatUtils.twelveHours;
                            _preferencesRepository.setTimeFormat(timeFormat);
                            _saveNewSetting(
                                sectionName: UserSettingsUtils.calendarSection,
                                key: UserSettingsUtils.timeFormat,
                                value: timeFormat);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
