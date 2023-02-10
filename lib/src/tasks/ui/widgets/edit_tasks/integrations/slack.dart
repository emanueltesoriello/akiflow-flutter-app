import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/doc_extension.dart';
import 'package:models/account/account.dart';
import 'package:models/doc/slack_doc.dart';
import 'package:models/task/task.dart';

class SlackLinkedContent extends StatelessWidget {
  final Task task;
  final SlackDoc doc;
  final Account? account;
  final Function itemBuilder;

  const SlackLinkedContent({
    Key? key,
    required this.task,
    required this.doc,
    required this.itemBuilder,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        itemBuilder(
          context,
          title: t.linkedContent.workspace,
          value: doc.getWorkspace(account),
        ),
        itemBuilder(
          context,
          title: t.linkedContent.channel,
          value: task.doc?.value?.channelName ?? ''
        ),
        itemBuilder(
          context,
          title: t.linkedContent.user,
          value: task.doc?.value?.userName ?? ''
        ),
        itemBuilder(
          context,
          title: t.linkedContent.savedOn,
          value: task.doc?.value?.starredAtFormatted ?? '',
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