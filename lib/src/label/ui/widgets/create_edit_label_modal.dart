import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/bordered_input_view.dart';
import 'package:mobile/src/base/ui/widgets/base/button_list.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/label/ui/widgets/button_list_label.dart';
import 'package:mobile/src/label/ui/widgets/colors_modal.dart';
import 'package:mobile/src/label/ui/widgets/folder_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';

/// Return new [Label] updated
class CreateEditLabelModal extends StatefulWidget {
  /// Set to `false` to update the label after close the modal (edit label purpose)
  final Label label;
  final List<Label> folders;

  const CreateEditLabelModal({
    Key? key,
    required this.label,
    required this.folders,
  }) : super(key: key);

  @override
  State<CreateEditLabelModal> createState() => _CreateEditLabelModalState();
}

class _CreateEditLabelModalState extends State<CreateEditLabelModal> {
  final FocusNode titleFocus = FocusNode();
  late final ValueNotifier<Label> _labelUpdated;

  @override
  void initState() {
    _labelUpdated = ValueNotifier<Label>(widget.label);
    titleFocus.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimension.padding),
                topRight: Radius.circular(Dimension.padding),
              ),
              child: Container(
                color: Theme.of(context).backgroundColor,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  bottom: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                    child: Column(
                      children: [
                        const SizedBox(height: Dimension.padding),
                        const ScrollChip(),
                        const SizedBox(height: Dimension.padding),
                        Row(
                          children: [
                            colorSelector(context),
                            const SizedBox(width: Dimension.paddingS),
                            Expanded(
                              child: SizedBox(
                                height: Dimension.bigIconSize,
                                child: BorderedInputView(
                                  focus: titleFocus,
                                  initialValue: widget.label.title ?? "",
                                  onChanged: (value) {
                                    _labelUpdated.value = _labelUpdated.value.copyWith(title: value);
                                  },
                                  hint: "",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimension.paddingM),
                        ValueListenableBuilder(
                          valueListenable: _labelUpdated,
                          builder: (context, Label value, child) {
                            String? parentId = value.parentId;

                            int index = widget.folders.indexWhere((element) => element.id == parentId);
                            Label? folder;

                            if (index != -1) {
                              folder = widget.folders[index];
                            }

                            return ButtonListLabel(
                              title: folder?.title ?? t.label.noFolder,
                              position: ButtonListPosition.single,
                              leading: Center(
                                child: SizedBox(
                                    height: Dimension.defaultIconSize,
                                    width: Dimension.defaultIconSize,
                                    child: SvgPicture.asset(
                                      Assets.images.icons.common.folderSVG,
                                      color: ColorsExt.grey800(context),
                                    )),
                              ),
                              onPressed: () async {
                                List<Label> foldersWithNoFolderItem = List.from(widget.folders);

                                foldersWithNoFolderItem.insert(0, Label(id: null, title: t.label.noFolder));

                                Label? folder = await showCupertinoModalBottomSheet(
                                  context: context,
                                  builder: (context) => FolderModal(
                                    folders: foldersWithNoFolderItem,
                                  ),
                                );

                                _labelUpdated.value = _labelUpdated.value.copyWith(parentId: Nullable(folder?.id));
                              },
                            );
                          },
                        ),
                        const SizedBox(height: Dimension.paddingM),
                        OutlinedButton(
                          style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                              backgroundColor: MaterialStateProperty.all((Colors.transparent)),
                              minimumSize: MaterialStateProperty.all(const Size(double.infinity, 45))),
                          onPressed: () {
                            Navigator.pop(context, _labelUpdated.value);
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: SvgPicture.asset(Assets.images.icons.common.checkmarkSVG,
                                      color: ColorsExt.grey900(context)),
                                ),
                                const SizedBox(width: 11),
                                ValueListenableBuilder(
                                  valueListenable: _labelUpdated,
                                  builder: (context, Label value, child) {
                                    String text;

                                    if (value.id == null) {
                                      text = t.label.createLabel;
                                    } else {
                                      text = t.label.save;
                                    }

                                    return Text(
                                      text,
                                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                            color: ColorsExt.grey800(context),
                                          ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimension.padding),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget colorSelector(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _labelUpdated,
      builder: (context, Label label, child) {
        Color iconBackground;
        Color iconForeground;

        if (label.color != null) {
          iconBackground = ColorsExt.getLightColorFromName(label.color!);
          iconForeground = ColorsExt.getFromName(label.color!);
        } else {
          iconBackground = ColorsExt.grey100(context);
          iconForeground = ColorsExt.grey800(context);
        }

        return InkWell(
          onTap: () async {
            String? rawColorName = await showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => const ColorsModal(),
            );

            if (rawColorName != null) {
              _labelUpdated.value = _labelUpdated.value.copyWith(color: rawColorName);
            }
          },
          child: Container(
            width: Dimension.bigIconSize,
            height: Dimension.bigIconSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorsExt.grey300(context),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(Dimension.radius),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: iconBackground,
                ),
                height: Dimension.mediumIconSize,
                width: Dimension.mediumIconSize,
                child: Center(
                  child: SvgPicture.asset(
                    Assets.images.icons.common.numberSVG,
                    color: iconForeground,
                    height: Dimension.defaultIconSize,
                    width: Dimension.defaultIconSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
