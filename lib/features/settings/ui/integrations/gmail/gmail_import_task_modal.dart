import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';

enum GmailImportTaskType {
  useAkiflowLabel(1),
  useStarToImport(0),
  doNothing(-1),
  askMeEveryTime(null);

  final int? key;
  const GmailImportTaskType(this.key);

  static String titleFromKey(int? key) {
    switch (key) {
      case 1:
        return t.settings.integrations.gmail.toImportTask.useAkiflowLabel;
      case 0:
        return t.settings.integrations.gmail.toImportTask.useStarToImport;
      case -1:
        return t.settings.integrations.gmail.toImportTask.doNothing;
      default:
        return t.settings.integrations.gmail.toImportTask.askMeEveryTime;
    }
  }
}

class GmaiImportTaskModal extends StatefulWidget {
  final GmailImportTaskType initialType;

  const GmaiImportTaskModal({Key? key, required this.initialType}) : super(key: key);

  @override
  State<GmaiImportTaskModal> createState() => _GmaiImportTaskModalState();
}

class _GmaiImportTaskModalState extends State<GmaiImportTaskModal> {
  late final ValueNotifier<GmailImportTaskType> _selectedType;

  @override
  void initState() {
    _selectedType = ValueNotifier<GmailImportTaskType>(widget.initialType);
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
              builder: (context, GmailImportTaskType type, child) => ListView(
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
                            t.settings.integrations.gmail.toImportTask.title,
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
                    text: t.settings.integrations.gmail.toImportTask.useAkiflowLabel,
                    selected: type == GmailImportTaskType.useAkiflowLabel,
                    onPressed: () {
                      Navigator.pop(context, GmailImportTaskType.useAkiflowLabel);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.toImportTask.useStarToImport,
                    selected: type == GmailImportTaskType.useStarToImport,
                    onPressed: () {
                      Navigator.pop(context, GmailImportTaskType.useStarToImport);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.toImportTask.doNothing,
                    selected: type == GmailImportTaskType.doNothing,
                    onPressed: () {
                      Navigator.pop(context, GmailImportTaskType.doNothing);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.toImportTask.askMeEveryTime,
                    selected: type == GmailImportTaskType.askMeEveryTime,
                    onPressed: () {
                      Navigator.pop(context, GmailImportTaskType.askMeEveryTime);
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
