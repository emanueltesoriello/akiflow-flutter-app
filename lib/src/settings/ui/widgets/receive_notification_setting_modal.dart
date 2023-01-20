import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class ReceiveNotificationSettingModal extends StatefulWidget {
  const ReceiveNotificationSettingModal({Key? key}) : super(key: key);

  @override
  State<ReceiveNotificationSettingModal> createState() => _ReceiveNotificationSettingModalState();
}

class _ReceiveNotificationSettingModalState extends State<ReceiveNotificationSettingModal> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).backgroundColor,
        child: AnimatedSize(
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 400),
          child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 12),
                  const ScrollChip(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Send notifications ...',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorsExt.grey2(context))),
                        const SizedBox(height: 12),
                        ...List.generate(
                          NextTaskNotificationsModel.values.length,
                          (index) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(NextTaskNotificationsModel.values[index].title,
                                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                                      fontSize: 17,
                                      color: ColorsExt.grey2(context),
                                    )),
                          ),
                        ).reversed,
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }
}
