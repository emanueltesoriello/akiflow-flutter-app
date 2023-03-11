import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:models/doc/jira_doc.dart';
import 'package:models/task/task.dart';

class JiraLinkedContent extends StatelessWidget {
  final Task task;
  final JiraDoc doc;
  final Function itemBuilder;

  const JiraLinkedContent({
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
          title: t.linkedContent.team,
          value: doc.teamName ?? '',
        ),
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
      ],
    );
  }
}
