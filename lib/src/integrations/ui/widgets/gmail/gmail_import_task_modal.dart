import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:models/integrations/gmail.dart';

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
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: _selectedType,
          builder: (context, GmailSyncMode type, child) => ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: Dimension.padding),
              const ScrollChip(),
              Padding(
                padding: const EdgeInsets.all(Dimension.padding),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.settings.integrations.gmail.toImportTask.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              // DEPRECATED
              /*const SizedBox(height: 2),
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
              ),*/
              const SizedBox(height: 50),
            ],
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
