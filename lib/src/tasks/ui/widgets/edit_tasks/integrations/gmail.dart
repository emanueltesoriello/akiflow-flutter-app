import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
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
          value: doc.subject ?? t.noTitle,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.from,
          value: doc.from ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.date,
          value: internalDateFormatted,
        ),
      ],
    );
  }

  String get internalDateFormatted {
    DateTime? internalDate;

    if (doc.internalDate != null) {
      int internalDateAsMilliseconds = int.parse(doc.internalDate!);
      internalDate = DateTime.fromMillisecondsSinceEpoch(internalDateAsMilliseconds).toLocal();
    }

    if (internalDate != null) {
      if (internalDate.toLocal().day == DateTime.now().day &&
          internalDate.toLocal().month == DateTime.now().month &&
          internalDate.toLocal().year == DateTime.now().year) {
        return t.task.today;
      } else {
        return DateFormat("dd MMM yyyy").format(internalDate.toLocal());
      }
    } else {
      return '';
    }
  }
}
