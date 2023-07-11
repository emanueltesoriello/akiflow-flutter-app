import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/time_picker_utils.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/src/base/models/next_event_notifications_models.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/settings/ui/widgets/receive_event_notification_setting_modal.dart';
import 'package:mobile/src/settings/ui/widgets/receive_task_notification_setting_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final AuthCubit _authCubit = locator<AuthCubit>();
  String dailyOverviewTime = '';
  NextTaskNotificationsModel tasksNotificationsTime = NextTaskNotificationsModel.d;
  NextEventNotificationsModel eventsNotificationsTime = NextEventNotificationsModel.d;
  bool tasksNotificationsEnabled = true;
  bool eventsNotificationsEnabled = true;
  bool dailyOverviewNotificationsEnabled = true;
  bool taskCompletedSoundEnabled = true;

  @override
  void initState() {
    super.initState();

    //events
    eventsNotificationsEnabled = _authCubit.getSettingBySectionAndKey(
            sectionName: UserSettingsUtils.notificationsSection, key: UserSettingsUtils.eventsNotificationsEnabled) ??
        true;
    eventsNotificationsTime = NextEventNotificationsModel.fromMap(jsonDecode(_authCubit.getSettingBySectionAndKey(
            sectionName: UserSettingsUtils.notificationsSection, key: UserSettingsUtils.eventsNotificationsTime) ??
        '{"minutesBeforeToStart":5,"title":"5 minutes before the event starts"}'));

    //tasks
    tasksNotificationsEnabled = _authCubit.getSettingBySectionAndKey(
            sectionName: UserSettingsUtils.notificationsSection, key: UserSettingsUtils.tasksNotificationsEnabled) ??
        true;
    tasksNotificationsTime = NextTaskNotificationsModel.fromMap(jsonDecode(_authCubit.getSettingBySectionAndKey(
            sectionName: UserSettingsUtils.notificationsSection, key: UserSettingsUtils.tasksNotificationsTime) ??
        '{"minutesBeforeToStart":5,"title":"5 minutes before the task starts"}'));

    //daily overview
    dailyOverviewNotificationsEnabled = _authCubit.getSettingBySectionAndKey(
            sectionName: UserSettingsUtils.notificationsSection,
            key: UserSettingsUtils.dailyOverviewNotificationsEnabled) ??
        true;
    dailyOverviewTime = fromTimeOfDayToFormattedString(_authCubit.getSettingBySectionAndKey(
            sectionName: UserSettingsUtils.notificationsSection,
            key: UserSettingsUtils.dailyOverviewNotificationsTime) ??
        const TimeOfDay(hour: 8, minute: 0));

    //task complete sound
    taskCompletedSoundEnabled = _authCubit.getSettingBySectionAndKey(
            sectionName: UserSettingsUtils.tasksSection, key: UserSettingsUtils.taskCompletedSoundEnabled) ??
        true;
  }

  mainItem(String switchTitle, String mainButtonListTitle, String selectedBottomListItem, Function onTap,
      {required Function(bool) onChanged, required bool isEnabled}) {
    return Container(
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
          color: Colors.white),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 44,
            padding:
                const EdgeInsets.only(top: Dimension.paddingS, left: Dimension.paddingSM, right: Dimension.paddingSM),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    switchTitle,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ColorsExt.grey800(context),
                        ),
                  ),
                  FlutterSwitch(
                    width: 48,
                    height: 24,
                    toggleSize: 20,
                    activeColor: ColorsExt.akiflow500(context),
                    inactiveColor: ColorsExt.grey200(context),
                    value: isEnabled,
                    borderRadius: Dimension.radiusL,
                    padding: 2,
                    onToggle: (val) => onChanged(val),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Opacity(
            opacity: isEnabled ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !isEnabled,
              child: ListTile(
                visualDensity: const VisualDensity(vertical: -4), // to compact
                contentPadding: const EdgeInsets.only(
                    bottom: Dimension.paddingS, left: Dimension.paddingSM, right: Dimension.paddingSM),
                onTap: () => onTap(),
                title: Text(
                  mainButtonListTitle,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  selectedBottomListItem,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w400),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: Dimension.chevronIconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onReceiveNotificationNextTaskClick() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => ReceiveTaskNotificationSettingModal(
        selectedNextTaskNotificationsModel: tasksNotificationsTime,
        onSelectedNextTaskNotificationsModel: (NextTaskNotificationsModel newVal) {
          setState(() {
            tasksNotificationsTime = newVal;
          });
          _saveNewSetting(
              sectionName: UserSettingsUtils.notificationsSection,
              key: UserSettingsUtils.tasksNotificationsTime,
              value: jsonEncode(NextTaskNotificationsModel.toMap(tasksNotificationsTime)));
        },
      ),
    );
  }

  onReceiveNotificationNextEventClick() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => ReceiveEventNotificationSettingModal(
        selectedNextEventNotificationsModel: eventsNotificationsTime,
        onSelectedNextEventNotificationsModel: (NextEventNotificationsModel newVal) {
          setState(() {
            eventsNotificationsTime = newVal;
          });
          _saveNewSetting(
              sectionName: UserSettingsUtils.notificationsSection,
              key: UserSettingsUtils.eventsNotificationsTime,
              value: jsonEncode(NextEventNotificationsModel.toMap(eventsNotificationsTime)));
        },
      ),
    );
  }

  fromTimeOfDayToFormattedString(TimeOfDay value) {
    String hour = value.hour.toString();
    String minute = value.minute.toString().length == 1 ? '0${value.minute.toString()}' : value.minute.toString();
    return "At ${hour.toString()}:${minute.toString()}";
  }

  onReceiveNotificationDailyOverviewClick() {
    TimePickerUtils.pick(
      context,
      initialTime: _authCubit.getSettingBySectionAndKey(
              sectionName: UserSettingsUtils.notificationsSection,
              key: UserSettingsUtils.dailyOverviewNotificationsTime) ??
          const TimeOfDay(hour: 8, minute: 0),
      onTimeSelected: (selected) {
        if (selected != null) {
          setState(() {
            dailyOverviewTime = fromTimeOfDayToFormattedString(selected);
          });
          _saveNewSetting(
              sectionName: UserSettingsUtils.notificationsSection,
              key: UserSettingsUtils.dailyOverviewNotificationsTime,
              value: '${selected.hour.toString()}:${selected.minute.toString()}');

          NotificationsService.setDailyReminder(locator<PreferencesRepository>());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarComp(
        title: "Notifications",
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
                  "EVENTS IN CALENDAR".toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorsExt.grey600(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: Dimension.paddingXS),
                mainItem(
                    "Next events",
                    "Receive notification",
                    eventsNotificationsTime.title.replaceAll(RegExp(r'task'), 'event'),
                    () => onReceiveNotificationNextEventClick(), onChanged: (newVal) async {
                  setState(() {
                    eventsNotificationsEnabled = newVal;
                  });
                  if (newVal == false) {
                    await NotificationsService.cancelScheduledNotifications(locator<PreferencesRepository>());
                    NotificationsService.scheduleNotificationsService(locator<PreferencesRepository>());
                  } else if (newVal) {
                    locator<SyncCubit>().sync();
                  }
                  _saveNewSetting(
                      sectionName: UserSettingsUtils.notificationsSection,
                      key: UserSettingsUtils.eventsNotificationsEnabled,
                      value: eventsNotificationsEnabled);
                }, isEnabled: eventsNotificationsEnabled),
                const SizedBox(height: Dimension.padding),
                Text(
                  "TASKS IN CALENDAR".toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorsExt.grey600(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: Dimension.paddingXS),
                mainItem("Next tasks", "Receive notification", tasksNotificationsTime.title,
                    () => onReceiveNotificationNextTaskClick(), onChanged: (newVal) async {
                  setState(() {
                    tasksNotificationsEnabled = newVal;
                  });
                  if (newVal == false) {
                    await NotificationsService.cancelScheduledNotifications(locator<PreferencesRepository>());
                  } else if (newVal) {
                    NotificationsService.scheduleNotificationsService(locator<PreferencesRepository>());
                  }
                  _saveNewSetting(
                      sectionName: UserSettingsUtils.notificationsSection,
                      key: UserSettingsUtils.tasksNotificationsEnabled,
                      value: tasksNotificationsEnabled);
                }, isEnabled: tasksNotificationsEnabled),
                const SizedBox(height: Dimension.padding),
                Text(
                  "DAILY OVERVIEW".toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorsExt.grey600(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: Dimension.paddingXS),
                FutureBuilder(builder: (context, AsyncSnapshot<PreferencesRepository> repo) {
                  return Container();
                }),
                mainItem("Daily overview notification", "Receive notification", dailyOverviewTime,
                    () => onReceiveNotificationDailyOverviewClick(), onChanged: (newVal) async {
                  setState(() {
                    dailyOverviewNotificationsEnabled = newVal;
                  });
                  if (!newVal) {
                    NotificationsService.cancelNotificationById(NotificationsService.dailyReminderTaskId);
                  }
                  NotificationsService.setDailyReminder(locator<PreferencesRepository>());
                  _saveNewSetting(
                      sectionName: UserSettingsUtils.notificationsSection,
                      key: UserSettingsUtils.dailyOverviewNotificationsEnabled,
                      value: dailyOverviewNotificationsEnabled);
                }, isEnabled: dailyOverviewNotificationsEnabled),
                const SizedBox(height: Dimension.padding),
                Text(
                  "sounds".toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorsExt.grey600(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: Dimension.paddingXS),
                Container(
                  height: 54,
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
                      color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Task completed",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: ColorsExt.grey800(context),
                              ),
                        ),
                        FlutterSwitch(
                          width: 48,
                          height: 24,
                          toggleSize: 20,
                          activeColor: ColorsExt.akiflow500(context),
                          inactiveColor: ColorsExt.grey200(context),
                          value: taskCompletedSoundEnabled,
                          borderRadius: 24,
                          padding: 2,
                          onToggle: (value) {
                            setState(() {
                              taskCompletedSoundEnabled = value;
                            });
                            _saveNewSetting(
                                sectionName: UserSettingsUtils.tasksSection,
                                key: UserSettingsUtils.taskCompletedSoundEnabled,
                                value: taskCompletedSoundEnabled);
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
    final PreferencesRepository preferencesRepository = locator<PreferencesRepository>();
    Map<String, dynamic> setting = {
      'key': key,
      'value': value,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
    List<dynamic> sectionSettings = UserSettingsUtils.updateSectionSetting(
        sectionName: sectionName,
        localSectionSettings: preferencesRepository.user?.settings?[sectionName],
        newSetting: setting);

    _authCubit.updateSection(sectionName: sectionName, section: sectionSettings);

    _authCubit.updateUserSettings({
      sectionName: [setting]
    });
  }
}
