import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/components/base/search.dart';
import 'package:mobile/components/task/label_item.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/label_ext.dart';
import 'package:models/label/label.dart';

class LabelsModal extends StatefulWidget {
  final Function(Label) selectLabel;

  const LabelsModal({
    Key? key,
    required this.selectLabel,
  }) : super(key: key);

  @override
  State<LabelsModal> createState() => _LabelsModalState();
}

class _LabelsModalState extends State<LabelsModal> {
  final ValueNotifier<String> _searchNotifier = ValueNotifier<String>('');

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
                const SizedBox(height: 12),
                BlocBuilder<LabelsCubit, LabelsCubitState>(
                  builder: (context, state) {
                    List<Label> labels = state.labels.toList();

                    labels = LabelExt.filter(labels);

                    return ValueListenableBuilder<String>(
                        valueListenable: _searchNotifier,
                        builder: (context, value, child) {
                          List<Label> labelsFiltered = labels.toList();

                          labelsFiltered = labelsFiltered.where((label) {
                            if (label.title == null || label.title!.isEmpty) {
                              return false;
                            }

                            return (label.title!).toLowerCase().contains(value.toLowerCase());
                          }).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: labelsFiltered.length + 3,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    t.editTask.assignLabel,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: ColorsExt.grey2(context),
                                    ),
                                  ),
                                );
                              }

                              if (index == 1) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: BorderedInputView(
                                    hint: t.editTask.createOrSearchALabel,
                                    onChanged: (value) {
                                      _searchNotifier.value = value;
                                    },
                                  ),
                                );
                              }

                              if (index == 2) {
                                Label noLabel = Label(
                                  title: t.editTask.noLabel,
                                );

                                return LabelItem(
                                  noLabel,
                                  onTap: () {
                                    widget.selectLabel(noLabel);
                                    Navigator.pop(context);
                                  },
                                );
                              }

                              index -= 3;

                              Label label = labels[index];

                              return LabelItem(
                                label,
                                onTap: () {
                                  widget.selectLabel(label);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
