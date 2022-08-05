import 'package:flutter/material.dart';
import 'package:models/task/task.dart';

import '../../../style/colors.dart';
import '../../../utils/task_extension.dart';

class DotPrefix extends StatelessWidget {
  const DotPrefix({Key? key,required this.task}) : super(key: key);
  final Task? task;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      child: Builder(
        builder: (context) {
          Color? color;

          if (task?.statusType == TaskStatusType.inbox && task?.readAt == null) {
            color = ColorsExt.cyan(context);
          }

          try {
            if (task?.content["expiredSnooze"] == true) {
              color = ColorsExt.pink(context);
            }
          } catch (_) {}

          if (color == null) {
            return const SizedBox();
          }

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 5, right: 0, top: 22),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
