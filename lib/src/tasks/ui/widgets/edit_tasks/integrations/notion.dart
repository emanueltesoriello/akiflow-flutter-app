import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/doc/notion_doc.dart';
import 'package:models/task/task.dart';

class NotionLinkedContent extends StatelessWidget {
  final Task task;
  final NotionDoc doc;
  final Function itemBuilder;

  const NotionLinkedContent({
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
          value: doc.workspaceName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: task.title ?? '',
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.created,
          value: createdAtFormatted ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.scheduledDate,
          value: task.datetimeFormatted,
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.lastEdit,
          value: modifiedAtFormatted ?? '',
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

    String? get createdAtFormatted {
    if (doc.createdAt != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(doc.createdAt!).toLocal());
    }

    return '';
  }

    String? get modifiedAtFormatted {
    if (doc.updatedAt != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(doc.updatedAt!).toLocal());
    }

    return '';
  }

}
