import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/popup_menu_item.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/create_edit_label_modal.dart';
import 'package:mobile/style/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';

enum LabelActions { edit, order, newSection, showDone, delete }

class LabelAppBar extends StatelessWidget {
  final Label label;

  const LabelAppBar({
    Key? key,
    required this.label,
  }) : super(key: key);

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
      title: label.title ?? t.task.noTitle,
      showSyncButton: false,
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
      actions: [
        PopupMenuButton<LabelActions>(
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
                LabelCubit currentLabelCubit = context.read<LabelCubit>();

                // Use a reference to the current label to update ui after updated the label
                LabelCubit labelUpdateCubit = LabelCubit(label, labelsCubit: labelsCubit);

                bool? update = await showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => BlocProvider(
                    key: ObjectKey(label),
                    create: (context) => labelUpdateCubit,
                    child: const CreateEditLabelModal(),
                  ),
                );

                if (update != null && update == true) {
                  currentLabelCubit.saveLabel(labelUpdateCubit.state.selectedLabel!);
                }

                break;
              case LabelActions.order:
                // TODO: Handle this case.
                break;
              case LabelActions.newSection:
                // TODO: Handle this case.
                break;
              case LabelActions.showDone:
                // TODO: Handle this case.
                break;
              case LabelActions.delete:
                // TODO: Handle this case.
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
              height: 40,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: PopupMenuCustomItem(
                  iconAsset: "assets/images/icons/_common/arrow_up_arrow_down.svg",
                  text: t.label.order,
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
                  text: t.label.showDone,
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
        )
      ],
    );
  }
}
