import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class AsanaLinkedContent extends StatelessWidget {
  final Task task;
  final Doc doc;
  final Function itemBuilder;

  const AsanaLinkedContent({
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
          value: doc.content?["workspaceName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.project,
          value: doc.content?["projectName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.parentTask,
          value: task.title ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: doc.title ?? '',
        ),
      ],
    );
  }
}
