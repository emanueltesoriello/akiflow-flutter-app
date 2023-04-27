import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/models/next_event_notifications_models.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class ReceiveEventNotificationSettingModal extends StatefulWidget {
  final NextEventNotificationsModel selectedNextEventNotificationsModel;
  final Function(NextEventNotificationsModel value) onSelectedNextEventNotificationsModel;

  const ReceiveEventNotificationSettingModal({
    required this.selectedNextEventNotificationsModel,
    required this.onSelectedNextEventNotificationsModel,
    Key? key,
  }) : super(key: key);

  @override
  State<ReceiveEventNotificationSettingModal> createState() => _ReceiveEventNotificationSettingModalState();
}

class _ReceiveEventNotificationSettingModalState extends State<ReceiveEventNotificationSettingModal> {
  NextEventNotificationsModel _selectedNextEventNotificationsModel = NextEventNotificationsModel.d;

  @override
  void initState() {
    super.initState();
    _selectedNextEventNotificationsModel = widget.selectedNextEventNotificationsModel;
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
                          NextEventNotificationsModel.values.length,
                          (index) => _predefinedDateItem(context, text: NextEventNotificationsModel.values[index].title,
                              onPressed: () {
                            PreferencesRepository preferencesRepository = locator<PreferencesRepository>();
                            preferencesRepository
                                .setNextEventNotificationSetting(NextEventNotificationsModel.values[index]);
                            widget.onSelectedNextEventNotificationsModel(NextEventNotificationsModel.values[index]);
                            setState(() {
                              _selectedNextEventNotificationsModel = NextEventNotificationsModel.values[index];
                            });
                            locator<SyncCubit>().sync();
                          },
                              selected: NextEventNotificationsModel.values[index].minutesBeforeToStart ==
                                  _selectedNextEventNotificationsModel.minutesBeforeToStart),
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
