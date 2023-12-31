import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/src/base/models/next_task_notifications_models.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class ReceiveTaskNotificationSettingModal extends StatefulWidget {
  final NextTaskNotificationsModel selectedNextTaskNotificationsModel;
  final Function(NextTaskNotificationsModel value) onSelectedNextTaskNotificationsModel;

  const ReceiveTaskNotificationSettingModal({
    required this.selectedNextTaskNotificationsModel,
    required this.onSelectedNextTaskNotificationsModel,
    Key? key,
  }) : super(key: key);

  @override
  State<ReceiveTaskNotificationSettingModal> createState() => _ReceiveTaskNotificationSettingModalState();
}

class _ReceiveTaskNotificationSettingModalState extends State<ReceiveTaskNotificationSettingModal> {
  NextTaskNotificationsModel _selectedNextTaskNotificationsModel = NextTaskNotificationsModel.d;

  @override
  void initState() {
    super.initState();
    _selectedNextTaskNotificationsModel = widget.selectedNextTaskNotificationsModel;
  }

  Widget _predefinedDateItem(
    BuildContext context, {
    required String text,
    required Function() onPressed,
    required bool selected,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        color: selected ? ColorsExt.grey6(context) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      color: ColorsExt.grey2(context),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  topLeft: Radius.circular(Dimension.radiusM),
                  topRight: Radius.circular(Dimension.radius),
                ),
              ),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: Dimension.padding),
                  const ScrollChip(),
                  const SizedBox(height: Dimension.padding),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text('Send notifications ...',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorsExt.grey2(context))),
                        ),
                        const SizedBox(height: Dimension.padding),
                        ...List.generate(
                          NextTaskNotificationsModel.values.length,
                          (index) => _predefinedDateItem(context, text: NextTaskNotificationsModel.values[index].title,
                              onPressed: () {
                            PreferencesRepository preferencesRepository = locator<PreferencesRepository>();
                            preferencesRepository
                                .setNextTaskNotificationSetting(NextTaskNotificationsModel.values[index]);
                            widget.onSelectedNextTaskNotificationsModel(NextTaskNotificationsModel.values[index]);
                            setState(() {
                              _selectedNextTaskNotificationsModel = NextTaskNotificationsModel.values[index];
                            });
                            NotificationsService.scheduleNotificationsService(locator<PreferencesRepository>());
                          },
                              selected: NextTaskNotificationsModel.values[index].minutesBeforeToStart ==
                                  _selectedNextTaskNotificationsModel.minutesBeforeToStart),
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
