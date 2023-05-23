import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/task/task.dart';

class DotPrefix extends StatelessWidget {
  const DotPrefix({Key? key, required this.task}) : super(key: key);
  final Task? task;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimension.appBarLeadingIcon,
      height: Dimension.appBarLeadingIcon,
      child: Builder(
        builder: (context) {
          Color? color;

          if (task?.statusType == TaskStatusType.inbox && task?.readAt == null) {
            color = ColorsExt.jordyBlue400(context);
          }

          try {
            if (task?.content != null && task?.content["expiredSnooze"] == true) {
              color = ColorsExt.rose400(context);
            }
          } catch (_) {}

          if (color == null) {
            return const SizedBox();
          }

          return Align(
            alignment: Alignment.topRight,
            child: Container(
              // width: 8,
              // height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
