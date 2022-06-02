import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/tagbox.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/string_ext.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class TaskInfo extends StatelessWidget {
  final Task task;
  final bool hideInboxLabel;
  final DateTime? selectDate;
  final bool showLabel;
  final bool showPlanInfo;

  const TaskInfo(
    this.task, {
    Key? key,
    required this.hideInboxLabel,
    required this.selectDate,
    required this.showLabel,
    required this.showPlanInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (task.statusType == null && !task.isOverdue && task.listId == null && !hideInboxLabel) {
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 10.5),
        Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _status(context),
            _label(context),
          ],
        ),
      ],
    );
  }

  Widget _status(BuildContext context) {
    void statusClick() {
      print(task.status);
    }

    if (task.statusType == TaskStatusType.inbox && hideInboxLabel) {
      return const SizedBox();
    }

    if (task.statusType == TaskStatusType.inbox) {
      return TagBox(
        icon: "assets/images/icons/_common/tray.svg",
        backgroundColor: ColorsExt.cyan25(context),
        text: t.bottomBar.inbox,
        onPressed: statusClick,
        active: true,
      );
    } else if (task.statusType == TaskStatusType.someday) {
      return TagBox(
        icon: "assets/images/icons/_common/archivebox.svg",
        backgroundColor: ColorsExt.akiflow10(context),
        text: task.statusType!.name.capitalizeFirstCharacter(),
        onPressed: statusClick,
        active: true,
      );
    } else if (task.statusType == TaskStatusType.snoozed) {
      return TagBox(
        icon: "assets/images/icons/_common/clock.svg",
        backgroundColor: ColorsExt.akiflow10(context),
        text: task.datetimeFormatted,
        onPressed: statusClick,
        active: true,
      );
    } else if (task.statusType == TaskStatusType.planned && showPlanInfo) {
      return plannedInfo(context);
    } else {
      if (task.datetime != null && !task.isOverdue) {
        return TagBox(
          backgroundColor: ColorsExt.cyan25(context),
          text: task.timeFormatted,
          onPressed: statusClick,
          active: true,
        );
      }
    }

    return const SizedBox();
  }

  Widget plannedInfo(BuildContext context) {
    String text;
    Color color;

    TaskStatusType? status = TaskStatusTypeExt.fromId(task.status) ?? TaskStatusType.inbox;

    if ((status == TaskStatusType.inbox || status == TaskStatusType.planned) && status != TaskStatusType.someday) {
      color = ColorsExt.cyan25(context);
    } else if (status == TaskStatusType.completed) {
      color = ColorsExt.green20(context);
    } else {
      color = ColorsExt.pink30(context);
    }

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

    return TagBox(
      text: text,
      backgroundColor: color,
      active: true,
    );
  }

  Widget _label(BuildContext context) {
    if (!showLabel) {
      return const SizedBox();
    }

    if (task.listId == null || task.listId!.isEmpty) {
      return const SizedBox();
    }

    List<Label> labels = context.watch<LabelsCubit>().state.labels;

    Label? label = labels.firstWhereOrNull(
      (label) => task.listId!.contains(label.id!),
    );

    if (label == null || label.deletedAt != null) {
      return const SizedBox();
    }

    bool active = label.color != null;

    return TagBox(
      icon: "assets/images/icons/_common/number.svg",
      text: label.title,
      backgroundColor: active ? ColorsExt.getFromName(label.color!).withOpacity(0.1) : null,
      iconColor: active ? ColorsExt.getFromName(label.color!) : ColorsExt.grey3(context),
      onPressed: () {
        context.read<MainCubit>().selectLabel(label);
      },
      active: active,
    );
  }
}
