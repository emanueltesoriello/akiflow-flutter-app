import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/doc/click_up_doc.dart';
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
          value: doc.teamName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.space,
          value: doc.spaceName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.folder,
          value: doc.folderName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.list,
          value: doc.listName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: task.title ?? '',
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
          title: t.linkedContent.scheduledDate,
          value: task.datetimeFormatted,
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.duration,
          value: task.endTime ?? '',
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
