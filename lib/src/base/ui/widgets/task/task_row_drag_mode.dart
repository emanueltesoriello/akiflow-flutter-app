import 'package:flutter/material.dart';
import 'package:mobile/src/base/ui/widgets/task/task_row.dart';
import 'package:models/task/task.dart';

class TaskRowDragMode extends TaskRow {
  TaskRowDragMode(Task task, {Key? key})
      : super(
          key: key,
          completedClick: () {},
          selectTask: () {},
          task: task.copyWith(selected: true),
          showLabel: false,
          showPlanInfo: false,
          hideInboxLabel: true,
          swipeActionPlanClick: () {},
          swipeActionSelectLabelClick: () {},
          swipeActionSnoozeClick: () {},
          selectMode: true,
        );
}
