import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
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
        height: 42,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context))),
            const SizedBox(width: 4),
            Text("($taskCount)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.grey2_5(context))),
            const Spacer(),
            SvgPicture.asset(
              listOpened
                  ? "assets/images/icons/_common/chevron_up.svg"
                  : "assets/images/icons/_common/chevron_down.svg",
              color: ColorsExt.grey3(context),
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
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
                    "assets/images/icons/_common/ellipsis.svg",
                    color: ColorsExt.grey3(context),
                    width: 20,
                    height: 20,
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
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: PopupMenuCustomItem(
                          iconAsset: "assets/images/icons/_common/plus_square.svg",
                          text: t.label.addTask,
                        ),
                      ),
                    ),
                    PopupMenuItem<SectionActionType>(
                      value: SectionActionType.rename,
                      padding: EdgeInsets.zero,
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: PopupMenuCustomItem(
                          iconAsset: "assets/images/icons/_common/pencil.svg",
                          text: t.label.rename,
                        ),
                      ),
                    ),
                    PopupMenuItem<SectionActionType>(
                      value: SectionActionType.delete,
                      padding: EdgeInsets.zero,
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: PopupMenuCustomItem(
                          iconAsset: "assets/images/icons/_common/trash.svg",
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