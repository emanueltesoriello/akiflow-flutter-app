import 'package:flutter/material.dart';
import 'package:mobile/components/task/task_row.dart';
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
          swipeActionPlanClick: () {},
          swipeActionSelectLabelClick: () {},
          swipeActionSnoozeClick: () {},
          selectMode: true,
        ) {
    print(task.id);
  }
}
