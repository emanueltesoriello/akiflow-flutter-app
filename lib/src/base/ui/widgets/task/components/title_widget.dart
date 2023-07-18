import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: task.statusType == TaskStatusType.deleted || task.deletedAt != null
                          ? ColorsExt.grey600(context)
                          : ColorsExt.grey900(context),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
