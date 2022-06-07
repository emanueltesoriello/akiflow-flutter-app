import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/popup_menu_item.dart';
import 'package:mobile/style/colors.dart';

enum TaskListMenuAction { sort, filter }

class TaskListMenu extends StatelessWidget {
  const TaskListMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
      child: PopupMenuButton<TaskListMenuAction>(
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          "assets/images/icons/_common/ellipsis.svg",
          width: 24,
          height: 24,
          color: ColorsExt.grey2(context),
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(t.comingSoon.toUpperCase(),
                  style: TextStyle(color: ColorsExt.grey3(context), fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ),
          PopupMenuItem<TaskListMenuAction>(
            value: TaskListMenuAction.sort,
            padding: EdgeInsets.zero,
            height: 40,
            enabled: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: PopupMenuCustomItem(
                iconAsset: "assets/images/icons/_common/arrow_up_arrow_down.svg",
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: PopupMenuCustomItem(
                iconAsset: "assets/images/icons/_common/line_horizontal_3_decrease.svg",
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
