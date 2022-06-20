import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class TodoistLinkedContent extends StatelessWidget {
  final Task task;
  final Doc doc;
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
        ),
        itemBuilder(
          context,
          title: t.linkedContent.date,
          value: doc.dueDateTimeFormatted ?? '',
        ),
      ],
    );
  }
}
