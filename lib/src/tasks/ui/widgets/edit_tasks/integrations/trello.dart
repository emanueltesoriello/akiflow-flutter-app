import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:models/doc/trello_doc.dart';
import 'package:models/task/task.dart';

class TrelloLinkedContent extends StatelessWidget {
  final Task task;
  final TrelloDoc doc;
  final Function itemBuilder;

  const TrelloLinkedContent({
    Key? key,
    required this.task,
    required this.doc,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        itemBuilder(context, title: t.linkedContent.board, value: doc.boardName),
        itemBuilder(context, title: t.linkedContent.list, value: doc.listName),
        itemBuilder(
          context,
          title: t.linkedContent.board,
          value: doc.boardName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.list,
          value: doc.listName ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.title,
          value: task.title ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.dueDate,
          value: dueFormatted,
        ),
      ],
    );
  }

  String? get dueFormatted {
    if (doc.due != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(doc.due!).toLocal());
    }
    return '';
  }
}
