import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/string_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
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
    String? text;
    Color? color;

    if (task.statusType == TaskStatusType.inbox) {
      leadingIconAsset = Assets.images.icons.common.traySVG;
      color = ColorsExt.cyan25(context);
      text = t.bottomBar.inbox;
    } else if (task.statusType == TaskStatusType.someday) {
      leadingIconAsset = Assets.images.icons.common.archiveboxSVG;
      color = ColorsExt.akiflow10(context);
      text = task.statusType!.name.capitalizeFirstCharacter();
    } else if (task.statusType == TaskStatusType.snoozed) {
      if (task.date != null) {
        DateTime parsed = DateTime.parse(task.date!);

        if (task.isYesterday) {
          text = t.task.yesterday;
        } else {
          text = DateFormat("EEE, d MMM").format(parsed);
        }
      }

      if (task.datetime != null) {
        text = task.datetimeFormatted;
      }

      leadingIconAsset = Assets.images.icons.common.clockSVG;
      color = ColorsExt.akiflow10(context);
      text = text ?? t.task.snoozed;
    } else if (task.statusType == TaskStatusType.planned) {
      leadingIconAsset = Assets.images.icons.common.calendarSVG;
      color = ColorsExt.grey5(context);

      if (task.date != null) {
        DateTime parsed = DateTime.parse(task.date!);
        text = DateFormat("EEE, d MMM").format(parsed);
      } else {
        text = t.bottomBar.inbox;
      }

      if (task.datetime != null) {
        DateTime parsed = DateTime.parse(task.datetime!).toLocal();
        text = "$text ${DateFormat("HH:mm").format(parsed)}";
      }
    } else if (task.date != null && !task.isOverdue) {
      color = ColorsExt.cyan25(context);
      DateTime parsed = DateTime.parse(task.date!);
      text = DateFormat("EEE, d MMM").format(parsed);
    }

    return TagBox(
      text: text,
      backgroundColor: color,
      icon: leadingIconAsset,
      isBig: true,
      active: true,
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
    );
  }
}
