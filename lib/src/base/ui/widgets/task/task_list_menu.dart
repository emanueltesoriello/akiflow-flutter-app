import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';

enum TaskListMenuAction { sort, filter }

class TaskListMenu extends StatelessWidget {
  const TaskListMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
      child: PopupMenuButton<TaskListMenuAction>(
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        icon: SvgPicture.asset(
          Assets.images.icons.common.ellipsisSVG,
          width: Dimension.defaultIconSize,
          height: Dimension.defaultIconSize,
          color: ColorsExt.grey800(context),
        ),
        onSelected: (TaskListMenuAction result) {
          switch (result) {
            case TaskListMenuAction.sort:
              // TODO: implement sort
              break;
            case TaskListMenuAction.filter:
              // TODO: implement filter
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<TaskListMenuAction>>[
          PopupMenuItem<TaskListMenuAction>(
            value: TaskListMenuAction.sort,
            enabled: false,
            padding: EdgeInsets.zero,
            height: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingSM),
              child: Text(t.comingSoon.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w500)),
            ),
          ),
          PopupMenuItem<TaskListMenuAction>(
            value: TaskListMenuAction.sort,
            padding: EdgeInsets.zero,
            height: 40,
            enabled: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingSM),
              child: PopupMenuCustomItem(
                iconAsset: Assets.images.icons.common.arrowUpArrowDownSVG,
                text: t.task.sort,
                enabled: false,
              ),
            ),
          ),
          PopupMenuItem<TaskListMenuAction>(
            value: TaskListMenuAction.filter,
            padding: EdgeInsets.zero,
            height: 40,
            enabled: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingSM),
              child: PopupMenuCustomItem(
                iconAsset: Assets.images.icons.common.lineHorizontal3DecreaseSVG,
                text: t.task.filter,
                enabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
