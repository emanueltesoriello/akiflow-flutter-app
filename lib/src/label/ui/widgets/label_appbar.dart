import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/animated_chevron.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/label/ui/widgets/create_edit_label_modal.dart';
import 'package:mobile/src/label/ui/widgets/create_folder_modal.dart';
import 'package:mobile/src/settings/ui/widgets/settings_modal.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/labels_list.dart';
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

  _buildTitleAppbarSection(BuildContext context) {
    return Row(children: [
      Theme(
        data: Theme.of(context).copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
        child: PopupMenuButton(
          child: Row(
            children: [
              Text(label.title ?? t.noTitle,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey2(context))),
              const SizedBox(width: Dimension.paddingS),
              const AnimatedChevron(iconUp: true),
            ],
          ),
          itemBuilder: (BuildContext bc) {
            return [
              PopupMenuItem(
                child: Container(
                  //height: 200,
                  width: 200,
                  child: LabelsList(
                    showHeaders: false,
                    showNoLabel: false,
                    onSelect: (Label selected) {
                      context.read<LabelsCubit>().selectLabel(selected);
                      context.read<MainCubit>().changeHomeView(HomeViewType.label);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ];
          },
        ),
      ),
    ]);
  }

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
      titleWidget: _buildTitleAppbarSection(context),
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: iconBackground,
        ),
        height: Dimension.appBarLeadingIcon,
        width: Dimension.appBarLeadingIcon,
        child: Padding(
          padding: const EdgeInsets.all(Dimension.paddingXS),
          child: Center(
            child: SvgPicture.asset(
              Assets.images.icons.common.numberSVG,
              color: iconForeground,
            ),
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
              Assets.images.icons.common.ellipsisSVG,
              width: Dimension.appBarLeadingIcon,
              height: Dimension.appBarLeadingIcon,
              color: ColorsExt.grey2(context),
            ),
            onSelected: (LabelActions result) async {
              switch (result) {
                case LabelActions.edit:
                  context.read<LabelsCubit>().appbarActionEditLabel(context);
                  break;
                case LabelActions.order:
                  // context.read<LabelCubit>().toggleSorting();
                  break;
                case LabelActions.newSection:
                  context.read<LabelsCubit>().appbarActionNewSection(context);
                  break;
                case LabelActions.showDone:
                  context.read<LabelsCubit>().toggleShowDone();
                  break;
                case LabelActions.delete:
                  context.read<LabelsCubit>().appbarActionDeleteLabel(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<LabelActions>>[
              PopupMenuItem<LabelActions>(
                value: LabelActions.edit,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: PopupMenuCustomItem(
                    iconAsset: Assets.images.icons.common.pencilSVG,
                    text: t.label.editLabel,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.order,
                enabled: false,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: PopupMenuCustomItem(
                    iconAsset: Assets.images.icons.common.arrowUpArrowDownSVG,
                    text: t.label.sortComingSoon,
                    enabled: false,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.newSection,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: PopupMenuCustomItem(
                    iconAsset: Assets.images.icons.common.plusSVG,
                    text: t.label.newSection,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.showDone,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: PopupMenuCustomItem(
                    iconAsset: Assets.images.icons.common.checkDoneOutlineSVG,
                    text: showDone ? t.label.hideDone : t.label.showDone,
                  ),
                ),
              ),
              PopupMenuItem<LabelActions>(
                value: LabelActions.delete,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: PopupMenuCustomItem(
                    iconAsset: Assets.images.icons.common.trashSVG,
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
