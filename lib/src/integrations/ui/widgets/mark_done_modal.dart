import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/models/mark_as_done_type.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class MarkDoneModal extends StatefulWidget {
  final MarkAsDoneType initialType;
  final String integrationTitle;

  const MarkDoneModal({
    Key? key,
    required this.initialType,
    required this.integrationTitle,
  }) : super(key: key);

  @override
  State<MarkDoneModal> createState() => _MarkDoneModalState();
}

class _MarkDoneModalState extends State<MarkDoneModal> {
  late final ValueNotifier<MarkAsDoneType> _selectedType;

  @override
  void initState() {
    _selectedType = ValueNotifier<MarkAsDoneType>(widget.initialType);
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
        child: ValueListenableBuilder(
          valueListenable: _selectedType,
          builder: (context, MarkAsDoneType type, child) => ListView(
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
                        t.settings.integrations.onMarkAsDone.behaviorOfToolOnMarkDone(tool: widget.integrationTitle),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey800(context),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.integrationTitle == 'Gmail')
                Column(
                  children: [
                    const SizedBox(height: 2),
                    _item(
                      context,
                      text: t.settings.integrations.onMarkAsDone.unstarTheEmail,
                      selected: type == MarkAsDoneType.unstarTheEmail,
                      onPressed: () {
                        Navigator.pop(context, MarkAsDoneType.unstarTheEmail);
                      },
                    ),
                  ],
                ),
              if (widget.integrationTitle != 'Gmail')
                Column(
                  children: [
                    const SizedBox(height: 2),
                    _item(
                      context,
                      text: t.settings.integrations.onMarkAsDone.markAsDone(tool: widget.integrationTitle),
                      selected: type == MarkAsDoneType.markAsDone,
                      onPressed: () {
                        Navigator.pop(context, MarkAsDoneType.markAsDone);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 2),
              _item(
                context,
                text: '${t.settings.integrations.onMarkAsDone.goTo} ${widget.integrationTitle}',
                selected: type == MarkAsDoneType.goTo,
                onPressed: () {
                  Navigator.pop(context, MarkAsDoneType.goTo);
                },
              ),
              const SizedBox(height: 2),
              _item(
                context,
                text: t.settings.integrations.onMarkAsDone.doNothing,
                selected: type == MarkAsDoneType.doNothing,
                onPressed: () {
                  Navigator.pop(context, MarkAsDoneType.doNothing);
                },
              ),
              const SizedBox(height: 2),
              _item(
                context,
                text: t.settings.integrations.onMarkAsDone.askMeEveryTime,
                selected: type == MarkAsDoneType.askMeEveryTime,
                onPressed: () {
                  Navigator.pop(context, MarkAsDoneType.askMeEveryTime);
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
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
