import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/components/base/scroll_chip.dart';
import 'package:mobile/features/integrations/cubit/gmail_mark_as_done_type.dart';
import 'package:mobile/common/style/colors.dart';

class GmailMarkDoneModal extends StatefulWidget {
  final GmailMarkAsDoneType initialType;

  const GmailMarkDoneModal({Key? key, required this.initialType}) : super(key: key);

  @override
  State<GmailMarkDoneModal> createState() => _GmailMarkDoneModalState();
}

class _GmailMarkDoneModalState extends State<GmailMarkDoneModal> {
  late final ValueNotifier<GmailMarkAsDoneType> _selectedType;

  @override
  void initState() {
    _selectedType = ValueNotifier<GmailMarkAsDoneType>(widget.initialType);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: ValueListenableBuilder(
              valueListenable: _selectedType,
              builder: (context, GmailMarkAsDoneType type, child) => ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 12),
                  const ScrollChip(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.settings.integrations.gmail.onMarkAsDone.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.onMarkAsDone.unstarTheEmail,
                    selected: type == GmailMarkAsDoneType.unstarTheEmail,
                    onPressed: () {
                      Navigator.pop(context, GmailMarkAsDoneType.unstarTheEmail);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.onMarkAsDone.goToGmail,
                    selected: type == GmailMarkAsDoneType.goToGmail,
                    onPressed: () {
                      Navigator.pop(context, GmailMarkAsDoneType.goToGmail);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.onMarkAsDone.doNothing,
                    selected: type == GmailMarkAsDoneType.doNothing,
                    onPressed: () {
                      Navigator.pop(context, GmailMarkAsDoneType.doNothing);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.onMarkAsDone.askMeEveryTime,
                    selected: type == GmailMarkAsDoneType.askMeEveryTime,
                    onPressed: () {
                      Navigator.pop(context, GmailMarkAsDoneType.askMeEveryTime);
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 17,
                color: ColorsExt.grey2(context),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
