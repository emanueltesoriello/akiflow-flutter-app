import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/string_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
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

  Widget _overdue(BuildContext context) {
    if (task.isOverdue && task.datetime != null && task.datetime!.isNotEmpty) {
      var formattedDate = DateTime.tryParse(task.datetime!)!.toLocal();
      if (formattedDate == null) {
        return const SizedBox();
      }
      var stringDate = DateFormat("dd MMM").add_Hm().format(formattedDate);
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: SizedBox(
          height: 22 + 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TagBox(
                text: stringDate,
                backgroundColor: ColorsExt.cosmos200(context),
                active: true,
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    Widget status = _status(context);
    Widget label = _label(context);
    if (status is! SizedBox) {
      children.add(status);
    }
    if (label is! SizedBox) {
      children.add(label);
    }

    return Row(
      children: [
        children.isEmpty
            ? const SizedBox()
            : SizedBox(
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
              ),
      ],
    );
  }

  Widget _status(BuildContext context) {
    if (task.statusType == TaskStatusType.inbox && hideInboxLabel) {
      return const SizedBox();
    }

    if (task.statusType == TaskStatusType.inbox) {
      return TagBox(
        icon: Assets.images.icons.common.traySVG,
        backgroundColor: ColorsExt.jordyBlue200(context),
        text: t.bottomBar.inbox,
        active: true,
      );
    } else if (task.statusType == TaskStatusType.someday) {
      return TagBox(
        icon: Assets.images.icons.common.archiveboxSVG,
        backgroundColor: ColorsExt.akiflow100(context),
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
        icon: Assets.images.icons.common.clockSVG,
        backgroundColor: ColorsExt.akiflow100(context),
        text: text ?? t.task.snoozed,
        active: true,
      );
    } else if (task.statusType == TaskStatusType.planned && (showPlanInfo || task.isOverdue)) {
      return plannedInfo(context);
    } else {
      if (task.datetime != null && !task.isOverdue) {
        return TagBox(
          backgroundColor: (task.done ?? false) ? ColorsExt.yorkGreen200(context) : ColorsExt.grey200(context),
          text: task.timeFormatted,
          active: true,
        );
      }
    }

    return const SizedBox();
  }

  Widget plannedInfo(BuildContext context) {
    Color color = (task.done ?? false) ? ColorsExt.yorkGreen200(context) : ColorsExt.grey200(context);

    if (task.isOverdue) {
      color = ColorsExt.cosmos200(context);
    }

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
      icon: Assets.images.icons.common.numberSVG,
      text: label.title,
      backgroundColor: active ? ColorsExt.getLightColorFromName(label.color!) : null,
      iconColor: active ? ColorsExt.getFromName(label.color!) : ColorsExt.grey600(context),
      onPressed: () {
        context.read<LabelsCubit>().selectLabel(label);
        context.read<MainCubit>().changeHomeView(HomeViewType.label);
      },
      active: active,
    );
  }
}
