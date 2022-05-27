import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';

enum GmailSyncMode {
  useAkiflowLabel(1),
  useStarToImport(0),
  doNothing(-1),
  askMeEveryTime(null);

  final int? key;
  const GmailSyncMode(this.key);

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
  final GmailSyncMode initialType;

  const GmaiImportTaskModal({Key? key, required this.initialType}) : super(key: key);

  @override
  State<GmaiImportTaskModal> createState() => _GmaiImportTaskModalState();
}

class _GmaiImportTaskModalState extends State<GmaiImportTaskModal> {
  late final ValueNotifier<GmailSyncMode> _selectedType;

  @override
  void initState() {
    _selectedType = ValueNotifier<GmailSyncMode>(widget.initialType);
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
              builder: (context, GmailSyncMode type, child) => ListView(
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
                    selected: type == GmailSyncMode.useAkiflowLabel,
                    onPressed: () {
                      Navigator.pop(context, GmailSyncMode.useAkiflowLabel);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.toImportTask.useStarToImport,
                    selected: type == GmailSyncMode.useStarToImport,
                    onPressed: () {
                      Navigator.pop(context, GmailSyncMode.useStarToImport);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.toImportTask.doNothing,
                    selected: type == GmailSyncMode.doNothing,
                    onPressed: () {
                      Navigator.pop(context, GmailSyncMode.doNothing);
                    },
                  ),
                  const SizedBox(height: 2),
                  _predefinedDateItem(
                    context,
                    text: t.settings.integrations.gmail.toImportTask.askMeEveryTime,
                    selected: type == GmailSyncMode.askMeEveryTime,
                    onPressed: () {
                      Navigator.pop(context, GmailSyncMode.askMeEveryTime);
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
