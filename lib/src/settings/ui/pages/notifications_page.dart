import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  buttonElement() {
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: SwitchListTile(
                    value: true,
                    onChanged: (newVal) {},
                    activeColor: ColorsExt.akiflow(context),
                    title: Text(
                      "New task",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 17,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: ListTile(
                    title: Text(
                      "Receive notifications",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                    subtitle: Text(
                      "Receive notifications",
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(color: ColorsExt.grey3(context), fontWeight: FontWeight.normal),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                buttonElement(),
                const SizedBox(height: 20),
                Text(
                  "DAILY OVERVIEW".toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                ),
                buttonElement(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
