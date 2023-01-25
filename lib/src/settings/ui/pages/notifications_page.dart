import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/common/utils/time_picker_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
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
          border: Border.all(color: ColorsExt.grey5(context)),
          borderRadius: const BorderRadius.all(
            Radius.circular(radius),
          ),
          color: Colors.white),
      child: ListView(
        shrinkWrap: true,
        children: [
          SwitchListTile(
            value: isEnabled,
            onChanged: (val) => onChanged(val),
            activeColor: ColorsExt.akiflow(context),
            title: Text(
              switchTitle,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 17,
                color: ColorsExt.grey2(context),
              ),
            ),
          ),
          const Divider(),
          Opacity(
            opacity: isEnabled ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !isEnabled,
              child: ListTile(
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
    return "At ${value.hour.toString()}:${value.minute.toString()}";
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
                    await NotificationsCubit.cancelScheduledNotifications();
                  } else if (newVal) {
                    Workmanager().registerOneOffTask(
                      "com.akiflow.mobile.scheduleNotifications",
                      "com.akiflow.mobile.scheduleNotifications",
                    );
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
                Opacity(
                  opacity: 0.3,
                  child: IgnorePointer(
                    ignoring: true,
                    child: mainItem("Daily overview notification", "Receive notification", dailyOverviewTime,
                        () => onReceiveNotificationDailyOverviewClick(), onChanged: (newVal) {
                      service.seDailyOverviewNotificationTime(newVal);
                      setState(() {
                        dailyOverviewNotificationTimeEnabled = newVal;
                      });
                    }, isEnabled: dailyOverviewNotificationTimeEnabled),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
