import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/common/utils/time_picker_utils.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/settings/ui/widgets/receive_notification_setting_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  mainItem(String switchTitle, String mainButtonListTitle, String selectedButtonListItem, Function onTap) {
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
            value: true,
            onChanged: (newVal) {},
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
          ListTile(
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
        ],
      ),
    );
  }

  onReceiveNotificationNextTaskClick() async {
    await showCupertinoModalBottomSheet(
        context: context, builder: (context) => const ReceiveNotificationSettingModal());
  }

  onReceiveNotificationDailyOverviewClick() {
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);
    TimePickerUtils.pick(
      context,
      initialTime: initialTime,
      onTimeSelected: (selected) {},
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
                mainItem("Next tasks", "Receive notification", "X minutes before the task starts",
                    () => onReceiveNotificationNextTaskClick()),
                const SizedBox(height: 20),
                Text(
                  "DAILY OVERVIEW".toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                ),
                const SizedBox(height: 5),
                mainItem("Daily overview notification", "Receive notification", "At 10:00",
                    () => onReceiveNotificationDailyOverviewClick()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
