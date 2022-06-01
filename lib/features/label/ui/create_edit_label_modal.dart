import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/bordered_input_view.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/button_list_label.dart';
import 'package:mobile/features/label/ui/colors_modal.dart';
import 'package:mobile/features/label/ui/folder_modal.dart';
import 'package:mobile/style/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';

class CreateEditLabelModal extends StatefulWidget {
  // Set to `false` to update the label after close the modal (edit label purpose)
  final bool isCreating;

  const CreateEditLabelModal({Key? key, required this.isCreating}) : super(key: key);

  @override
  State<CreateEditLabelModal> createState() => _CreateEditLabelModalState();
}

class _CreateEditLabelModalState extends State<CreateEditLabelModal> {
  final FocusNode titleFocus = FocusNode();

  @override
  void initState() {
    titleFocus.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Container(
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
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const ScrollChip(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            colorSelector(context),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: BorderedInputView(
                                  focus: titleFocus,
                                  initialValue: context.read<LabelCubit>().state.selectedLabel?.title,
                                  onChanged: (value) {
                                    context.read<LabelCubit>().titleChanged(value);
                                  },
                                  hint: "",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<LabelCubit, LabelCubitState>(
                          builder: (context, state) {
                            List<Label> folders = context
                                .read<LabelsCubit>()
                                .state
                                .labels
                                .where((label) => label.type == "folder" && label.deletedAt == null)
                                .toList();

                            Label label = state.selectedLabel!;

                            String? parentId = label.parentId;

                            int index = folders.indexWhere((element) => element.id == parentId);
                            Label? folder;

                            if (index != -1) {
                              folder = folders[index];
                            }

                            return ButtonListLabel(
                              title: folder?.title ?? t.label.noFolder,
                              position: ButtonListPosition.single,
                              leading: SizedBox(
                                height: 26,
                                width: 26,
                                child: Center(
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SvgPicture.asset(
                                        "assets/images/icons/_common/folder.svg",
                                        color: ColorsExt.grey2(context),
                                      )),
                                ),
                              ),
                              onPressed: () async {
                                LabelCubit labelCubit = context.read<LabelCubit>();

                                Label? folder = await showCupertinoModalBottomSheet(
                                  context: context,
                                  builder: (context) => FolderModal(
                                    folders: folders,
                                  ),
                                );

                                if (folder != null) {
                                  labelCubit.setFolder(folder);
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () {
                            if (widget.isCreating) {
                              Label label = context.read<LabelCubit>().state.selectedLabel!;
                              context.read<LabelsCubit>().addLabel(label);
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context, true);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorsExt.grey4(context),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: SvgPicture.asset("assets/images/icons/_common/checkmark.svg",
                                        color: ColorsExt.grey1(context)),
                                  ),
                                  const SizedBox(width: 11),
                                  BlocBuilder<LabelCubit, LabelCubitState>(
                                    builder: (context, state) {
                                      String text;

                                      if (state.selectedLabel?.id == null) {
                                        text = t.label.createLabel;
                                      } else {
                                        text = t.label.save;
                                      }

                                      return Text(
                                        text,
                                        style: TextStyle(fontSize: 15, color: ColorsExt.grey2(context)),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
    LabelCubit labelCubit = context.watch<LabelCubit>();

    Label label = labelCubit.state.selectedLabel!;

    Color iconBackground;
    Color iconForeground;

    if (label.color != null) {
      iconBackground = ColorsExt.getFromName(label.color!).withOpacity(0.1);
      iconForeground = ColorsExt.getFromName(label.color!);
    } else {
      iconBackground = ColorsExt.grey6(context);
      iconForeground = ColorsExt.grey2(context);
    }

    return InkWell(
      onTap: () async {
        LabelCubit labelCubit = context.read<LabelCubit>();

        String? rawColorName = await showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => const ColorsModal(),
        );

        if (rawColorName != null) {
          labelCubit.setColor(rawColorName);
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorsExt.grey4(context),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: iconBackground,
            ),
            height: 26,
            width: 26,
            child: Center(
              child: SvgPicture.asset(
                "assets/images/icons/_common/number.svg",
                color: iconForeground,
                height: 20,
                width: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
