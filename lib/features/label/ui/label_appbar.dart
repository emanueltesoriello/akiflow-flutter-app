import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/create_edit_label_modal.dart';
import 'package:mobile/features/label/ui/create_edit_section_modal.dart';
import 'package:mobile/features/label/ui/delete_label_dialog.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:uuid/uuid.dart';

enum LabelActions { edit, order, newSection, showDone, delete }

class LabelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Label label;
  final bool showDone;

  const LabelAppBar({
    Key? key,
    required this.label,
    required this.showDone,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    Color iconBackground;
    Color iconForeground;

    if (label.color != null) {
      iconBackground = ColorsExt.getFromName(label.color!).withOpacity(0.1);
      iconForeground = ColorsExt.getFromName(label.color!);
    } else {
      iconBackground = ColorsExt.grey6(context);
      iconForeground = ColorsExt.grey2(context);
    }

    return AppBarComp(
      title: label.title ?? t.noTitle,
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: iconBackground,
        ),
        height: 26,
        width: 26,
        child: Center(
          child: SvgPicture.asset(
            "assets/images/icons/_common/number.svg",
            width: 15,
            height: 15,
            color: iconForeground,
          ),
        ),
      ),
      showSyncButton: true,
      actions: [
        Theme(
          data: Theme.of(context).copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
          child: PopupMenuButton<LabelActions>(
            padding: const EdgeInsets.all(0),
            icon: SvgPicture.asset(
              "assets/images/icons/_common/ellipsis.svg",
              width: 22,
              height: 22,
              color: ColorsExt.grey3(context),
            ),
            onSelected: (LabelActions result) async {
              switch (result) {
                case LabelActions.edit:
                  LabelsCubit labelsCubit = context.read<LabelsCubit>();

                  List<Label> folders = labelsCubit.state.labels
                      .where((label) => label.type == "folder" && label.deletedAt == null)
                      .toList();

                  Label? updated = await showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => CreateEditLabelModal(
                      label: labelsCubit.state.selectedLabel!,
                      folders: folders,
                    ),
                  );

                  if (updated != null) {
                    labelsCubit.saveLabel(updated);
                  }
                  break;
                case LabelActions.order:
                  // context.read<LabelCubit>().toggleSorting();
                  break;
                case LabelActions.newSection:
                  Label currentLabel = context.read<LabelsCubit>().state.selectedLabel!;
                  Label newSection = Label(id: const Uuid().v4(), parentId: currentLabel.id!, type: "section");

                  LabelsCubit labelsCubit = context.read<LabelsCubit>();

                  Label? section = await showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => CreateEditSectionModal(initialSection: newSection),
                  );

                  if (section != null) {
                    labelsCubit.addSectionToLocalUi(section);
                    labelsCubit.addLabel(section, labelType: LabelType.section);
                  }

                  break;
                case LabelActions.showDone:
                  context.read<LabelsCubit>().toggleShowDone();
                  break;
                case LabelActions.delete:
                  LabelsCubit labelsCubit = context.read<LabelsCubit>();
                  MainCubit mainCubit = context.read<MainCubit>();

                  Label labelToDelete = labelsCubit.state.selectedLabel!;

                  showDialog(
                      context: context,
                      builder: (context) => DeleteLabelDialog(
                            labelToDelete,
                            justDeleteTheLabelClick: () {
                              labelsCubit.delete();

                              Label deletedLabel = labelsCubit.state.selectedLabel!;
                              labelsCubit.updateLabel(deletedLabel);

                              mainCubit.changeHomeView(HomeViewType.inbox);
                            },
                            markAllTasksAsDoneClick: () {
                              labelsCubit.delete(markTasksAsDone: true);

                              Label deletedLabel = labelsCubit.state.selectedLabel!;
                              labelsCubit.updateLabel(deletedLabel);

                              mainCubit.changeHomeView(HomeViewType.inbox);
                            },
                          ));

                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<LabelActions>>[
              PopupMenuItem<LabelActions>(
                value: LabelActions.edit,
                height: 40,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PopupMenuCustomItem(
                    iconAsset: "assets/images/icons/_common/pencil.svg",
                    text: t.label.editLabel,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.order,
                enabled: false,
                height: 40,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PopupMenuCustomItem(
                    iconAsset: "assets/images/icons/_common/arrow_up_arrow_down.svg",
                    text: t.label.sortComingSoon,
                    enabled: false,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.newSection,
                height: 40,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PopupMenuCustomItem(
                    iconAsset: "assets/images/icons/_common/plus.svg",
                    text: t.label.newSection,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.showDone,
                height: 40,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PopupMenuCustomItem(
                    iconAsset: "assets/images/icons/_common/Check-done-outline.svg",
                    text: showDone ? t.label.hideDone : t.label.showDone,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.delete,
                height: 40,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PopupMenuCustomItem(
                    iconAsset: "assets/images/icons/_common/trash.svg",
                    text: t.label.deleteLabel,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
