import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/doc_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/trello_doc.dart';
import 'package:models/task/task.dart';

class TrelloLinkedContent extends StatelessWidget {
  final Task task;
  final Doc doc;
  final Function itemBuilder;

  const TrelloLinkedContent({
    Key? key,
    required this.task,
    required this.doc,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(doc.toSql());
    return Column(
      children: [
        itemBuilder(context, title: t.linkedContent.board, value: doc.boardName),
        itemBuilder(context, title: t.linkedContent.list, value: doc.listName),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: doc.title ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.dueDate,
          value: doc.dueFormatted,
        ),
      ],
    );
  }
}
