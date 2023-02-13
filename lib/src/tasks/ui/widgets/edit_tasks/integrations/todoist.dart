import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/doc/todoist_doc.dart';
import 'package:models/task/task.dart';

class TodoistLinkedContent extends StatelessWidget {
  final Task task;
  final TodoistDoc doc;
  final Function itemBuilder;

  const TodoistLinkedContent({
    Key? key,
    required this.task,
    required this.doc,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        itemBuilder(
          context,
          title: t.linkedContent.project,
          value: doc.projectName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: task.title ?? '',
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.task.description,
          value: task.description ?? '',
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.scheduledDate,
          value: task.datetimeFormatted,
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.date,
          value: task.dueDateFormatted,
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.task.priority.title,
          value: task.priorityName,
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.status,
          value: (task.done ?? false) ? t.linkedContent.done : t.linkedContent.toDo,
          syncing: true,
        ),
      ],
    );
  }
}
