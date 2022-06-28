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

    List<Widget> children = [];

    Widget status = _status(context);
    if (status is! SizedBox) {
      children.add(status);
    }

    Widget label = _label(context);
    if (label is! SizedBox) {
      children.add(label);
    }

    if (children.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 22 + 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _status(BuildContext context) {
    if (task.statusType == TaskStatusType.inbox && hideInboxLabel) {
      return const SizedBox();
    }

    if (task.statusType == TaskStatusType.inbox) {
      return TagBox(
        icon: "assets/images/icons/_common/tray.svg",
        backgroundColor: ColorsExt.cyan25(context),
        text: t.bottomBar.inbox,
        active: true,
      );
    } else if (task.statusType == TaskStatusType.someday) {
      return TagBox(
        icon: "assets/images/icons/_common/archivebox.svg",
        backgroundColor: ColorsExt.akiflow10(context),
        text: task.statusType!.name.capitalizeFirstCharacter(),
        active: true,
      );
    } else if (task.statusType == TaskStatusType.snoozed) {
      String? text;

      if (task.date != null) {
        DateTime parsed = DateTime.parse(task.date!);

        if (task.isYesterday) {
          text = t.task.yesterday;
        } else {
          text = DateFormat("d MMM").format(parsed);
        }
      }

      if (task.datetime != null) {
        text = task.datetimeFormatted;
      }

      return TagBox(
        icon: "assets/images/icons/_common/clock.svg",
        backgroundColor: ColorsExt.akiflow10(context),
        text: text ?? t.task.snoozed,
        active: true,
      );
    } else if (task.statusType == TaskStatusType.planned && showPlanInfo) {
      return plannedInfo(context);
    } else {
      if (task.datetime != null && !task.isOverdue) {
        return TagBox(
          backgroundColor: ColorsExt.cyan25(context),
          text: task.timeFormatted,
          active: true,
        );
      }
    }

    return const SizedBox();
  }

  Widget plannedInfo(BuildContext context) {
    Color color = ColorsExt.grey5(context);

    String text;

    if (task.date != null) {
      DateTime parsed = DateTime.parse(task.date!);

      if (task.isToday) {
        text = t.addTask.today;
      } else if (task.isTomorrow) {
        text = t.addTask.tmw;
      } else {
        text = DateFormat("d MMM").format(parsed);
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
        context.read<LabelsCubit>().selectLabel(label);
        context.read<MainCubit>().changeHomeView(HomeViewType.label);
      },
      active: active,
    );
  }
}
