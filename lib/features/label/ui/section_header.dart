import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/popup_menu_item.dart';
import 'package:mobile/style/colors.dart';

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
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ColorsExt.grey5(context),
              width: 1,
            ),
          ),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06), // shadow color
            ),
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 6,
              color: ColorsExt.grey7(context),
              // background color
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context))),
            const SizedBox(width: 4),
            Text("($taskCount)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context))),
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

              return PopupMenuButton<SectionActionType>(
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
              );
            })
          ],
        ),
      ),
    );
  }
}
