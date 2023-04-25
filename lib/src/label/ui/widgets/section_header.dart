import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';

enum SectionActionType { addTask, rename, delete }

class SectionHeaderItem extends StatelessWidget {
  const SectionHeaderItem(
    this.title, {
    Key? key,
    required this.taskCount,
    required this.listOpened,
    required this.onClick,
    required this.onCreateTask,
    required this.onRename,
    required this.onDelete,
    required this.showActionsMenu,
  }) : super(key: key);

  final String title;
  final int taskCount;
  final bool listOpened;
  final Function() onClick;
  final Function() onCreateTask;
  final Function() onRename;
  final Function() onDelete;
  final bool showActionsMenu;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: Dimension.padding, top: Dimension.padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.caption?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorsExt.akiflow(context),
                  ),
            ),
            const SizedBox(width: Dimension.paddingXS),
            Text(
              "($taskCount)",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorsExt.grey2_5(context),
                  ),
            ),
            const Spacer(),
            SvgPicture.asset(
              listOpened ? Assets.images.icons.common.chevronUpSVG : Assets.images.icons.common.chevronDownSVG,
              color: ColorsExt.grey3(context),
              width: Dimension.chevronIconSize,
              height: Dimension.chevronIconSize,
            ),
            const SizedBox(width: Dimension.paddingS),
            Builder(builder: (context) {
              if (!showActionsMenu) {
                return const SizedBox();
              }

              return Theme(
                data: Theme.of(context)
                    .copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
                child: PopupMenuButton<SectionActionType>(
                  padding: EdgeInsets.zero,
                  icon: SvgPicture.asset(
                    Assets.images.icons.common.ellipsisSVG,
                    color: ColorsExt.grey3(context),
                    width: Dimension.defaultIconSize,
                    height: Dimension.defaultIconSize,
                  ),
                  onSelected: (SectionActionType result) {
                    switch (result) {
                      case SectionActionType.addTask:
                        onCreateTask();
                        break;
                      case SectionActionType.rename:
                        onRename();
                        break;
                      case SectionActionType.delete:
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<SectionActionType>>[
                    PopupMenuItem<SectionActionType>(
                      value: SectionActionType.addTask,
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                        child: PopupMenuCustomItem(
                          iconAsset: Assets.images.icons.common.plusSquareSVG,
                          text: t.label.addTask,
                        ),
                      ),
                    ),
                    PopupMenuItem<SectionActionType>(
                      value: SectionActionType.rename,
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                        child: PopupMenuCustomItem(
                          iconAsset: Assets.images.icons.common.pencilSVG,
                          text: t.label.rename,
                        ),
                      ),
                    ),
                    PopupMenuItem<SectionActionType>(
                      value: SectionActionType.delete,
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                        child: PopupMenuCustomItem(
                          iconAsset: Assets.images.icons.common.trashSVG,
                          text: t.label.delete,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
