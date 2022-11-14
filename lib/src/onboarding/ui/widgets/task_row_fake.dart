import 'package:flutter/material.dart';
import 'package:mobile/common/components/task/task_row.dart';
import 'package:models/task/task.dart';

class TaskRowFake extends TaskRow {
  TaskRowFake(Task task, {Key? key})
      : super(
          key: key,
          completedClick: () {},
          selectTask: () {},
          task: task.copyWith(selected: false),
          showLabel: false,
          showPlanInfo: false,
          hideInboxLabel: true,
          swipeActionPlanClick: () {},
          swipeActionSelectLabelClick: () {},
          swipeActionSnoozeClick: () {},
          selectMode: false,
          isOnboarding: true,
        );
}
