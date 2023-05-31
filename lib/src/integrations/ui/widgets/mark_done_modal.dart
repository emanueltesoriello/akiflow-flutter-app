import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/integrations_utils.dart';
import 'package:mobile/src/base/models/mark_as_done_type.dart';
import 'package:mobile/src/base/ui/widgets/base/action_button.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/calendar/ui/widgets/settings/calendar_settings_modal.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:models/account/account.dart';

class MarkDoneModal extends StatefulWidget {
  final MarkAsDoneType initialType;
  final Account account;
  final bool askBehavior;

  const MarkDoneModal({
    Key? key,
    required this.initialType,
    required this.account,
    this.askBehavior = false,
  }) : super(key: key);

  @override
  State<MarkDoneModal> createState() => _MarkDoneModalState();
}

class _MarkDoneModalState extends State<MarkDoneModal> {
  late MarkAsDoneType selectedType;
  bool rememberChoice = false;
  late String integrationTitle;

  @override
  void initState() {
    selectedType = widget.initialType;
    rememberChoice = false;
    integrationTitle = IntegrationsUtils.titleFromConnectorId(widget.account.connectorId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ColorsExt.background(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.padding),
            topRight: Radius.circular(Dimension.padding),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 12),
            const ScrollChip(),
            Padding(
              padding: const EdgeInsets.all(Dimension.padding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      integrationTitle == 'Gmail'
                          ? t.task.gmail.doYouAlsoWantTo
                          : t.settings.integrations.onMarkAsDone.behaviorOfToolOnMarkDone(tool: integrationTitle),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey800(context),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (integrationTitle == 'Gmail')
              Column(
                children: [
                  const SizedBox(height: 2),
                  _item(
                    context,
                    text: t.settings.integrations.onMarkAsDone.unstarTheEmail,
                    selected: selectedType == MarkAsDoneType.unstarTheEmail,
                    onPressed: () {
                      setState(() {
                        selectedType = MarkAsDoneType.unstarTheEmail;
                      });
                      if (!widget.askBehavior) {
                        Navigator.pop(context, MarkAsDoneType.unstarTheEmail);
                      }
                    },
                  ),
                ],
              ),
            if (integrationTitle != 'Gmail')
              Column(
                children: [
                  const SizedBox(height: 2),
                  _item(
                    context,
                    text: t.settings.integrations.onMarkAsDone.markAsDone(tool: integrationTitle),
                    selected: selectedType == MarkAsDoneType.markAsDone,
                    onPressed: () {
                      setState(() {
                        selectedType = MarkAsDoneType.markAsDone;
                      });
                      if (!widget.askBehavior) {
                        Navigator.pop(context, MarkAsDoneType.markAsDone);
                      }
                    },
                  ),
                ],
              ),
            const SizedBox(height: 2),
            _item(
              context,
              text: '${t.settings.integrations.onMarkAsDone.goTo} $integrationTitle',
              selected: selectedType == MarkAsDoneType.goTo,
              onPressed: () {
                setState(() {
                  selectedType = MarkAsDoneType.goTo;
                });
                if (!widget.askBehavior) {
                  Navigator.pop(context, MarkAsDoneType.goTo);
                }
              },
            ),
            const SizedBox(height: 2),
            _item(
              context,
              text: t.settings.integrations.onMarkAsDone.doNothing,
              selected: selectedType == MarkAsDoneType.doNothing,
              onPressed: () {
                setState(() {
                  selectedType = MarkAsDoneType.doNothing;
                });
                if (!widget.askBehavior) {
                  Navigator.pop(context, MarkAsDoneType.doNothing);
                }
              },
            ),
            if (!widget.askBehavior)
              Column(
                children: [
                  const SizedBox(height: 2),
                  _item(
                    context,
                    text: t.settings.integrations.onMarkAsDone.askMeEveryTime,
                    selected: selectedType == MarkAsDoneType.askMeEveryTime,
                    onPressed: () {
                      setState(() {
                        selectedType = MarkAsDoneType.askMeEveryTime;
                      });
                      Navigator.pop(context, MarkAsDoneType.askMeEveryTime);
                    },
                  ),
                ],
              ),
            if (widget.askBehavior)
              Column(
                children: [
                  const SizedBox(height: Dimension.padding),
                  const Separator(),
                  const SizedBox(height: Dimension.padding),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remember my choice',
                          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                color: ColorsExt.grey800(context),
                              ),
                        ),
                        SwitchButton(
                          value: rememberChoice,
                          onToggle: (value) {
                            setState(() {
                              rememberChoice = !rememberChoice;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: Dimension.padding, left: Dimension.padding, right: Dimension.padding),
                    child: ActionButton(
                      onPressed: () {
                        if (rememberChoice) {
                          var integrationsCubit = context.read<IntegrationsCubit>();
                          integrationsCubit.behaviorMarkAsDone(widget.account, selectedType);
                        }
                        Navigator.pop(context, selectedType);
                      },
                      color: ColorsExt.akiflow100(context),
                      splashColor: ColorsExt.akiflow200(context),
                      borderColor: ColorsExt.akiflow500(context),
                      child: Text('Confirm',
                          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorsExt.akiflow500(context),
                              )),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

Widget _item(
  BuildContext context, {
  required String text,
  required Function() onPressed,
  required bool selected,
}) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      color: selected ? ColorsExt.grey100(context) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
      height: 46,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: ColorsExt.grey800(context),
                  ),
            ),
          ),
        ],
      ),
    ),
  );
}
