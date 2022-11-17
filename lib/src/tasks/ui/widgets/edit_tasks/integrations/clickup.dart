import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/doc_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/doc/click_up_doc.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class ClickupLinkedContent extends StatelessWidget {
  final Task task;
  final ClickupDoc doc;
  final Function itemBuilder;

  const ClickupLinkedContent({
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
          title: t.linkedContent.workspace,
          value: doc.content?["teamName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.space,
          value: doc.content?["spaceName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.folder,
          value: doc.content?["folderName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.list,
          value: doc.content?["listName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: doc.title ?? '',
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
          title: "Scheduled Date",
          value: task.datetimeFormatted,
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
          title: "Duration",
          value: task.endTime,
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
