import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/doc_extension.dart';
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
          value: doc.content?["projectName"] ?? doc.content?["project_name"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: task.title ?? '',
          syncing: true,
        ),
        itemBuilder(
          context,
          title: "Description",
          value: task.description ?? '',
          syncing: true,
        ),
        itemBuilder(
          context,
          title: "Scheduled Date",
          value: task.datetimeFormatted,
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.date,
          value: doc.dueDateTimeFormatted ?? '',
          syncing: true,
        ),
        itemBuilder(
          context,
          title: "Priority",
          value: task.priorityName,
          syncing: true,
        ),
        itemBuilder(
          context,
          title: "Status",
          value: (task.done ?? false) ? "Done" : "Not Done",
          syncing: true,
        ),
      ],
    );
  }
}
