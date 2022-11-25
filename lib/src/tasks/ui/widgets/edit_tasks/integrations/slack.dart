import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/doc_extension.dart';
import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
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
          value: doc.content?["channelName"] ?? doc.content?["channel_name"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.user,
          value: doc.content?["userName"] ?? doc.content?["user_name"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.savedOn,
          value: doc.starredAtFormatted,
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
