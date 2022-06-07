import 'package:flutter/material.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/features/edit_task/ui/labels_list.dart';
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
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 12),
                const ScrollChip(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: LabelsList(
                    showHeaders: true,
                    onSelect: widget.selectLabel,
                    showNoLabel: widget.showNoLabel,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
