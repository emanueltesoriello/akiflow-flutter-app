import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/common/utils/time_picker_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/settings/ui/widgets/receive_notification_setting_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workmanager/workmanager.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final service = locator<PreferencesRepository>();
  String dailyOverviewTime = '';
  NextTaskNotificationsModel selectedNextTaskNotificationsModel = NextTaskNotificationsModel.d;
  bool nextTaskNotificationSettingEnabled = false;
  bool dailyOverviewNotificationTimeEnabled = false;

  @override
  void initState() {
    super.initState();
    selectedNextTaskNotificationsModel = service.nextTaskNotificationSetting;
    nextTaskNotificationSettingEnabled = service.nextTaskNotificationSettingEnabled;
    dailyOverviewNotificationTimeEnabled = service.dailyOverviewNotificationTimeEnabled;
    dailyOverviewTime = fromTimeOfDayToFormattedString(service.dailyOverviewNotificationTime);
  }

  mainItem(String switchTitle, String mainButtonListTitle, String selectedButtonListItem, Function onTap,
      {required Function(bool) onChanged, required bool isEnabled}) {
    return Container(
      margin: const EdgeInsets.all(1),
      //padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: ColorsExt.grey5(context),
              offset: const Offset(0, 2),
              blurRadius: 1,
            ),
          ],
          color: Colors.white),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    switchTitle,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 17,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                  FlutterSwitch(
                    width: 48,
                    height: 24,
                    toggleSize: 20,
                    activeColor: ColorsExt.akiflow(context),
                    inactiveColor: ColorsExt.grey5(context),
                    value: isEnabled,
                    borderRadius: 24,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                onTap: () => onTap(),
                title: Text(
                  mainButtonListTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 17,
                    color: ColorsExt.grey2(context),
                  ),
                ),
                subtitle: Text(
                  selectedButtonListItem,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(color: ColorsExt.grey3(context), fontWeight: FontWeight.normal),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
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
      builder: (context) => ReceiveNotificationSettingModal(
        selectedNextTaskNotificationsModel: selectedNextTaskNotificationsModel,
        onSelectedNextTaskNotificationsModel: (NextTaskNotificationsModel newVal) {
          setState(() {
            selectedNextTaskNotificationsModel = newVal;
          });
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
    PreferencesRepository preferencesRepository = locator<PreferencesRepository>();
    TimePickerUtils.pick(
      context,
      initialTime: preferencesRepository.dailyOverviewNotificationTime,
      onTimeSelected: (selected) {
        if (selected != null) {
          preferencesRepository.setDailyOverviewNotificationTime(selected);
          setState(() {
            dailyOverviewTime = fromTimeOfDayToFormattedString(selected);
          });
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                Text(
                  "TASKS IN CALENDAR".toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                ),
                const SizedBox(height: 5),
                mainItem("Next tasks", "Receive notification", selectedNextTaskNotificationsModel.title,
                    () => onReceiveNotificationNextTaskClick(), onChanged: (newVal) async {
                  service.setNextTaskNotificationSettingEnabled(newVal);
                  setState(() {
                    nextTaskNotificationSettingEnabled = newVal;
                  });
                  if (newVal == false) {
                    await NotificationsService.cancelScheduledNotifications(locator<PreferencesRepository>());
                  } else if (newVal) {
                    if (Platform.isAndroid) {
                      Workmanager().registerOneOffTask(
                        scheduleNotificationsTaskKey,
                        scheduleNotificationsTaskKey,
                      );
                    } else {
                      NotificationsService.scheduleNotificationsService(locator<PreferencesRepository>());
                    }
                  }
                }, isEnabled: nextTaskNotificationSettingEnabled),
                const SizedBox(height: 20),
                Text(
                  "DAILY OVERVIEW".toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                ),
                const SizedBox(height: 5),
                FutureBuilder(builder: (context, AsyncSnapshot<PreferencesRepository> repo) {
                  return Container();
                }),
                mainItem("Daily overview notification", "Receive notification", dailyOverviewTime,
                    () => onReceiveNotificationDailyOverviewClick(), onChanged: (newVal) async {
                  service.seDailyOverviewNotificationTime(newVal);
                  setState(() {
                    dailyOverviewNotificationTimeEnabled = newVal;
                  });
                  if (!newVal) {
                    NotificationsService.cancelNotificationById(NotificationsService.dailyReminderTaskId);
                  }
                  NotificationsService.setDailyReminder(locator<PreferencesRepository>());
                }, isEnabled: dailyOverviewNotificationTimeEnabled),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
