import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/add_task/ui/add_task_action_item.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class PlanForAction extends StatelessWidget {
  final Task task;
  final Function() onTap;

  const PlanForAction({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? leadingIconAsset;
    String text;
    Color color;

    TaskStatusType? status = TaskStatusTypeExt.fromId(task.status) ?? TaskStatusType.inbox;

    if ((status == TaskStatusType.inbox || status == TaskStatusType.planned) && status != TaskStatusType.someday) {
      color = ColorsExt.cyan25(context);
      leadingIconAsset = "assets/images/icons/_common/calendar.svg";
    } else if (status == TaskStatusType.completed) {
      color = ColorsExt.green20(context);
    } else {
      color = ColorsExt.pink30(context);
      leadingIconAsset = "assets/images/icons/_common/clock.svg";
    }

    if (status != TaskStatusType.completed) {
      if (task.date != null) {
        DateTime parsed = DateTime.parse(task.date!).toLocal();

        if (task.isToday) {
          text = t.addTask.today;
        } else if (task.isTomorrow) {
          text = t.addTask.tmw;
        } else {
          text = DateFormat("EEE, d MMM").format(parsed);
        }
      } else if (task.status == TaskStatusType.someday.id) {
        text = t.task.someday;
      } else {
        text = t.bottomBar.inbox;
      }

      if (task.datetime != null) {
        DateTime parsed = DateTime.parse(task.datetime!).toLocal();
        text = "$text ${DateFormat("HH:mm").format(parsed)}";
      }
    } else {
      text = task.doneAtFormatted;
    }

    return AddTaskActionItem(
      text: text,
      color: color,
      leadingIconAsset: leadingIconAsset,
      active: true,
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
    );
  }
}
