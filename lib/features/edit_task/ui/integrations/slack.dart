import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class SlackLinkedContent extends StatelessWidget {
  final Task task;
  final Doc doc;
  final Function itemBuilder;

  const SlackLinkedContent({
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
          title: t.linkedContent.channel,
          value: doc.content?["channelName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.message,
          value: doc.title ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.user,
          value: doc.content?["userName"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.starredAt,
          value: doc.starredAtFormatted,
        ),
        // TODO slack attachments `SlackStarredMessageLinkedContent`
      ],
    );
  }
}
