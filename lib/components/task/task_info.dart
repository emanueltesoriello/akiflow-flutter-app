import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/aki_chip.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/string_ext.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class TaskInfo extends StatelessWidget {
  final Task task;
  final bool hideInboxLabel;
  final DateTime? selectDate;
  final bool hideLabel;

  const TaskInfo(
    this.task, {
    Key? key,
    required this.hideInboxLabel,
    required this.selectDate,
    required this.hideLabel,
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
      return AkiChip(
        icon: "assets/images/icons/_common/tray.svg",
        backgroundColor: ColorsExt.cyan25(context),
        text: t.bottomBar.inbox,
        onPressed: statusClick,
      );
    } else if (task.statusType == TaskStatusType.someday) {
      return AkiChip(
        icon: "assets/images/icons/_common/archivebox.svg",
        backgroundColor: ColorsExt.akiflow10(context),
        text: task.statusType!.name.capitalizeFirstCharacter(),
        onPressed: statusClick,
      );
    } else if (task.statusType == TaskStatusType.snoozed) {
      return AkiChip(
        icon: "assets/images/icons/_common/clock.svg",
        backgroundColor: ColorsExt.akiflow10(context),
        text: task.datetimeFormatted,
        onPressed: statusClick,
      );
    } else {
      if (task.datetime != null && !task.isOverdue) {
        return AkiChip(
          backgroundColor: ColorsExt.cyan25(context),
          text: task.timeFormatted,
          onPressed: statusClick,
        );
      }
    }

    return const SizedBox();
  }

  Widget _label(BuildContext context) {
    if (hideLabel) {
      return const SizedBox();
    }

    if (task.listId == null || task.listId!.isEmpty) {
      return const SizedBox();
    }

    List<Label> labels = context.watch<TasksCubit>().state.labels;

    Label? label = labels.firstWhereOrNull(
      (label) => task.listId!.contains(label.id!),
    );

    if (label == null) {
      return const SizedBox();
    }

    return Wrap(
      children: [
        AkiChip(
          icon: "assets/images/icons/_common/number.svg",
          text: label.title,
          backgroundColor: label.color != null ? ColorsExt.getFromName(label.color!).withOpacity(0.1) : null,
          iconColor: label.color != null ? ColorsExt.getFromName(label.color!) : ColorsExt.grey3(context),
          onPressed: () {},
        ),
      ],
    );
  }
}
