import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/doc/gmail_doc.dart';
import 'package:models/task/task.dart';

class GmailLinkedContent extends StatelessWidget {
  final GmailDoc doc;
  final Task task;
  final Function itemBuilder;

  const GmailLinkedContent({
    Key? key,
    required this.doc,
    required this.task,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        itemBuilder(
          context,
          title: t.linkedContent.subject,
          value: doc.title ?? t.noTitle,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.from,
          value: task.doc?.value?.from ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.date,
          value: task.internalDateFormatted,
        ),
      ],
    );
  }
}
