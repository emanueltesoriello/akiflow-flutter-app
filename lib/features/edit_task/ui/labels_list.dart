import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/bordered_input_view.dart';
import 'package:mobile/components/label/label_item.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/settings/ui/view/folder_item.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/label/label.dart';

class LabelsList extends StatefulWidget {
  final Function(Label selected) onSelect;
  final bool showHeaders;
  final bool showNoLabel;

  const LabelsList({
    Key? key,
    required this.showHeaders,
    required this.onSelect,
    required this.showNoLabel,
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
  void dispose() {
    super.dispose();
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

    List<Label> all = List.from(state.labels);

    List<Label> searchFiltered = all.where((label) {
      if (value.isEmpty) return true;

      if (label.type == "folder") {
        return true;
      }

      if (label.title == null || label.title!.isEmpty) {
        return false;
      }

      return (label.title!).toLowerCase().contains(value.toLowerCase());
    }).toList();

    List<Label> foldersAndLabels = searchFiltered;
    foldersAndLabels = foldersAndLabels.where((element) => element.deletedAt == null).toList();
    foldersAndLabels.removeWhere((element) => element.type != null && element.type == "section");

    List<dynamic> list = [];

    // add only if is folder or if parentId == null
    for (var label in foldersAndLabels) {
      if (label.type == "folder") {
        list.add(label);
      } else if (label.parentId == null) {
        list.add(label);
      }
    }

    int count = list.length;

    if (widget.showHeaders) count += 2;
    if (widget.showNoLabel) count += 1;

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
                hint: t.editTask.searchALabel,
                onChanged: (value) {
                  _searchNotifier.value = value;
                },
              ),
            );
          }

          index -= 2;
        }

        if (widget.showNoLabel) {
          if (index == 0) {
            Label noLabel = Label(
              title: t.editTask.removeLabel,
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

        Label label = list[index];

        if (label.type == "folder") {
          Label folder = label;
          List<Label>? labels = state.labels.where((element) => element.parentId == label.id).toList();

          return _folderRow(folder, labels, value);
        } else {
          return LabelItem(
            label,
            onTap: () {
              widget.onSelect(label);
            },
          );
        }
      },
    );
  }

  Widget _folderRow(Label folder, List<Label> labels, String searchValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          if (searchValue.isNotEmpty) {
            return const SizedBox();
          }

          return Row(
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

                  return GestureDetector(
                    onTap: () => toggleFolder(folder),
                    child: SvgPicture.asset(
                      open
                          ? "assets/images/icons/_common/chevron_up.svg"
                          : "assets/images/icons/_common/chevron_down.svg",
                      width: 16,
                      height: 16,
                      color: ColorsExt.grey3(context),
                    ),
                  );
                },
              ),
            ],
          );
        }),
        ValueListenableBuilder(
          valueListenable: _folderOpenNotifier,
          builder: (context, Map<Label, bool> folderOpen, child) {
            bool open = folderOpen[folder] ?? false;

            if (!open && searchValue.isEmpty) {
              return const SizedBox();
            }

            List<Label> searchFiltered = labels.where((label) {
              if (searchValue.isEmpty) return true;

              if (label.type == "folder") {
                return true;
              }

              if (label.title == null || label.title!.isEmpty) {
                return false;
              }

              return (label.title!).toLowerCase().contains(searchValue.toLowerCase());
            }).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: searchValue.isEmpty ? 16 : 0),
              itemCount: searchFiltered.length,
              itemBuilder: (context, index) {
                Label label = searchFiltered[index];

                return LabelItem(
                  label,
                  folder: searchValue.isEmpty ? null : folder,
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

  void toggleFolder(Label folder) {
    Map<Label, bool> openFolder = Map.from(_folderOpenNotifier.value);

    openFolder[folder] = !(openFolder[folder] ?? false);

    _folderOpenNotifier.value = openFolder;
  }
}
