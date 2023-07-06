import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:models/doc/github_doc.dart';
import 'package:models/task/task.dart';

class GithubLinkedContent extends StatelessWidget {
  final Task task;
  final GithubDoc doc;
  final Function itemBuilder;

  const GithubLinkedContent({
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
          value: doc.repo ?? '',
          syncing: true,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.list,
          value: doc.submitter ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: task.title ?? '',
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
