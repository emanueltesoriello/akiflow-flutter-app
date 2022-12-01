import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
import 'package:models/task/task.dart';

class TitleWidget extends StatelessWidget {
  final Task task;

  const TitleWidget(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? text = task.title;

    if (text == null || text.isEmpty) {
      text = t.noTitle;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        constraints: const BoxConstraints(minHeight: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1.3,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: task.statusType == TaskStatusType.deleted || task.deletedAt != null
                      ? ColorsExt.grey3(context)
                      : ColorsExt.grey1(context),
                ),
              ),
            ),
            isGoal(context),
          ],
        ),
      ),
    );
  }

  Widget isGoal(BuildContext context) {
    if (task.isDailyGoal) {
      return TagBox(
        icon: "assets/images/icons/_common/target_active.svg",
        isBig: true,
        isSquare: true,
        backgroundColor: Colors.transparent,
        active: task.dailyGoal != null && task.dailyGoal == 1,
      );
    }

    return const SizedBox();
  }
}
