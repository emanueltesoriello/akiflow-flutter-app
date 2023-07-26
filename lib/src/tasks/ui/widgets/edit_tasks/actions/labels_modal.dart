import 'package:flutter/material.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/labels_list.dart';
import 'package:models/label/label.dart';

class LabelsModal extends StatefulWidget {
  final Function(Label) selectLabel;
  final bool showNoLabel;

  const LabelsModal({
    Key? key,
    required this.selectLabel,
    required this.showNoLabel,
  }) : super(key: key);

  @override
  State<LabelsModal> createState() => _LabelsModalState();
}

class _LabelsModalState extends State<LabelsModal> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimension.radiusM),
              topRight: Radius.circular(Dimension.radiusM),
            ),
          ),
          child: ScrollConfiguration(
            behavior: NoScrollBehav(),
            child: Column(
              children: [
                const SizedBox(height: Dimension.padding),
                const ScrollChip(),
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Dimension.padding),
                        child: LabelsList(
                          showHeaders: true,
                          onSelect: (label) {
                            widget.selectLabel(label);
                            Navigator.pop(context);
                          },
                          showNoLabel: widget.showNoLabel,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
