import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/bordered_input_view.dart';
import 'package:mobile/components/label/label_item.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/settings/ui/view/folder_item.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/label_ext.dart';
import 'package:models/label/label.dart';

class LabelsList extends StatefulWidget {
  final Function(Label selected) onSelect;
  final bool showHeaders;
  final String? initialSelectedListId;

  const LabelsList({
    Key? key,
    required this.showHeaders,
    required this.onSelect,
    this.initialSelectedListId,
  }) : super(key: key);

  @override
  State<LabelsList> createState() => _LabelsListState();
}

class _LabelsListState extends State<LabelsList> {
  final ValueNotifier<String> _searchNotifier = ValueNotifier<String>('');
  final ValueNotifier<Map<Label, bool>> _folderOpenNotifier = ValueNotifier<Map<Label, bool>>({});

  @override
  void initState() {
    List<Label> allItems = context.read<LabelsCubit>().state.labels;
    List<Label> folders = allItems.where((element) => element.type == "folder").toList();

    Map<Label, bool> folderOpen = {};

    for (var folder in folders) {
      folderOpen[folder] = false;
    }

    _folderOpenNotifier.value = folderOpen;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showHeaders) {
      return ValueListenableBuilder<String>(
          valueListenable: _searchNotifier, builder: (context, value, child) => content(context, value: value));
    } else {
      return content(context);
    }
  }

  Widget content(BuildContext context, {String value = ""}) {
    LabelsCubitState state = context.watch<LabelsCubit>().state;

    if (state.loading) {
      return const Center(
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    List<Label> labels = List.from(state.labels);

    labels = LabelExt.filter(labels);

    labels = labels.where((element) => element.deletedAt == null).toList();

    labels = labels.where((label) {
      if (value.isEmpty) return true;

      if (label.type == "folder" || label.type == "section") {
        return true;
      }

      if (label.title == null || label.title!.isEmpty) {
        return false;
      }

      return (label.title!).toLowerCase().contains(value.toLowerCase());
    }).toList();

    List<Label> folders = labels.where((element) => element.type == "folder").toList();
    List<Label> labelsWithoutFolder = labels
        .where((element) => element.type != "folder" && element.type != "section" && element.parentId == null)
        .toList();

    labelsWithoutFolder = labelsWithoutFolder.where((label) {
      if (value.isEmpty) return true;

      if (label.title == null || label.title!.isEmpty) {
        return false;
      }

      return (label.title!).toLowerCase().contains(value.toLowerCase());
    }).toList();

    Map<Label?, List<Label>> folderLabels = {};

    // Add to top all the labels which don't have parentId
    folderLabels[null] = labelsWithoutFolder;

    for (var folder in folders) {
      List<Label> labelsForFolder = labels.where((Label label) => label.parentId == folder.id).toList();
      folderLabels[folder] = labelsForFolder;
    }

    int count = folderLabels.length;

    if (widget.showHeaders) count += 2;
    if (widget.initialSelectedListId != null) count += 1;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        if (widget.showHeaders) {
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

          index -= 2;
        }

        if (widget.initialSelectedListId != null) {
          if (index == 0) {
            if (widget.initialSelectedListId == null) {
              return const SizedBox();
            }

            Label noLabel = Label(
              title: t.editTask.noLabel,
            );

            return LabelItem(
              noLabel,
              onTap: () {
                widget.onSelect(noLabel);
              },
            );
          }

          index -= 1;
        }

        Label? folder = folderLabels.keys.elementAt(index);
        List<Label> labels = folderLabels.values.elementAt(index);

        if (folder == null) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: labels.length,
            itemBuilder: (context, index) {
              Label label = labels[index];

              return LabelItem(
                label,
                onTap: () {
                  widget.onSelect(label);
                },
              );
            },
          );
        } else {
          List<Label>? labels = folderLabels[folder] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FolderItem(
                      folder,
                      onTap: () {
                        toggleFolder(folder);
                      },
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _folderOpenNotifier,
                    builder: (context, Map<Label, bool> folderOpen, child) {
                      bool open = folderOpen[folder] ?? false;

                      return SvgPicture.asset(
                        open
                            ? "assets/images/icons/_common/chevron_up.svg"
                            : "assets/images/icons/_common/chevron_down.svg",
                        width: 16,
                        height: 16,
                        color: ColorsExt.grey3(context),
                      );
                    },
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: _folderOpenNotifier,
                builder: (context, Map<Label, bool> folderOpen, child) {
                  bool open = folderOpen[folder] ?? false;

                  if (!open) {
                    return const SizedBox();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: labels.length,
                    itemBuilder: (context, index) {
                      Label label = labels[index];

                      return LabelItem(
                        label,
                        onTap: () {
                          widget.onSelect(label);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  void toggleFolder(Label folder) {
    Map<Label, bool> openFolder = Map.from(_folderOpenNotifier.value);

    openFolder[folder] = !(openFolder[folder] ?? false);

    _folderOpenNotifier.value = openFolder;
  }
}
